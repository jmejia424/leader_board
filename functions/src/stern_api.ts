/**
 * Stern Pinball API Integration
 *
 * This module provides Firebase Cloud Functions to interact with Stern Pinball's
 * Insider API, enabling authenticated access to user machines and high scores.
 *
 * Environment Variables Required:
 * - STERN_USERNAME: Your Stern Insider account email
 * - STERN_PASSWORD: Your Stern Insider account password
 */

import axios from "axios";
import * as logger from "firebase-functions/logger";
import { defineString } from "firebase-functions/params";
import { HttpsError, onCall } from "firebase-functions/v2/https";

// --- Stern API Configuration ---
const sternUsername = defineString("STERN_USERNAME", {
    description: "Stern Insider account email",
});
const sternPassword = defineString("STERN_PASSWORD", {
    description: "Stern Insider account password",
});

// --- API Constants ---
const API_BASE_URL = "https://cms.prd.sternpinball.io/api/v1/portal";
const GAME_TEAMS_API_URL = "https://api.prd.sternpinball.io/api/v1/portal";
const AUTH_EXPIRY_TIME = 25 * 60 * 1000; // 25 minutes (slightly less than 30 for safety)

// --- Types ---
interface SternAuthData {
    token: string | null;
    cookies: string | null;
    lastAuthTime: number | null;
}

interface SternMachine {
    id: string;
    model: string;
    title?: string;
    image_url?: string;
    serial_number?: string;
    location_id?: string;
    tech_alerts?: any[];
    online?: boolean;
}

interface SternHighScore {
    id: string;
    player_name: string;
    score: number;
    rank?: number;
    initials?: string;
    avatar_url?: string;
    created_at?: string;
}

interface SternGameTeam {
    id: string;
    name: string;
    avatar_url?: string;
}

// --- Auth State (in-memory, refreshed as needed) ---
let authState: SternAuthData = {
    token: null,
    cookies: null,
    lastAuthTime: null,
};

/**
 * Authenticate with Stern Insider API
 */
async function authenticateWithStern(): Promise<boolean> {
    const username = sternUsername.value();
    const password = sternPassword.value();

    if (!username || !password) {
        logger.error("STERN_USERNAME and STERN_PASSWORD environment variables are required");
        return false;
    }

    try {
        logger.log("Attempting Stern Insider authentication...");

        // Send login data as JSON array like the browser does
        const loginData = [username, password];

        const loginResponse = await axios({
            method: "POST",
            url: "https://insider.sternpinball.com/login",
            headers: {
                "User-Agent": "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:142.0) Gecko/20100101 Firefox/142.0",
                "Accept": "text/x-component",
                "Accept-Language": "en-US,en;q=0.5",
                "Referer": "https://insider.sternpinball.com/login",
                "Next-Action": "9d2cf818afff9e2c69368771b521d93585a10433",
                "Next-Router-State-Tree": "%5B%22%22%2C%7B%22children%22%3A%5B%22login%22%2C%7B%22children%22%3A%5B%22__PAGE__%22%2C%7B%7D%2C%22%2Flogin%22%2C%22refresh%22%5D%7D%5D%7D%2Cnull%2Cnull%2Ctrue%5D",
                "Content-Type": "text/plain;charset=UTF-8",
                "Origin": "https://insider.sternpinball.com",
            },
            data: JSON.stringify(loginData),
            maxRedirects: 0,
            validateStatus: (status) => status < 400 || status === 302,
        });

        // Extract cookies and check for JWT token
        const setCookieHeader = loginResponse.headers["set-cookie"];
        let cookies = "";
        let token: string | null = null;

        if (setCookieHeader) {
            cookies = Array.isArray(setCookieHeader) ? setCookieHeader.join("; ") : setCookieHeader;
            const tokenMatch = cookies.match(/spb-insider-token=([^;]+)/);
            if (tokenMatch) {
                token = tokenMatch[1];
            }
        }

        // Parse the response to check authentication status
        let authenticationSuccessful = false;
        const responseText = typeof loginResponse.data === "string" ? loginResponse.data : JSON.stringify(loginResponse.data);

        try {
            const lines = responseText.split("\n");
            for (const line of lines) {
                if (line.includes("\"authenticated\"")) {
                    const jsonMatch = line.match(/\{.*\}/);
                    if (jsonMatch) {
                        const authResult = JSON.parse(jsonMatch[0]);
                        authenticationSuccessful = authResult.authenticated === true;
                        break;
                    }
                }
            }
        } catch {
            // Could not parse authentication result, continue with token check
        }

        if (loginResponse.status === 200 && (authenticationSuccessful || token)) {
            authState = {
                token,
                cookies,
                lastAuthTime: Date.now(),
            };
            logger.log("Stern Insider authentication successful");
            return true;
        } else {
            logger.error("Stern Insider authentication failed - status:", loginResponse.status);
            return false;
        }
    } catch (error: any) {
        logger.error("Stern authentication error:", error.message);
        return false;
    }
}

