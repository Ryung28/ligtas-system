import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from 'npm:@supabase/supabase-js@2';
import { SignJWT, importPKCS8 } from "https://deno.land/x/jose@v4.14.4/index.ts";

/**
 * LIGTAS ENTERPRISE DISPATCHER (v2.0 - Enterprise Scale)
 * 🛡️ Anti-Gravity Protocol: Chunked Dispatch + Stale Token Purge
 */

// ============================================================================
// 🏗️ CENTRALIZED CONFIG — The Single Source of Truth
// Changing one value here updates all dispatch logic atomically.
// ============================================================================
const CONFIG = {
  CHANNEL_ID: 'emergency_coordination_v7',
  FCM_CHUNK_SIZE: 500,            // FCM v1 batch limit per project
  STALE_ERROR_CODES: new Set([
    'UNREGISTERED',               // App uninstalled
    'INVALID_ARGUMENT',           // Malformed token
  ]),
} as const;

// ── Type Definitions ──────────────────────────────────────────────────────────
interface ChatRecord {
  id: string;
  sender_id: string;
  receiver_id: string | null;
  content: string;
  room_id: string;
}

interface FcmResult {
  token: string;
  response: { error?: { status?: string; details?: string } };
}

// ── Helpers ───────────────────────────────────────────────────────────────────

/** Splits an array into chunks of a given size. */
function chunk<T>(arr: T[], size: number): T[][] {
  return Array.from({ length: Math.ceil(arr.length / size) }, (_, i) =>
    arr.slice(i * size, i * size + size)
  );
}

/** Returns true if the FCM error indicates a permanently stale token. */
function isStaleToken(result: FcmResult): boolean {
  const status = result.response?.error?.status ?? '';
  return CONFIG.STALE_ERROR_CODES.has(status);
}

