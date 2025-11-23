import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { initializeApp, cert, ServiceAccount } from "npm:firebase-admin@^12.0.0/app";
import { getMessaging } from "npm:firebase-admin@^12.0.0/messaging";

// Initialize Firebase Admin (only once)
let firebaseApp: any = null;

function getFirebaseApp() {
  if (!firebaseApp) {
    try {
      const serviceAccountJson = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");
      
      if (!serviceAccountJson) {
        throw new Error("FIREBASE_SERVICE_ACCOUNT environment variable is not set");
      }

      const serviceAccount: ServiceAccount = JSON.parse(serviceAccountJson);
      
      firebaseApp = initializeApp({
        credential: cert(serviceAccount),
      });
      
      console.log("✅ Firebase Admin initialized successfully");
    } catch (error) {
      console.error("❌ Failed to initialize Firebase Admin:", error);
      throw error;
    }
  }
  return firebaseApp;
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization",
      },
    });
  }

  // Only allow POST requests
  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ success: false, error: "Method not allowed" }),
      { 
        status: 405, 
        headers: { 
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        } 
      }
    );
  }

  try {
    console.log("📩 Received push notification request");
    
    // Parse request body
    const body = await req.json();
    const { tokens, title, body: messageBody, data } = body;

    // Validate input
    if (!tokens || !Array.isArray(tokens) || tokens.length === 0) {
      throw new Error("Invalid or empty tokens array");
    }

    if (!title) {
      throw new Error("Title is required");
    }

    console.log(`📤 Sending notification to ${tokens.length} device(s)`);
    console.log(`📝 Title: ${title}`);
    console.log(`📝 Body: ${messageBody}`);

    // Get Firebase app
    getFirebaseApp();

    // Prepare the message
    const message = {
      notification: {
        title: title,
        body: messageBody || "",
      },
      data: data || {},
      tokens: tokens,
      // Android-specific config
      android: {
        priority: "high" as const,
        notification: {
          sound: "default",
          channelId: "monie_notifications",
        },
      },
      // iOS-specific config
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    };

    // Send the notification
    const response = await getMessaging().sendEachForMulticast(message);

    console.log(`✅ Successfully sent: ${response.successCount}`);
    console.log(`❌ Failed: ${response.failureCount}`);

    // Log failures for debugging
    if (response.failureCount > 0) {
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          console.error(`❌ Token ${idx} failed:`, resp.error?.message);
        }
      });
    }

    return new Response(
      JSON.stringify({
        success: true,
        successCount: response.successCount,
        failureCount: response.failureCount,
        responses: response.responses,
      }),
      {
        status: 200,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  } catch (error) {
    console.error("❌ Error sending push notification:", error);
    
    return new Response(
      JSON.stringify({
        success: false,
        error: error instanceof Error ? error.message : "Unknown error",
      }),
      {
        status: 500,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  }
});

console.log("🚀 Edge Function 'send-group-notification' is running");

