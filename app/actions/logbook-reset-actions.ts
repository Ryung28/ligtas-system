'use server'

import { createSupabaseServer } from '@/lib/supabase-server'
import {
  RESET_CONFIRMATION_PHRASE,
  BACKUP_CONFIRMATION_PHRASE,
  IMPORT_CONFIRMATION_PHRASE,
  RESTORE_CONFIRMATION_PHRASE,
  RESET_SCOPE_VERSION,
} from '@/src/features/admin-logbook-reset/reset-scope'
import {
  getMaxBackupImportBytes,
  parseAndValidateImportPayload,
} from '@/src/features/admin-logbook-reset/backup-integrity'
import type { LogbookResetResult } from '@/src/features/admin-logbook-reset/types'

interface ExecuteResetInput {
  confirmation: string
  reason: string
}

interface ImportSnapshotInput {
  confirmation: string
  reason: string
  payload: unknown
}

interface PruneSnapshotsInput {
  keepLatest?: number
  keepDays?: number
}

const BACKUP_FRESHNESS_HOURS = 24

export interface LogbookAdminStatus {
  backup: {
    id: string | null
    status: string | null
    created_at: string | null
    completed_at: string | null
    snapshot_id: string | null
  }
  reset: {
    id: string | null
    status: string | null
    created_at: string | null
    completed_at: string | null
    snapshot_id: string | null
  }
  restore: {
    id: string | null
    status: string | null
    created_at: string | null
    completed_at: string | null
    snapshot_id: string | null
  }
}

function isAdminRole(role: unknown): boolean {
  return role === 'admin'
}

function toFriendlyRestoreError(message: string): string {
  const lowered = message.toLowerCase()
  if (lowered.includes('duplicate key value')) {
    return `Restore failed due to duplicate-key collisions in snapshot data. DB says: ${message.slice(
      0,
      240,
    )}`
  }
  if (lowered.includes('scope version mismatch')) {
    return 'This snapshot is from a different app version and cannot be restored here.'
  }
  return `Restore failed. DB says: ${message.slice(0, 240)}`
}

export async function executeLogbookResetAction(
  input: ExecuteResetInput,
): Promise<LogbookResetResult> {
  if (input.confirmation !== RESET_CONFIRMATION_PHRASE) {
    return {
      success: false,
      error: 'Confirmation text does not match.',
      errorCode: 'VALIDATION',
    }
  }

  const reason = input.reason.trim()
  if (reason.length < 10) {
    return {
      success: false,
      error: 'Please add a short reason (at least 10 characters).',
      errorCode: 'VALIDATION',
    }
  }

  const supabase = await createSupabaseServer()
  const {
    data: { user },
    error: userError,
  } = await supabase.auth.getUser()

  if (userError || !user) {
    return { success: false, error: 'Unauthorized.', errorCode: 'UNAUTHORIZED' }
  }

  const { data: profile, error: profileError } = await supabase
    .from('user_profiles')
    .select('role')
    .eq('id', user.id)
    .maybeSingle()

  if (profileError || !isAdminRole(profile?.role)) {
    return { success: false, error: 'Admin access required.', errorCode: 'FORBIDDEN' }
  }

  const { data: latestBackup, error: backupGuardError } = await supabase
    .from('backup_jobs')
    .select('id,status,created_at')
    .eq('status', 'completed')
    .order('created_at', { ascending: false })
    .limit(1)
    .maybeSingle()

  if (backupGuardError) {
    return {
      success: false,
      error: 'Unable to verify your latest recovery snapshot.',
      errorCode: 'INTERNAL',
    }
  }

  if (!latestBackup?.id) {
    return {
      success: false,
      error: 'Clear Logbook is blocked. Create a completed recovery snapshot first.',
      errorCode: 'PRECONDITION',
    }
  }

  if (latestBackup.created_at) {
    const latestBackupAt = new Date(latestBackup.created_at).getTime()
    const freshnessWindowMs = BACKUP_FRESHNESS_HOURS * 60 * 60 * 1000
    if (Date.now() - latestBackupAt > freshnessWindowMs) {
      return {
        success: false,
        error: `Clear Logbook is blocked. Your latest recovery snapshot is older than ${BACKUP_FRESHNESS_HOURS} hours.`,
        errorCode: 'PRECONDITION',
      }
    }
  }

  const { data, error } = await supabase.rpc('admin_logbook_reset_v1', {
    p_requested_by: user.id,
    p_reason: reason,
    p_scope_version: RESET_SCOPE_VERSION,
  })

  if (error || !data) {
    const message = error?.message ?? 'Clear logbook failed.'
    const lowered = message.toLowerCase()
    const isConflict =
      lowered.includes('already running') || lowered.includes('another logbook')
    return {
      success: false,
      error: message,
      errorCode: isConflict ? 'CONFLICT' : 'INTERNAL',
    }
  }

  const row = Array.isArray(data) ? data[0] : data
  return {
    success: true,
    jobId: row.job_id,
    snapshotId: row.snapshot_id,
  }
}

