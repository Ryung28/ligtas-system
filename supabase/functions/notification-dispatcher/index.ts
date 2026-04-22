import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";
import { SignJWT, importPKCS8 } from "https://deno.land/x/jose@v4.14.4/index.ts";

type Json = Record<string, unknown>;

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

const MAX_EVENTS_PER_RUN = 25;
const RETRYABLE_STATUSES = new Set([
  "INTERNAL",
  "UNAVAILABLE",
  "RESOURCE_EXHAUSTED",
  "DEADLINE_EXCEEDED",
  "UNKNOWN",
]);
const PERMANENT_STATUSES = new Set([
  "UNREGISTERED",
  "INVALID_ARGUMENT",
  "MISMATCH_SENDER_ID",
  // FCM can return NOT_FOUND for stale/non-existent token entities.
  "NOT_FOUND",
]);

interface NotificationEventRow {
  id: string;
  event_type: string;
  audience: Json;
  payload: Json;
  attempt_count: number;
}

interface TokenRow {
  id: string;
  user_id: string;
  fcm_token: string;
}

function isUuid(value: string): boolean {
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(value);
}

function normalizeAndroidPriority(value: string): "HIGH" | "NORMAL" {
  return value.toLowerCase() === "high" ? "HIGH" : "NORMAL";
}

function computeBackoffSeconds(attemptCount: number): number {
  // 30s, 2m, 10m, 30m, 2h (bounded)
  const schedule = [30, 120, 600, 1800, 7200];
  return schedule[Math.min(attemptCount, schedule.length - 1)];
}

async function getAccessToken(serviceAccountJson: string): Promise<{ accessToken: string; projectId: string }> {
  const sa = JSON.parse(serviceAccountJson);
  const jwt = await new SignJWT({ scope: "https://www.googleapis.com/auth/cloud-platform" })
    .setProtectedHeader({ alg: "RS256" })
    .setIssuedAt()
    .setIssuer(sa.client_email)
    .setAudience("https://oauth2.googleapis.com/token")
    .setExpirationTime("1h")
    .sign(await importPKCS8(sa.private_key, "RS256"));

  const tokenResponse = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });

  if (!tokenResponse.ok) {
    throw new Error(`Failed to fetch OAuth token (${tokenResponse.status})`);
  }

  const tokenData = await tokenResponse.json();
  return { accessToken: tokenData.access_token, projectId: sa.project_id };
}

async function fetchPendingEvents(supabase: ReturnType<typeof createClient>): Promise<NotificationEventRow[]> {
  const { data, error } = await supabase
    .from("notification_events")
    .select("id,event_type,audience,payload,attempt_count")
    .eq("status", "pending")
    .lte("next_attempt_at", new Date().toISOString())
    .order("created_at", { ascending: true })
    .limit(MAX_EVENTS_PER_RUN);

  if (error) throw error;
  return (data ?? []) as NotificationEventRow[];
}

async function resolveTargets(
  supabase: ReturnType<typeof createClient>,
  audience: Json,
): Promise<TokenRow[]> {
  const explicitUserIds = (audience["user_ids"] as string[] | undefined) ?? [];
  const validUserIds = explicitUserIds.filter((id) => typeof id === "string" && isUuid(id));
  if (validUserIds.length === 0) return [];

  const { data, error } = await supabase
    .from("user_fcm_tokens")
    .select("id,user_id,fcm_token")
    .in("user_id", validUserIds)
    .is("invalidated_at", null);

  if (error) throw error;
  return (data ?? []) as TokenRow[];
}

function classifySendResult(fcmResponse: Json): "success" | "retryable_failure" | "permanent_failure" {
  const status = (fcmResponse?.error as Json | undefined)?.status as string | undefined;
  if (!status) return "success";
  if (PERMANENT_STATUSES.has(status)) return "permanent_failure";
  if (RETRYABLE_STATUSES.has(status)) return "retryable_failure";
  return "retryable_failure";
}

