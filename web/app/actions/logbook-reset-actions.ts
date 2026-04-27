'use server'

import { createSupabaseServer } from '@/lib/supabase-server'
import {
  RESET_CONFIRMATION_PHRASE,
  RESET_SCOPE_VERSION,
} from '@/src/features/admin-logbook-reset/reset-scope'
import type { LogbookResetResult } from '@/src/features/admin-logbook-reset/types'

interface ExecuteResetInput {
  confirmation: string
  reason: string
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

export async function executeLogbookResetAction(
  input: ExecuteResetInput,
): Promise<LogbookResetResult> {
  if (input.confirmation !== RESET_CONFIRMATION_PHRASE) {
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
    .select('id,status')
    .eq('status', 'completed')
    .order('created_at', { ascending: false })
    .limit(1)
    .maybeSingle()

  if (backupGuardError) {
    return {
      success: false,
      error: 'Failed to verify backup status.',
      errorCode: 'INTERNAL',
    }
  }

  if (!latestBackup?.id) {
    return {
      success: false,
      error: 'Reset is blocked: create a completed logbook backup first.',
      errorCode: 'PRECONDITION',
    }
  }

  if (latestBackup.created_at) {
    const latestBackupAt = new Date(latestBackup.created_at).getTime()
    const freshnessWindowMs = BACKUP_FRESHNESS_HOURS * 60 * 60 * 1000
    if (Date.now() - latestBackupAt > freshnessWindowMs) {
      return {
        success: false,
        error: `Reset is blocked: latest backup is older than ${BACKUP_FRESHNESS_HOURS} hours.`,
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
    const message = error?.message ?? 'Reset RPC failed.'
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
  const reason = input.reason.trim()
  if (reason.length < 10) {
    return {
      success: false,
      error: 'Please provide a more detailed reason.',
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
    const message = error?.message ?? 'Backup RPC failed.'
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
  if (input.confirmation !== RESET_CONFIRMATION_PHRASE) {
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

  const snapshotId = input.snapshotId.trim()
  if (!snapshotId) {
    return {
      success: false,
      error: 'Snapshot ID is required for restore.',
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

  const { data, error } = await supabase.rpc('admin_logbook_restore_v1', {
    p_requested_by: user.id,
    p_snapshot_id: snapshotId,
    p_reason: reason,
    p_scope_version: RESET_SCOPE_VERSION,
  })

  if (error || !data) {
    const message = error?.message ?? 'Restore RPC failed.'
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