export async function createLogbookBackupAction(
  input: ExecuteResetInput,
): Promise<LogbookResetResult> {
  if (input.confirmation !== BACKUP_CONFIRMATION_PHRASE) {
    return {
      success: false,
      error: 'Confirmation text does not match.',
      errorCode: 'VALIDATION',
    }
  }

  const reason = input.reason.trim()
  if (reason.length < 10) {
    return {
      success: false,
      error: 'Please add a short reason (at least 10 characters).',
      errorCode: 'VALIDATION',
    }
  }

  const supabase = await createSupabaseServer()
  const {
    data: { user },
    error: userError,
  } = await supabase.auth.getUser()

  if (userError || !user) {
    return { success: false, error: 'Unauthorized.', errorCode: 'UNAUTHORIZED' }
  }

  const { data: profile, error: profileError } = await supabase
    .from('user_profiles')
    .select('role')
    .eq('id', user.id)
    .maybeSingle()

  if (profileError || !isAdminRole(profile?.role)) {
    return { success: false, error: 'Admin access required.', errorCode: 'FORBIDDEN' }
  }

  const { data, error } = await supabase.rpc('admin_logbook_backup_v1', {
    p_requested_by: user.id,
    p_reason: reason,
    p_scope_version: RESET_SCOPE_VERSION,
  })

  if (error || !data) {
    const message = error?.message ?? 'Create recovery snapshot failed.'
    const lowered = message.toLowerCase()
    const isConflict =
      lowered.includes('already running') || lowered.includes('another logbook')
    return {
      success: false,
      error: message,
      errorCode: isConflict ? 'CONFLICT' : 'INTERNAL',
    }
  }

  const row = Array.isArray(data) ? data[0] : data
  return {
    success: true,
    jobId: row.job_id,
    snapshotId: row.snapshot_id,
  }
}