Deno.serve(async () => {
  try {
    if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
      throw new Error("Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY");
    }

    const serviceAccountJson = Deno.env.get("SERVICE_ACCOUNT_JSON");
    if (!serviceAccountJson) {
      return new Response(JSON.stringify({ error: "SERVICE_ACCOUNT_JSON missing" }), { status: 500 });
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
    const { accessToken, projectId } = await getAccessToken(serviceAccountJson);

    const events = await fetchPendingEvents(supabase);
    const summary: Json[] = [];

    for (const event of events) {
      const targets = await resolveTargets(supabase, event.audience);

      if (targets.length === 0) {
        await supabase
          .from("notification_events")
          .update({ status: "failed", updated_at: new Date().toISOString() })
          .eq("id", event.id);
        summary.push({ eventId: event.id, status: "failed", reason: "no-targets" });
        continue;
      }

      const title = String(event.payload["title"] ?? "ResQTrack Alert");
      const body = String(event.payload["body"] ?? "Check your dashboard for updates.");
      const path = String(event.payload["path"] ?? "/dashboard");
      const androidChannelId = String(event.payload["channel_id"] ?? "emergency_coordination_v7");
      const sound = String(event.payload["sound"] ?? "critical_alarm");
      const priority = normalizeAndroidPriority(String(event.payload["priority"] ?? "high"));
      const ttlSeconds = Number(event.payload["ttl_seconds"] ?? 300);
      const collapseId = String(event.payload["collapse_id"] ?? `${event.event_type}:${event.id}`);

      let successCount = 0;
      let retryableCount = 0;
      const staleTokenIds: string[] = [];

      for (const token of targets) {
        const start = Date.now();
        const response = await fetch(`https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${accessToken}`,
          },
          body: JSON.stringify({
            message: {
              token: token.fcm_token,
              data: {
                title,
                body,
                path,
                eventType: event.event_type,
              },
              android: {
                priority,
                ttl: `${Math.max(30, ttlSeconds)}s`,
                collapse_key: collapseId,
                notification: {
                  channel_id: androidChannelId,
                  sound,
                  tag: collapseId,
                },
              },
              apns: {
                headers: {
                  "apns-collapse-id": collapseId,
                  "apns-priority": priority === "HIGH" ? "10" : "5",
                  "apns-expiration": `${Math.floor(Date.now() / 1000) + Math.max(30, ttlSeconds)}`,
                },
                payload: {
                  aps: {
                    alert: { title, body },
                    sound: `${sound}.mp3`,
                    "content-available": 1,
                  },
                },
              },
            },
          }),
        });

        const payload = (await response.json()) as Json;
        const result = response.ok ? "success" : classifySendResult(payload);
        const errorStatus = (payload?.error as Json | undefined)?.status as string | undefined;
        const errorMessage = (payload?.error as Json | undefined)?.message as string | undefined;
        const providerMessageId = response.ok ? String(payload["name"] ?? "") : null;

        if (result === "success") successCount++;
        if (result === "retryable_failure") retryableCount++;
        if (result === "permanent_failure" && errorStatus && PERMANENT_STATUSES.has(errorStatus)) {
          staleTokenIds.push(token.id);
        }

        await supabase.from("notification_deliveries").insert({
          event_id: event.id,
          user_id: token.user_id,
          token_id: token.id,
          provider: "fcm",
          provider_message_id: providerMessageId,
          attempt_no: event.attempt_count + 1,
          result,
          error_code: errorStatus,
          error_message: errorMessage,
          latency_ms: Date.now() - start,
        });
      }

      if (staleTokenIds.length > 0) {
        await supabase
          .from("user_fcm_tokens")
          .update({
            invalidated_at: new Date().toISOString(),
            invalid_reason: "provider_permanent_failure",
          })
          .in("id", staleTokenIds);
      }

      if (retryableCount > 0) {
        const nextAttempt = new Date(Date.now() + computeBackoffSeconds(event.attempt_count) * 1000).toISOString();
        await supabase
          .from("notification_events")
          .update({
            status: successCount > 0 ? "partial" : "pending",
            attempt_count: event.attempt_count + 1,
            next_attempt_at: nextAttempt,
            updated_at: new Date().toISOString(),
          })
          .eq("id", event.id);
        summary.push({ eventId: event.id, status: successCount > 0 ? "partial" : "pending", successCount, retryableCount });
      } else {
        await supabase
          .from("notification_events")
          .update({
            status: successCount > 0 ? "sent" : "failed",
            attempt_count: event.attempt_count + 1,
            updated_at: new Date().toISOString(),
          })
          .eq("id", event.id);
        summary.push({ eventId: event.id, status: successCount > 0 ? "sent" : "failed", successCount });
      }
    }

    return new Response(JSON.stringify({ processed: events.length, summary }), {
      headers: { "Content-Type": "application/json" },
      status: 200,
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    return new Response(JSON.stringify({ error: "dispatcher_failed", detail: message }), {
      headers: { "Content-Type": "application/json" },
      status: 500,
    });
  }
});
