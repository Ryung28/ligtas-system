import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from 'npm:@supabase/supabase-js@2';
import { SignJWT, importPKCS8 } from "https://deno.land/x/jose@v4.14.4/index.ts";

/**
 * 🛡️ ResQTrack ENTERPRISE DISPATCHER (v3.1 - Role Convergence Fix)
 * 🏗️ Senior Architect Protocols:
 * - Aggressive Simplification: Removed Vault/pg_net complexity.
 * - Anti-Fragility: Uses Supabase Native Webhook engine.
 * - Omni-Directional: Fixed 'staff' and 'viewer' role routing.
 */

const CONFIG = {
  CHANNEL_ID: 'emergency_coordination_v7', // 🛰️ MANDATORY V7 CHANNEL
  STALE_ERROR_CODES: new Set(['UNREGISTERED']), // 🛡️ GENTLE PURGE
} as const;

interface ChatRecord {
  id: string;
  sender_id: string;
  content: string;
  room_id: string;
}

Deno.serve(async (req: Request) => {
  try {
    const payload = await req.json();
    
    // 📦 STEP 1: Extract Native Payload
    const record: ChatRecord | undefined = payload.record;
    if (!record) {
      console.log('[Push-Dispatcher] 🛑 ABORT: No record found in payload.');
      return new Response('Empty record', { status: 400 });
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    // 🗺️ STEP 2: Resolve Target Receivers (Staff vs Citizen)
    let targetUserIds: string[] = [];

    const { data: room, error: roomError } = await supabase
      .from('chat_rooms')
      .select('borrower_user_id')
      .eq('id', record.room_id)
      .single();

    if (roomError || !room) {
      console.error('[Push-Dispatcher] 🛑 ABORT: Room not found.');
      return new Response('Room not found', { status: 404 });
    }

    if (record.sender_id === room.borrower_user_id) {
      // 👤 CITIZEN -> STAFF: Fix the 'staff' role bug
      // Including ALL possible staff-level roles to ensure coverage.
      console.log('[Push-Dispatcher] 👤 Citizen message detected. Routing to Staff...');
      const { data: staff } = await supabase
        .from('user_profiles')
        .select('id')
        .in('role', ['admin', 'staff', 'editor', 'viewer']);
      
      targetUserIds = staff?.map((s) => s.id) ?? [];
    } else {
      // 🏢 STAFF -> CITIZEN: Route to specific Borrower
      console.log('[Push-Dispatcher] 🏢 Staff message detected. Routing to Borrower...');
      targetUserIds = [room.borrower_user_id];
    }

    if (targetUserIds.length === 0) {
      console.log('[Safe-Abort] No targets identified.');
      return new Response('No targets identified', { status: 200 });
    }

    // 🛡️ STEP 3: Fetch Active Device Tokens
    const { data: tokenRows } = await supabase
      .from('user_fcm_tokens')
      .select('fcm_token')
      .in('user_id', targetUserIds);

    if (!tokenRows?.length) {
      console.log('[Push-Dispatcher] 📴 Targets offline. No registered tokens.');
      return new Response('User offline', { status: 200 });
    }

    // 🛡️ STEP 4: FCM v1 Authentication (Service Account Secret)
    const serviceAccountJson = Deno.env.get('SERVICE_ACCOUNT_JSON');
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

    // 🛡️ Resolve Sender Name
    const { data: sender } = await supabase.from('user_profiles').select('full_name').eq('id', record.sender_id).single();
    const senderName = sender?.full_name ?? 'ResQTrack Dispatch';

    // 🚀 STEP 5: Parallel High-Priority Dispatch
    const staleTokens: string[] = [];
    let deliveredCount = 0;

    const results = await Promise.all(
      tokenRows.map(async (row) => {
        const fcmToken = row.fcm_token;
        const res = await fetch(`https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`, {
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
                body: record.content,
                roomId: record.room_id,
                type: 'CHAT',
              },
              android: {
                priority: 'high',
                notification: {
                  channel_id: CONFIG.CHANNEL_ID,
                  icon: 'ic_launcher',
                  tag: record.room_id,
                  sound: 'critical_alarm',
                },
              },
              apns: {
                payload: {
                  aps: {
                    alert: { title: senderName, body: record.content },
                    sound: 'critical_alarm.mp3',
                    'content-available': 1,
                  },
                },
              },
            },
          }),
        });

        const result = await res.json();
        if (res.ok) {
          deliveredCount++;
        } else if (result.error?.status === 'UNREGISTERED') {
          staleTokens.push(fcmToken);
        }
        return res.ok;
      })
    );

    // 🧹 STEP 6: Self-Cleaning (Gentle Purge)
    if (staleTokens.length > 0) {
      await supabase.from('user_fcm_tokens').delete().in('fcm_token', staleTokens);
      console.log(`[Push-Dispatcher] 🧹 Purged ${staleTokens.length} stale tokens.`);
    }

    console.log(`[Push-Dispatcher] 🚀 Delivered: ${deliveredCount}, Purged: ${staleTokens.length}`);
    return new Response(JSON.stringify({ success: true, delivered: deliveredCount }), { status: 200 });

  } catch (error) {
    const msg = error instanceof Error ? error.message : String(error);
    console.error('[Fatal-Abort] Trace:', msg);
    return new Response(JSON.stringify({ error: msg }), { status: 500 });
  }
});