// ── Main Handler ──────────────────────────────────────────────────────────────
Deno.serve(async (req: Request) => {
  try {
    const payload = await req.json();
    const payloadVersion = req.headers.get('X-Payload-Version') ?? '1';
    console.log(`[Push-Dispatcher] 📦 Payload Version: ${payloadVersion}`);

    // 🔒 STEP 1: Payload Lockdown
    const record: ChatRecord | undefined = payload.record;
    if (!record) {
      console.log('[Push-Dispatcher] 🛑 ABORT: Empty record payload.');
      return new Response('Empty payload', { status: 400 });
    }

    const message: ChatRecord = {
      id: record.id,
      sender_id: record.sender_id,
      receiver_id: record.receiver_id,
      content: record.content,
      room_id: record.room_id,
    };

    console.log('[Push-Dispatcher] 📡 Signal Detected:', message.id);

    // 🛡️ STEP 2: Initialize Supabase Admin Client
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    // 🛡️ STEP 3: Resolve Target Receivers (Omni-Directional Routing)
    let targetUserIds: string[] = [];

    console.log('[Push-Dispatcher] 🗺️ Mapping destination via Room:', message.room_id);
    const { data: room, error: roomError } = await supabase
      .from('chat_rooms')
      .select('borrower_user_id')
      .eq('id', message.room_id)
      .single();

    if (roomError || !room) {
      console.error('[Push-Dispatcher] 🛑 ABORT: Room not found.');
      return new Response('Room not found', { status: 404 });
    }

    if (message.sender_id === room.borrower_user_id) {
      // CITIZEN TALKING: Notify all Staff (Admins and Editors)
      console.log('[Push-Dispatcher] 👤 Citizen message detected. Routing to Staff...');
      const { data: staff } = await supabase
        .from('user_profiles')
        .select('id')
        .in('role', ['admin', 'editor']);
      
      if (staff) {
        targetUserIds = staff.map((s: { id: string }) => s.id);
      }
    } else {
      // STAFF TALKING: Notify the specific Borrower
      console.log('[Push-Dispatcher] 🏢 Staff message detected. Routing to Borrower...');
      targetUserIds = [room.borrower_user_id];
    }

    if (targetUserIds.length === 0) {
      console.log('[Safe-Abort] No targets identified. Terminating.');
      return new Response('No target identified', { status: 200 });
    }

    // 🛡️ STEP 4: Fetch Active Device Tokens for all targets
    const { data: tokenRows } = await supabase
      .from('user_fcm_tokens')
      .select('fcm_token')
      .in('user_id', targetUserIds);

    if (!tokenRows?.length) {
      console.log('[Push-Dispatcher] 📴 User offline. No registered devices.');
      return new Response('User offline', { status: 200 });
    }

    // 🛡️ STEP 5: Resolve Sender Name
    const { data: sender } = await supabase
      .from('user_profiles')
      .select('full_name')
      .eq('id', message.sender_id)
      .single();
    const senderName: string = sender?.full_name ?? 'LIGTAS Dispatch';

    // 🛡️ STEP 6: Generate FCM v1 Access Token
    const serviceAccountJson =
      Deno.env.get('SERVICE_ACCOUNT_JSON') ??
      Deno.env.get('FIREBASE_SERVICE_ACCOUNT_JSON');
    if (!serviceAccountJson) throw new Error('SERVICE_ACCOUNT_JSON binding missing');

    const serviceAccount = JSON.parse(serviceAccountJson);

    const jwt = await new SignJWT({ scope: 'https://www.googleapis.com/auth/cloud-platform' })
      .setProtectedHeader({ alg: 'RS256' })
      .setIssuedAt()
      .setIssuer(serviceAccount.client_email)
      .setAudience('https://oauth2.googleapis.com/token')
      .setExpirationTime('1h')
      .sign(await importPKCS8(serviceAccount.private_key, 'RS256'));

    const tokenResponse = await fetch('https://oauth2.googleapis.com/token', {
      method: 'POST',
      body: new URLSearchParams({
        grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        assertion: jwt,
      }),
    });

    const { access_token } = await tokenResponse.json();
    const projectId: string = serviceAccount.project_id;

    // 🛡️ STEP 7: Chunked Dispatch (FCM v1 — 500 tokens per batch)
    const allTokens: string[] = tokenRows.map((r: { fcm_token: string }) => r.fcm_token);
    const batches = chunk(allTokens, CONFIG.FCM_CHUNK_SIZE);
    const staleTokens: string[] = [];
    let totalDelivered = 0;

    for (const batch of batches) {
      const batchResults: FcmResult[] = await Promise.all(
        batch.map(async (fcmToken: string) => {
          const res = await fetch(
            `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
            {
              method: 'POST',
              headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${access_token}`,
              },
              body: JSON.stringify({
                message: {
                  token: fcmToken,
                  data: {
                    title: senderName,
                    body: message.content,
                    roomId: message.room_id,
                    type: 'CHAT',
                  },
                  android: {
                    priority: 'high', // 🛡️ HIGH PRIORITY: Bypasses power management
                    notification: {
                      channel_id: 'emergency_coordination_v7',
                      icon: 'ic_launcher',
                      tag: message.room_id, // 🛡️ COLLAPSE KEY: Ensures OS-level de-duplication
                      sound: 'critical_alarm',
                    },
                  },
                  apns: {
                    payload: {
                      aps: {
                        alert: { title: senderName, body: message.content },
                        sound: 'critical_alarm.mp3', // 🍎 APNS requires extension
                        'content-available': 1,
                      },
                    },
                  },
                },
              }),
            }
          );
          return { token: fcmToken, response: await res.json() };
        })
      );

      // 🧹 STALE TOKEN DETECTION
      for (const result of batchResults) {
        if (isStaleToken(result)) {
          staleTokens.push(result.token);
          console.log('[Push-Dispatcher] 🗑️ Stale token flagged:', result.token.slice(0, 20) + '...');
        } else {
          totalDelivered++;
        }
      }
    }

    // 🧹 STEP 8: Stale Token Purge (Self-Cleaning Registry)
    if (staleTokens.length > 0) {
      const { error: purgeError } = await supabase
        .from('user_fcm_tokens')
        .delete()
        .in('fcm_token', staleTokens);

      if (purgeError) {
        console.error('[Push-Dispatcher] ⚠️ Stale token purge failed:', purgeError.message);
      } else {
        console.log(`[Push-Dispatcher] 🧹 Purged ${staleTokens.length} stale token(s) from registry.`);
      }
    }

    console.log(`[Push-Dispatcher] 🚀 Mission Success: ${totalDelivered} delivered, ${staleTokens.length} purged.`);
    return new Response(
      JSON.stringify({ success: true, delivered: totalDelivered, purged: staleTokens.length }),
      { status: 200 }
    );

  } catch (error: unknown) {
    const msg = error instanceof Error ? error.message : String(error);
    console.error('[Fatal-Abort] Trace:', msg);
    return new Response(JSON.stringify({ error: msg }), { status: 500 });
  }
});