export async function getLogbookAdminStatusAction(): Promise<{
  success: boolean
  data?: LogbookAdminStatus
  error?: string
}> {
  const supabase = await createSupabaseServer()
  const {
    data: { user },
    error: userError,
  } = await supabase.auth.getUser()

  if (userError || !user) {
    return { success: false, error: 'Unauthorized.' }
  }

  const { data: profile, error: profileError } = await supabase
    .from('user_profiles')
    .select('role')
    .eq('id', user.id)
    .maybeSingle()

  if (profileError || !isAdminRole(profile?.role)) {
    return { success: false, error: 'Admin access required.' }
  }

  const [
    { data: backup, error: backupError },
    { data: reset, error: resetError },
    { data: restore, error: restoreError },
  ] =
    await Promise.all([
      supabase
        .from('backup_jobs')
        .select('id,status,created_at,completed_at,snapshot_id')
        .order('created_at', { ascending: false })
        .limit(1)
        .maybeSingle(),
      supabase
        .from('reset_jobs')
        .select('id,status,created_at,completed_at,snapshot_id')
        .order('created_at', { ascending: false })
        .limit(1)
        .maybeSingle(),
      supabase
        .from('restore_jobs')
        .select('id,status,created_at,completed_at,snapshot_id')
        .order('created_at', { ascending: false })
        .limit(1)
        .maybeSingle(),
    ])

  if (backupError || resetError || restoreError) {
    return {
      success: false,
      error:
        backupError?.message ||
        resetError?.message ||
        restoreError?.message ||
        'Failed to load logbook status.',
    }
  }

  return {
    success: true,
    data: {
      backup: {
        id: backup?.id ?? null,
        status: backup?.status ?? null,
        created_at: backup?.created_at ?? null,
        completed_at: backup?.completed_at ?? null,
        snapshot_id: backup?.snapshot_id ?? null,
      },
      reset: {
        id: reset?.id ?? null,
        status: reset?.status ?? null,
        created_at: reset?.created_at ?? null,
        completed_at: reset?.completed_at ?? null,
        snapshot_id: reset?.snapshot_id ?? null,
      },
      restore: {
        id: restore?.id ?? null,
        status: restore?.status ?? null,
        created_at: restore?.created_at ?? null,
        completed_at: restore?.completed_at ?? null,
        snapshot_id: restore?.snapshot_id ?? null,
      },
    },
  }
}

export async function createLogbookRestoreAction(input: {
  confirmation: string
  reason: string
  snapshotId: string
}): Promise<LogbookResetResult> {
  if (input.confirmation !== RESTORE_CONFIRMATION_PHRASE) {
    return {
      success: false,
      error: 'Confirmation text does not match.',
      errorCode: 'VALIDATION',
    }
  }

  const reason = input.reason.trim()
  if (reason.length < 10) {
    return {
      success: false,
      error: 'Please add a short reason (at least 10 characters).',
      errorCode: 'VALIDATION',
    }
  }

  const snapshotId = input.snapshotId.trim()
  if (!snapshotId) {
    return {
      success: false,
      error: 'Snapshot ID is required.',
      errorCode: 'VALIDATION',
    }
  }

  const supabase = await createSupabaseServer()
  const {
    data: { user },
    error: userError,
  } = await supabase.auth.getUser()

  if (userError || !user) {
    return { success: false, error: 'Unauthorized.', errorCode: 'UNAUTHORIZED' }
  }

  const { data: profile, error: profileError } = await supabase
    .from('user_profiles')
    .select('role')
    .eq('id', user.id)
    .maybeSingle()

  if (profileError || !isAdminRole(profile?.role)) {
    return { success: false, error: 'Admin access required.', errorCode: 'FORBIDDEN' }
  }

  const { data: previewRows, error: previewError } = await supabase.rpc(
    'admin_logbook_snapshot_preview_v1',
    {
      p_requested_by: user.id,
      p_snapshot_id: snapshotId,
    },
  )

  if (previewError) {
    return {
      success: false,
      error: previewError.message,
      errorCode: 'INTERNAL',
    }
  }

  const preview = (previewRows as Array<{ scope_version: string }>) || []
  const snapshotScopeVersion = preview[0]?.scope_version

  if (!snapshotScopeVersion) {
    return {
      success: false,
      error: 'Snapshot not found.',
      errorCode: 'VALIDATION',
    }
  }

  if (snapshotScopeVersion !== RESET_SCOPE_VERSION) {
    return {
      success: false,
      error: `This snapshot cannot be restored here (scope mismatch: ${snapshotScopeVersion} vs ${RESET_SCOPE_VERSION}).`,
      errorCode: 'PRECONDITION',
    }
  }

  const { data, error } = await supabase.rpc('admin_logbook_restore_v1', {
    p_requested_by: user.id,
    p_snapshot_id: snapshotId,
    p_reason: reason,
    p_scope_version: RESET_SCOPE_VERSION,
  })

  if (error || !data) {
    const message = error?.message ?? 'Restore failed.'
    const lowered = message.toLowerCase()
    const isConflict =
      lowered.includes('already running') || lowered.includes('another logbook')
    return {
      success: false,
      error: toFriendlyRestoreError(message),
      errorCode: isConflict ? 'CONFLICT' : 'INTERNAL',
    }
  }

  const row = Array.isArray(data) ? data[0] : data
  return {
    success: true,
    jobId: row.job_id,
    snapshotId: row.snapshot_id,
  }
}