/**
 * Check if authentication is expired
 */
function isAuthExpired(): boolean {
    if (!authState.lastAuthTime) {
        return true;
    }
    return (Date.now() - authState.lastAuthTime) > AUTH_EXPIRY_TIME;
}

/**
 * Ensure we have valid authentication
 */
async function ensureAuthenticated(): Promise<void> {
    if (!authState.token || !authState.cookies || isAuthExpired()) {
        const success = await authenticateWithStern();
        if (!success) {
            throw new HttpsError("unauthenticated", "Failed to authenticate with Stern Insider");
        }
    }
}

/**
 * Create headers for Stern API requests
 */
function createHeaders(): Record<string, string> {
    const defaultLocation = JSON.stringify({
        country: "US",
        state: "CO",
        stateName: "Colorado",
        continent: "NA",
    });

    const headers: Record<string, string> = {
        "User-Agent": "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:142.0) Gecko/20100101 Firefox/142.0",
        "Accept": "application/json, text/plain, */*",
        "Accept-Language": "en-US,en;q=0.5",
        "Referer": "https://insider.sternpinball.com/",
        "Content-Type": "application/json",
        "Cache-Control": "max-age=604800, no-cache, no-store",
        "Origin": "https://insider.sternpinball.com",
        "Location": defaultLocation,
    };

    if (authState.cookies) {
        headers["Cookie"] = authState.cookies;
    }

    if (authState.token) {
        headers["Authorization"] = `Bearer ${authState.token}`;
    }

    return headers;
}

/**
 * Make an authenticated request to Stern API with retry logic
 */
async function makeAuthenticatedRequest<T>(url: string, retryCount = 0): Promise<T> {
    const MAX_RETRIES = 2;

    await ensureAuthenticated();

    try {
        const response = await axios.get(url, {
            headers: createHeaders(),
        });

        return response.data;
    } catch (error: any) {
        const status = error.response?.status;

        if ((status === 401 || status === 403) && retryCount < MAX_RETRIES) {
            logger.log(`Received ${status} error, attempting to refresh authentication (retry ${retryCount + 1}/${MAX_RETRIES})`);

            // Force re-authentication
            authState.lastAuthTime = null;
            const success = await authenticateWithStern();

            if (success) {
                return makeAuthenticatedRequest(url, retryCount + 1);
            }

            throw new HttpsError("unauthenticated", "Authentication expired and refresh failed");
        }

        logger.error("Stern API request failed:", error.message);
        throw new HttpsError("internal", `Stern API request failed: ${error.message}`);
    }
}

// ============================================================================
// Cloud Functions
// ============================================================================

/**
 * Get all registered Stern machines for the authenticated user
 */
export const getSternMachines = onCall(
    {
        cors: true,
        maxInstances: 10,
    },
    async (request) => {
        // Verify the user is authenticated with Firebase
        if (!request.auth) {
            throw new HttpsError("unauthenticated", "User must be authenticated");
        }

        try {
            logger.log(`Fetching Stern machines for Firebase user: ${request.auth.uid}`);

            const machinesUrl = `${API_BASE_URL}/user_registered_machines/?group_type=home`;
            const machinesData = await makeAuthenticatedRequest<any>(machinesUrl);
            const basicMachines: SternMachine[] = machinesData.user?.machines || [];

            // Fetch detailed information for each machine
            const detailedMachines = await Promise.allSettled(
                basicMachines.map(async (machine) => {
                    try {
                        const detailsUrl = `${API_BASE_URL}/game_machines/${machine.id}`;
                        const detailsData = await makeAuthenticatedRequest<any>(detailsUrl);

                        return {
                            ...machine,
                            ...detailsData,
                            model: machine.model || detailsData.model,
                        };
                    } catch (err: any) {
                        logger.error(`Failed to fetch details for machine ${machine.id}:`, err.message);
                        return machine;
                    }
                }),
            );

            const successfulMachines = detailedMachines
                .filter((result): result is PromiseFulfilledResult<SternMachine> => result.status === "fulfilled")
                .map((result) => result.value);

            logger.log(`Successfully fetched ${successfulMachines.length} Stern machines`);

            return {
                machines: successfulMachines,
                count: successfulMachines.length,
            };
        } catch (error: any) {
            logger.error("Error fetching Stern machines:", error);
            if (error instanceof HttpsError) {
                throw error;
            }
            throw new HttpsError("internal", `Failed to fetch machines: ${error.message}`);
        }
    },
);

