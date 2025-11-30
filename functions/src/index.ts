
// # Deploy and set the provider to OpenAI
// firebase deploy --only functions --set-env-vars="VISION_MODEL_PROVIDER=OPENAI"

// # Switch back to Gemini (the default)
// firebase deploy --only functions --set-env-vars="VISION_MODEL_PROVIDER=GEMINI"

// --- Stern API Functions (separate module) ---
export { getSternGameTeams, getSternHighScores, getSternMachineDetails, getSternMachines } from "./stern_api";

import { Storage } from "@google-cloud/storage";
import { Part, VertexAI } from "@google-cloud/vertexai";
import axios from "axios";
import { initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import { defineString } from "firebase-functions/params";
import { onDocumentCreated } from "firebase-functions/v2/firestore";

initializeApp();

const db = getFirestore();
const storage = new Storage();

// --- Model Configuration ---
const visionModelProvider = defineString("VISION_MODEL_PROVIDER", {
    default: "OPENAI",
    description: 'The vision model provider to use. Either "GEMINI" or "OPENAI".',
});

// --- OpenAI Configuration ---
const openAIApiKey = defineString("OPENAI_API_KEY");
const openAIApiUrl = defineString("OPENAI_API_URL", {
    default: "https://api.openai.com/v1/chat/completions",
});

// --- Vertex AI (Gemini) Configuration ---
const vertexAI = new VertexAI({
    project: process.env.GCLOUD_PROJECT || "",
    location: "us-central1",
});
const geminiModel = "gemini-pro-vision";
const scorePrompt = `You are an image-analysis agent. Analyze the provided pinball score screen and extract the score for the specified player number. Follow ALL rules exactly and strictly.

============================================================
INTERPRETATION RULES
============================================================
1. Ignore ALL player names, labels, or text-based identifiers such as “PLAYER 1”, “P1”, or custom names. 
   Player numbers are determined ONLY by POSITION, never by text.

2. Identify ALL numeric values that could be player scores. 
   A score is a multi-digit number typically shown on a pinball display.

3. Determine the layout of score positions:
   - If arranged in ROWS: read LEFT → RIGHT, then TOP → BOTTOM (like reading a book).
   - If arranged in COLUMNS: read TOP → BOTTOM for each column, then LEFT COLUMN → RIGHT COLUMN.
   - If arranged in QUADRANTS: read LEFT → RIGHT, TOP → BOTTOM.
   - If scores appear in irregular locations: sort by reading order using:
       a) Highest (top-most) first  
       b) If equal height, left-most first  

4. Once numerically filtered and correctly ordered:
   Player 1 = first score  
   Player 2 = second score  
   Player 3 = third score  
   Player 4 = fourth score  

============================================================
PINBALL SCORE FILTER RULES (IMPORTANT)
============================================================
1. **Ignore ANY number that is 1 or 2 digits long (0–99).**
   These are NOT player scores. They are commonly “match numbers” shown at end of game. 
   Pinball scores NEVER have only 1–2 digits.

2. A valid score MUST:
   - Be at least **3 digits long**  
   - Typically be in the thousands, hundreds of thousands, or millions  
   - Appear in an area where multiple player scores are grouped together

3. If a large 1–2 digit number appears prominently in the center of the screen, it is ALWAYS a match number and MUST be excluded completely.

4. If multiple multi-digit numbers exist:
   - Favor numbers that share consistent font size  
   - Favor numbers grouped horizontally or vertically  
   - Ignore jackpot values, timer numbers, credit counters, or UI numbers unrelated to scoring

============================================================
PLAYER REQUEST
============================================================
Extract the score for:
PLAYER NUMBER = {PLAYER_NUMBER}

============================================================
OUTPUT FORMAT (STRICT)
============================================================
Respond ONLY with the following JSON. No explanations.

{
  "score": <number or null>,
  "confidence": "high" | "medium" | "low",
  "error": "<description only if score is null>"
}

If you are uncertain, set score = null and confidence = "low".
`;

/**
 * Analyzes an image using the OpenAI GPT-4 Vision model.
 */
async function analyzeWithOpenAI(imageUrl: string, playerNumber: number): Promise<any> {
    const promptWithPlayer = scorePrompt.replace("{PLAYER_NUMBER}", playerNumber.toString());

    try {
        const response = await axios.post(
            openAIApiUrl.value(),
            {
                // model: "gpt-4.1-nano",
                model: "gpt-4o-mini",
                messages: [
                    {
                        role: "user",
                        content: [
                            { type: "text", text: promptWithPlayer },
                            { type: "image_url", image_url: { url: imageUrl } },
                        ],
                    },
                ],
                max_tokens: 300,
            },
            {
                headers: {
                    "Content-Type": "application/json",
                    Authorization: `Bearer ${openAIApiKey.value()}`,
                },
            },
        );

        const message = response.data.choices[0].message.content;
        const jsonString = message.match(/```json\n([\s\S]*?)\n```/)?.[1] || message;
        return JSON.parse(jsonString);
    } catch (error: any) {
        if (error.response?.data) {
            logger.error("OpenAI API error details:", JSON.stringify(error.response.data, null, 2));
        }
        throw error;
    }
}

/**
 * Analyzes an image using the Google Gemini Pro Vision model.
 */
async function analyzeWithGemini(gcsUri: string, playerNumber: number): Promise<any> {
    const promptWithPlayer = scorePrompt.replace("{PLAYER_NUMBER}", playerNumber.toString());
    const generativeModel = vertexAI.getGenerativeModel({ model: geminiModel });
    const imagePart: Part = {
        fileData: {
            mimeType: "image/jpeg",
            fileUri: gcsUri,
        },
    };

    const request = {
        contents: [{ role: "user", parts: [{ text: promptWithPlayer }, imagePart] }],
    };

    const result = await generativeModel.generateContent(request);
    const response = result.response;
    const text = response.candidates?.[0]?.content?.parts?.[0]?.text;

    if (!text) {
        throw new Error("Failed to get a response from Gemini model.");
    }
    return JSON.parse(text);
}

/**
 * Updates leaderboard entries for a new score
 */
async function updateLeaderboards(
    userId: string,
    pinballId: string,
    score: number,
    displayName: string,
    submittedAt: Date,
): Promise<void> {
    // --- Maintain Top 20 Leaderboard Entries ---
    // All-time leaderboard
    const allTimeDocRef = db.collection("leaderboards").doc(`${pinballId}_all_time`);
    const allTimeEntriesRef = allTimeDocRef.collection("entries");

    // Add/update entry if score is higher than user's previous
    const userEntryRef = allTimeEntriesRef.doc(userId);
    const userEntrySnap = await userEntryRef.get();
    if (!userEntrySnap.exists || (userEntrySnap.data()?.highScore || 0) < score) {
        await userEntryRef.set({
            userId,
            displayName,
            highScore: score,
            lastUpdated: FieldValue.serverTimestamp(),
        }, { merge: true });
    }

    // Get all entries, order by highScore desc
    const allEntriesSnap = await allTimeEntriesRef.orderBy("highScore", "desc").get();
    const entries = allEntriesSnap.docs.map(doc => ({ id: doc.id, ...(doc.data() as any) }));
    const topEntries = entries.slice(0, 20);
    const extraEntries = entries.slice(20);

    // Delete entries beyond top 20
    for (const entry of extraEntries) {
        await allTimeEntriesRef.doc(entry.id).delete();
    }

    // Update leaderboard summary document
    const high = topEntries.length > 0 ? topEntries[0].highScore : null;
    const low = topEntries.length > 0 ? topEntries[topEntries.length - 1].highScore : null;
    const count = topEntries.length;
    await allTimeDocRef.set({ high, low, count, lastUpdated: FieldValue.serverTimestamp() }, { merge: true });

    // --- Monthly leaderboard ---
    const month = submittedAt.toISOString().slice(0, 7); // YYYY-MM
    const monthlyDocRef = db.collection("leaderboards").doc(`${pinballId}_monthly_${month}`);
    const monthlyEntriesRef = monthlyDocRef.collection("entries");
    const monthlyUserEntryRef = monthlyEntriesRef.doc(userId);
    const monthlyUserEntrySnap = await monthlyUserEntryRef.get();
    if (!monthlyUserEntrySnap.exists || (monthlyUserEntrySnap.data()?.highScore || 0) < score) {
        await monthlyUserEntryRef.set({
            userId,
            displayName,
            highScore: score,
            submittedAt: FieldValue.serverTimestamp(),
        }, { merge: true });
    }
    const monthlyEntriesSnap = await monthlyEntriesRef.orderBy("highScore", "desc").get();
    const monthlyEntries = monthlyEntriesSnap.docs.map(doc => ({ id: doc.id, ...(doc.data() as any) }));
    const monthlyTopEntries = monthlyEntries.slice(0, 20);
    const monthlyExtraEntries = monthlyEntries.slice(20);
    for (const entry of monthlyExtraEntries) {
        await monthlyEntriesRef.doc(entry.id).delete();
    }
    const monthlyHigh = monthlyTopEntries.length > 0 ? monthlyTopEntries[0].highScore : null;
    const monthlyLow = monthlyTopEntries.length > 0 ? monthlyTopEntries[monthlyTopEntries.length - 1].highScore : null;
    const monthlyCount = monthlyTopEntries.length;
    await monthlyDocRef.set({ high: monthlyHigh, low: monthlyLow, count: monthlyCount, lastUpdated: FieldValue.serverTimestamp() }, { merge: true });
}

/**
 * Cloud Function triggered on new score submission
 */
export const processScoreSubmission = onDocumentCreated(
    {
        document: "score_submissions/{submissionId}",
        cpu: 2,
    },
    async (event) => {
        const snapshot = event.data;
        if (!snapshot) {
            logger.error("No data associated with the event");
            return;
        }

        const submissionId = event.params.submissionId;
        const data = snapshot.data();
        const { userId, pinballId, playerNumber, imageUrl, status } = data;

        logger.log(`Processing submission ${submissionId} for user ${userId}`);

        // Only process pending submissions
        if (status !== "pending") {
            logger.log(`Submission ${submissionId} is not pending, skipping`);
            return;
        }

        try {
            // Update status to processing
            await snapshot.ref.update({
                status: "processing",
            });

            // Get bucket and file path for the image
            logger.log(`GCLOUD_PROJECT env:`, process.env.GCLOUD_PROJECT);
            const bucketName = "leader-board-2d961.firebasestorage.app";

            logger.log(`Image URL from Firestore: ${imageUrl}`);
            logger.log(`Bucket name: ${bucketName}`);

            const bucket = storage.bucket(bucketName);
            const file = bucket.file(imageUrl);

            // Analyze image with vision model
            let parsedResponse;
            const provider = visionModelProvider.value().toUpperCase();

            // Get file metadata for additional checks/logging
            const [metadata] = await file.getMetadata().catch((err) => {
                logger.error(`Error fetching metadata for file ${imageUrl}:`, err);
                return [{}];
            });
            logger.log(`File metadata for ${imageUrl}:`, metadata);

            if (provider === "GEMINI") {
                const gcsUri = `gs://${bucket.name}/${imageUrl}`;
                logger.log(`Analyzing with Gemini: ${gcsUri}`);
                parsedResponse = await analyzeWithGemini(gcsUri, playerNumber);
            } else if (provider === "OPENAI") {
                // Check if file exists before generating signed URL
                const [exists] = await file.exists();
                logger.log(`File exists in Storage: ${exists}`);

                if (!exists) {
                    throw new Error(`Image file not found in Storage: ${imageUrl}`);
                }

                // Check content type (must be image/*)
                let contentType = "unknown";
                if (metadata && typeof metadata === "object" && "contentType" in metadata && typeof (metadata as any).contentType === "string") {
                    contentType = (metadata as any).contentType;
                }
                logger.log(`File contentType for ${imageUrl}: ${contentType}`);
                if (!contentType.startsWith("image/")) {
                    throw new Error(`File ${imageUrl} has unsupported contentType: ${contentType}`);
                }

                const [signedUrl] = await file.getSignedUrl({
                    version: "v4",
                    action: "read",
                    expires: Date.now() + 15 * 60 * 1000, // 15 minutes
                });
                logger.log(`Generated signed URL for OpenAI: ${signedUrl}`);

                // Test signed URL accessibility (optional, for debugging)
                try {
                    const testRes = await axios.get(signedUrl, { responseType: "arraybuffer" });
                    logger.log(`Signed URL test download status: ${testRes.status}, content-type: ${testRes.headers["content-type"]}`);
                } catch (err) {
                    logger.error(`Failed to download image from signed URL: ${signedUrl}`, err);
                }

                parsedResponse = await analyzeWithOpenAI(signedUrl, playerNumber);
            } else {
                throw new Error(`Invalid vision model provider: ${provider}`);
            }

            logger.log("Parsed response from vision model:", parsedResponse);

            const { score, confidence, error } = parsedResponse;

            if (!score || confidence === "low") {
                // Failed to extract score
                await snapshot.ref.update({
                    status: "rejected",
                    error: error || "Could not extract score from image",
                    processedAt: FieldValue.serverTimestamp(),
                });
                logger.error(`Failed to extract score: ${error}`);
                return;
            }

            const scoreAsNumber = Number(score);
            if (isNaN(scoreAsNumber)) {
                await snapshot.ref.update({
                    status: "rejected",
                    error: "Invalid score format",
                    processedAt: FieldValue.serverTimestamp(),
                });
                return;
            }

            // Get user display name from Firebase Authentication
            let displayName = "Anonymous";
            try {
                const userRecord = await getAuth().getUser(userId);
                if (userRecord.displayName && userRecord.displayName.trim().length > 0) {
                    displayName = userRecord.displayName.trim();
                } else {
                    logger.warn(`Firebase Auth user ${userId} does not have a valid displayName.`);
                }
            } catch (err) {
                logger.error(`Error fetching Firebase Auth user for userId ${userId}:`, err);
            }

            const submittedDate = new Date();
            const month = submittedDate.toISOString().slice(0, 7); // YYYY-MM
            const year = submittedDate.getFullYear();

            // Check for duplicate score on the same day
            const startOfDay = new Date(submittedDate);
            startOfDay.setHours(0, 0, 0, 0);
            const endOfDay = new Date(submittedDate);
            endOfDay.setHours(23, 59, 59, 999);

            const duplicateScoreQuery = await db.collection("scores")
                .where("userId", "==", userId)
                .where("pinballId", "==", pinballId)
                .where("score", "==", scoreAsNumber)
                .where("submittedAt", ">=", startOfDay)
                .where("submittedAt", "<=", endOfDay)
                .limit(1)
                .get();

            if (!duplicateScoreQuery.empty) {
                // Duplicate score found - ignore this submission
                logger.warn(`Duplicate score detected for user ${userId}, pinball ${pinballId}, score ${scoreAsNumber} on ${submittedDate.toISOString().slice(0, 10)}. Ignoring submission.`);

                await snapshot.ref.update({
                    status: "rejected",
                    error: "Duplicate score detected for the same day",
                    processedAt: FieldValue.serverTimestamp(),
                });

                // Delete the image from storage
                await file.delete();
                logger.log(`Deleted duplicate submission image: ${imageUrl}`);

                // Delete the score_submissions document
                await snapshot.ref.delete();
                logger.log(`Deleted duplicate score_submissions document: ${submissionId}`);

                return;
            }

            // Save score to flat scores collection (queryable, real-time)
            const scoreRef = await db.collection("scores").add({
                userId,
                displayName,
                pinballId,
                score: scoreAsNumber,
                playerNumber,
                submittedAt: FieldValue.serverTimestamp(),
                month,
                year,
                imageUrl,
                submissionId,
                competitionId: null, // For future competition support
            });

            logger.log(`Score saved to scores collection: ${scoreRef.id}`);

            // Also save to user's personal scores subcollection (for user history)
            await db
                .collection("users")
                .doc(userId)
                .collection("scores")
                .add({
                    pinballId,
                    score: scoreAsNumber,
                    playerNumber,
                    submittedAt: FieldValue.serverTimestamp(),
                    month,
                    year,
                    imageUrl,
                    submissionId,
                    scoreRefId: scoreRef.id, // Reference to main score doc
                });

            // Update materialized leaderboards (for fast top-N queries)
            await updateLeaderboards(
                userId,
                pinballId,
                scoreAsNumber,
                displayName,
                submittedDate,
            );

            // Update submission status to verified
            await snapshot.ref.update({
                status: "verified",
                score: scoreAsNumber,
                processedAt: FieldValue.serverTimestamp(),
            });

            // Delete the image from storage after successful processing
            await file.delete();
            logger.log(`Deleted image: ${imageUrl}`);

            // Delete the score_submissions document after successful processing
            await snapshot.ref.delete();
            logger.log(`Deleted score_submissions document: ${submissionId}`);

            logger.log(`Successfully processed submission ${submissionId}`);
        } catch (error) {
            logger.error(`Error processing submission ${submissionId}:`, error);

            // Update submission with error
            await snapshot.ref.update({
                status: "rejected",
                error: error instanceof Error ? error.message : "Unknown error",
                processedAt: FieldValue.serverTimestamp(),
                retryCount: FieldValue.increment(1),
            });
        }
    },
);