export async function createLogbookImportAction(
  input: ImportSnapshotInput,
): Promise<LogbookResetResult> {
  if (input.confirmation !== IMPORT_CONFIRMATION_PHRASE) {
    return {
      success: false,
      error: 'Invalid confirmation phrase.',
      errorCode: 'VALIDATION',
    }
  }

  const reason = input.reason.trim()
  if (reason.length < 10) {
    return {
      success: false,
      error: 'Please provide a more detailed reason.',
      errorCode: 'VALIDATION',
    }
  }

  if (!input.payload || typeof input.payload !== 'object') {
    return {
      success: false,
      error: 'Invalid backup payload.',
      errorCode: 'VALIDATION',
    }
  }

  const importSigningSecret = process.env.LOGBOOK_BACKUP_SIGNING_SECRET
  if (!importSigningSecret) {
    return {
      success: false,
      error: 'Missing LOGBOOK_BACKUP_SIGNING_SECRET on server.',
      errorCode: 'INTERNAL',
    }
  }

  const serializedPayload = JSON.stringify(input.payload)
  if (Buffer.byteLength(serializedPayload, 'utf8') > getMaxBackupImportBytes()) {
    return {
      success: false,
      error: `Backup payload exceeds ${getMaxBackupImportBytes()} bytes limit.`,
      errorCode: 'VALIDATION',
    }
  }

  let normalizedPayload: unknown
  try {
    normalizedPayload = parseAndValidateImportPayload(input.payload, importSigningSecret)
  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Invalid backup payload.',
      errorCode: 'PRECONDITION',
    }
  }

  const supabase = await createSupabaseServer()
  const {
    data: { user },
    error: userError,
  } = await supabase.auth.getUser()

  if (userError || !user) {
    return { success: false, error: 'Unauthorized.', errorCode: 'UNAUTHORIZED' }
  }

  const { data: profile, error: profileError } = await supabase
    .from('user_profiles')
    .select('role')
    .eq('id', user.id)
    .maybeSingle()

  if (profileError || !isAdminRole(profile?.role)) {
    return { success: false, error: 'Admin access required.', errorCode: 'FORBIDDEN' }
  }

  const { data, error } = await supabase.rpc('admin_logbook_import_snapshot_v1', {
    p_requested_by: user.id,
    p_payload: normalizedPayload,
    p_scope_version: RESET_SCOPE_VERSION,
    p_reason: reason,
  })

  if (error || !data) {
    const message = error?.message ?? 'Import RPC failed.'
    const lowered = message.toLowerCase()
    const isConflict =
      lowered.includes('already running') || lowered.includes('another logbook')
    const isPrecondition =
      lowered.includes('scope version mismatch') ||
      lowered.includes('unsupported export schema version') ||
      lowered.includes('backup checksum mismatch') ||
      lowered.includes('backup signature verification failed') ||
      lowered.includes('legacy unsigned exports are no longer accepted')
    return {
      success: false,
      error: message,
      errorCode: isConflict ? 'CONFLICT' : isPrecondition ? 'PRECONDITION' : 'INTERNAL',
    }
  }

  const snapshotId = typeof data === 'string' ? data : String(data)
  return {
    success: true,
    snapshotId,
  }
}