/**
 * Get high scores for a specific Stern machine
 */
export const getSternHighScores = onCall(
    {
        cors: true,
        maxInstances: 10,
    },
    async (request) => {
        // Verify the user is authenticated with Firebase
        if (!request.auth) {
            throw new HttpsError("unauthenticated", "User must be authenticated");
        }

        const machineId = request.data?.machineId;
        if (!machineId) {
            throw new HttpsError("invalid-argument", "machineId is required");
        }

        try {
            logger.log(`Fetching high scores for machine: ${machineId}`);

            const url = `${API_BASE_URL}/game_machine_high_scores/?machine_id=${machineId}`;
            const highScoresData = await makeAuthenticatedRequest<any>(url);

            // Transform the data to a consistent format
            const highScores: SternHighScore[] = (highScoresData.high_scores || highScoresData || []).map((score: any, index: number) => ({
                id: score.id || `${machineId}_${index}`,
                player_name: score.player_name || score.name || score.initials || "Unknown",
                score: typeof score.score === "number" ? score.score : parseInt(score.score, 10) || 0,
                rank: score.rank || index + 1,
                initials: score.initials || score.player_name?.substring(0, 3)?.toUpperCase(),
                avatar_url: score.avatar_url || null,
                created_at: score.created_at || null,
            }));

            logger.log(`Successfully fetched ${highScores.length} high scores for machine ${machineId}`);

            return {
                machineId,
                highScores,
                count: highScores.length,
            };
        } catch (error: any) {
            logger.error("Error fetching high scores:", error);
            if (error instanceof HttpsError) {
                throw error;
            }
            throw new HttpsError("internal", `Failed to fetch high scores: ${error.message}`);
        }
    },
);

/**
 * Get game teams/avatars for a location
 */
export const getSternGameTeams = onCall(
    {
        cors: true,
        maxInstances: 10,
    },
    async (request) => {
        // Verify the user is authenticated with Firebase
        if (!request.auth) {
            throw new HttpsError("unauthenticated", "User must be authenticated");
        }

        const locationId = request.data?.locationId;
        if (!locationId) {
            throw new HttpsError("invalid-argument", "locationId is required");
        }

        try {
            logger.log(`Fetching game teams for location: ${locationId}`);

            const url = `${GAME_TEAMS_API_URL}/game_teams/?location_id=${locationId}`;
            const teamsData = await makeAuthenticatedRequest<any>(url);

            const teams: SternGameTeam[] = (teamsData.teams || teamsData || []).map((team: any) => ({
                id: team.id,
                name: team.name,
                avatar_url: team.avatar_url || null,
            }));

            logger.log(`Successfully fetched ${teams.length} game teams for location ${locationId}`);

            return {
                locationId,
                teams,
                count: teams.length,
            };
        } catch (error: any) {
            logger.error("Error fetching game teams:", error);
            if (error instanceof HttpsError) {
                throw error;
            }
            throw new HttpsError("internal", `Failed to fetch game teams: ${error.message}`);
        }
    },
);

/**
 * Get machine details including tech alerts
 */
export const getSternMachineDetails = onCall(
    {
        cors: true,
        maxInstances: 10,
    },
    async (request) => {
        // Verify the user is authenticated with Firebase
        if (!request.auth) {
            throw new HttpsError("unauthenticated", "User must be authenticated");
        }

        const machineId = request.data?.machineId;
        if (!machineId) {
            throw new HttpsError("invalid-argument", "machineId is required");
        }

        try {
            logger.log(`Fetching machine details for: ${machineId}`);

            const url = `${API_BASE_URL}/game_machines/${machineId}`;
            const machineDetails = await makeAuthenticatedRequest<SternMachine>(url);

            logger.log(`Successfully fetched details for machine ${machineId}`);

            return {
                machine: machineDetails,
            };
        } catch (error: any) {
            logger.error("Error fetching machine details:", error);
            if (error instanceof HttpsError) {
                throw error;
            }
            throw new HttpsError("internal", `Failed to fetch machine details: ${error.message}`);
        }
    },
);
