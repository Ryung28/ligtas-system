import { createSupabaseServer } from '@/lib/supabase-server'
import { createSignedLogbookExportEnvelope } from '@/src/features/admin-logbook-reset/backup-integrity'

export async function GET(req: Request) {
  try {
    const exportSigningSecret = process.env.LOGBOOK_BACKUP_SIGNING_SECRET
    if (!exportSigningSecret) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'Missing LOGBOOK_BACKUP_SIGNING_SECRET on server.',
        }),
        { status: 500, headers: { 'Content-Type': 'application/json' } },
      )
    }

    const url = new URL(req.url)
    const snapshotId = (url.searchParams.get('snapshotId') || '').trim()
    if (!snapshotId) {
      return new Response(
        JSON.stringify({ success: false, error: 'snapshotId is required.' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } },
      )
    }

    const supabase = await createSupabaseServer()
    const {
      data: { user },
      error: userError,
    } = await supabase.auth.getUser()

    if (userError || !user) {
      return new Response(
        JSON.stringify({ success: false, error: 'Unauthorized.' }),
        { status: 401, headers: { 'Content-Type': 'application/json' } },
      )
    }

    const { data: profile, error: profileError } = await supabase
      .from('user_profiles')
      .select('role')
      .eq('id', user.id)
      .maybeSingle()

    if (profileError || profile?.role !== 'admin') {
      return new Response(
        JSON.stringify({ success: false, error: 'Admin access required.' }),
        { status: 403, headers: { 'Content-Type': 'application/json' } },
      )
    }

    const { data, error } = await supabase.rpc(
      'admin_logbook_export_snapshot_v1',
      {
        p_requested_by: user.id,
        p_snapshot_id: snapshotId,
      },
    )

    if (error || !data) {
      const message = error?.message ?? 'Export RPC failed.'
      const status = message.toLowerCase().includes('not found') ? 404 : 500
      return new Response(
        JSON.stringify({ success: false, error: message }),
        { status, headers: { 'Content-Type': 'application/json' } },
      )
    }

    const envelope = createSignedLogbookExportEnvelope(data, exportSigningSecret)
    const payload = JSON.stringify(envelope)
    const createdAtRaw =
      typeof (data as any)?.snapshot?.created_at === 'string'
        ? (data as any).snapshot.created_at
        : null
    const createdAt = createdAtRaw ? new Date(createdAtRaw) : new Date()
    const pad = (value: number) => value.toString().padStart(2, '0')
    const timestamp = `${createdAt.getFullYear()}${pad(createdAt.getMonth() + 1)}${pad(createdAt.getDate())}-${pad(createdAt.getHours())}${pad(createdAt.getMinutes())}`
    const filename = `backup-logbook-${timestamp}.json`

    return new Response(payload, {
      status: 200,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Content-Disposition': `attachment; filename="${filename}"`,
        'Cache-Control': 'no-store',
      },
    })
  } catch {
    return new Response(
      JSON.stringify({ success: false, error: 'Invalid request.' }),
      { status: 400, headers: { 'Content-Type': 'application/json' } },
    )
  }
}