export async function getLogbookSnapshotPreviewAction(input: {
  snapshotId: string
}): Promise<{
  success: boolean
  data?: {
    snapshot_id: string
    created_at: string
    requested_by: string
    reason: string
    scope_version: string
    table_counts: Array<{ table_name: string; row_count: number }>
  }
  error?: string
  errorCode?: 'UNAUTHORIZED' | 'FORBIDDEN' | 'VALIDATION' | 'INTERNAL'
}> {
  const snapshotId = input.snapshotId.trim()
  if (!snapshotId) {
    return {
      success: false,
      error: 'Snapshot ID is required.',
      errorCode: 'VALIDATION',
    }
  }

  const supabase = await createSupabaseServer()
  const {
    data: { user },
    error: userError,
  } = await supabase.auth.getUser()

  if (userError || !user) {
    return { success: false, error: 'Unauthorized.', errorCode: 'UNAUTHORIZED' }
  }

  const { data: profile, error: profileError } = await supabase
    .from('user_profiles')
    .select('role')
    .eq('id', user.id)
    .maybeSingle()

  if (profileError || !isAdminRole(profile?.role)) {
    return { success: false, error: 'Admin access required.', errorCode: 'FORBIDDEN' }
  }

  const { data: rows, error: previewError } = await supabase.rpc(
    'admin_logbook_snapshot_preview_v1',
    {
      p_requested_by: user.id,
      p_snapshot_id: snapshotId,
    },
  )

  if (previewError) {
    return {
      success: false,
      error: previewError.message,
      errorCode: 'INTERNAL',
    }
  }

  const previewRows = (rows as Array<{
    snapshot_id: string
    created_at: string
    requested_by: string
    reason: string
    scope_version: string
    table_name: string
    row_count: number
  }>) || []

  if (previewRows.length === 0) {
    return {
      success: false,
      error: 'Snapshot not found.',
      errorCode: 'VALIDATION',
    }
  }

  const first = previewRows[0]

  return {
    success: true,
    data: {
      snapshot_id: first.snapshot_id,
      created_at: first.created_at,
      requested_by: first.requested_by,
      reason: first.reason,
      scope_version: first.scope_version,
      table_counts: previewRows
        .map((row) => ({ table_name: row.table_name, row_count: Number(row.row_count) }))
        .sort((a, b) => a.table_name.localeCompare(b.table_name)),
    },
  }
}

export async function createLogbookPruneAction(
  input: PruneSnapshotsInput = {},
): Promise<{
  success: boolean
  deletedSnapshots?: number
  deletedRows?: number
  error?: string
  errorCode?: 'UNAUTHORIZED' | 'FORBIDDEN' | 'VALIDATION' | 'INTERNAL'
}> {
  const keepLatest = Number.isFinite(input.keepLatest) ? Number(input.keepLatest) : 100
  const keepDays = Number.isFinite(input.keepDays) ? Number(input.keepDays) : 180

  if (keepLatest < 1 || keepDays < 1) {
    return {
      success: false,
      error: 'keepLatest and keepDays must be >= 1.',
      errorCode: 'VALIDATION',
    }
  }

  const supabase = await createSupabaseServer()
  const {
    data: { user },
    error: userError,
  } = await supabase.auth.getUser()

  if (userError || !user) {
    return { success: false, error: 'Unauthorized.', errorCode: 'UNAUTHORIZED' }
  }

  const { data: profile, error: profileError } = await supabase
    .from('user_profiles')
    .select('role')
    .eq('id', user.id)
    .maybeSingle()

  if (profileError || !isAdminRole(profile?.role)) {
    return { success: false, error: 'Admin access required.', errorCode: 'FORBIDDEN' }
  }

  const { data, error } = await supabase.rpc('admin_logbook_prune_snapshots_v1', {
    p_requested_by: user.id,
    p_keep_latest: keepLatest,
    p_keep_days: keepDays,
  })

  if (error || !data) {
    return {
      success: false,
      error: error?.message ?? 'Prune RPC failed.',
      errorCode: 'INTERNAL',
    }
  }

  const row = Array.isArray(data) ? data[0] : data
  return {
    success: true,
    deletedSnapshots: Number(row.deleted_snapshots ?? 0),
    deletedRows: Number(row.deleted_rows ?? 0),
  }
}
