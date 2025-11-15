
// # Deploy and set the provider to OpenAI
// firebase deploy --only functions --set-env-vars="VISION_MODEL_PROVIDER=OPENAI"

// # Switch back to Gemini (the default)
// firebase deploy --only functions --set-env-vars="VISION_MODEL_PROVIDER=GEMINI"

import { Storage } from "@google-cloud/storage";
import { Part, VertexAI } from "@google-cloud/vertexai";
import axios from "axios";
import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import { defineString } from "firebase-functions/params";
import { onObjectFinalized } from "firebase-functions/v2/storage";

initializeApp();

const db = getFirestore();
const storage = new Storage();

// --- Model Configuration ---
// Use this parameter to switch between vision models.
// Supported values: "GEMINI", "OPENAI"
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

const prompt =
    "Identify the game name, player name, and score from this image. " +
    "Respond in JSON format with keys: game, player, score.";

/**
 * Analyzes an image using the OpenAI GPT-4 Vision model.
 * @param {string} imageUrl The public URL of the image to analyze.
 * @return {Promise<any>} The parsed JSON response from the model.
 */
async function analyzeWithOpenAI(imageUrl: string): Promise<any> {
    const response = await axios.post(
        openAIApiUrl.value(),
        {
            model: "gpt-4.1-nano",
            messages: [
                {
                    role: "user",
                    content: [
                        { type: "text", text: prompt },
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
}

/**
 * Analyzes an image using the Google Gemini Pro Vision model.
 * @param {string} gcsUri The Google Cloud Storage URI of the image.
 * @return {Promise<any>} The parsed JSON response from the model.
 */
async function analyzeWithGemini(gcsUri: string): Promise<any> {
    const generativeModel = vertexAI.getGenerativeModel({ model: geminiModel });
    const imagePart: Part = {
        fileData: {
            mimeType: "image/jpeg", // Assuming jpeg, adjust if needed.
            fileUri: gcsUri,
        },
    };

    const request = {
        contents: [{ role: "user", parts: [{ text: prompt }, imagePart] }],
    };

    const result = await generativeModel.generateContent(request);
    const response = result.response;
    const text = response.candidates?.[0]?.content?.parts?.[0]?.text;

    if (!text) {
        throw new Error("Failed to get a response from Gemini model.");
    }
    return JSON.parse(text);
}

export const processScoreImage = onObjectFinalized(
    { cpu: 2 },
    async (event) => {
        const { bucket: fileBucket, name: filePath, contentType } = event.data;

        if (!filePath || !filePath.startsWith("scores/")) {
            logger.log("Not a score image.");
            return;
        }

        if (!contentType || !contentType.startsWith("application/octet-stream")) {
            logger.log("This is not an image file.");
            return;
        }

        try {
            let parsedResponse;
            const provider = visionModelProvider.value().toUpperCase();

            if (provider === "GEMINI") {
                const gcsUri = `gs://${fileBucket}/${filePath}`;
                logger.log(`Analyzing with Gemini: ${gcsUri}`);
                parsedResponse = await analyzeWithGemini(gcsUri);
            } else if (provider === "OPENAI") {
                const file = storage.bucket(fileBucket).file(filePath);
                const [signedUrl] = await file.getSignedUrl({
                    version: "v4",
                    action: "read",
                    expires: Date.now() + 15 * 60 * 1000, // 15 minutes
                });
                logger.log(`Analyzing with OpenAI: ${signedUrl}`);
                parsedResponse = await analyzeWithOpenAI(signedUrl);
            } else {
                logger.error(`Invalid vision model provider: ${provider}`);
                return;
            }

            logger.log("Parsed response from vision model:", parsedResponse);

            const { game, player, score } = parsedResponse;

            const scoreAsNumber = Number(score);
            logger.log("Parsed scoreAsNumber from vision model:", scoreAsNumber);

            if (game && player && !isNaN(scoreAsNumber)) {
                await db.collection("scores").add({
                    game,
                    player,
                    scoreAsNumber,
                    createdAt: new Date(),
                    imagePath: filePath,
                });
                logger.log("Score saved to Firestore:", parsedResponse);
            } else {
                logger.error(
                    "Could not parse all required fields from vision model response.",
                    parsedResponse,
                );
            }
        } catch (error) {
            logger.error("Error processing image:", error);
        }
    },
);
