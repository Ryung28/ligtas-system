export const RESET_SCOPE_VERSION = 'v1'
export const RESET_CONFIRMATION_PHRASE = 'RESET LOGBOOK'
export const BACKUP_CONFIRMATION_PHRASE = 'BACKUP LOGBOOK'
export const IMPORT_CONFIRMATION_PHRASE = 'IMPORT LOGBOOK'
export const RESTORE_CONFIRMATION_PHRASE = 'RESTORE LOGBOOK'

export const RESET_SCOPE_TABLES = [
  'public.chat_messages',
  'public.chat_rooms',
  'public.borrow_logs',
  'public.notification_reads',
  'public.notification_deliveries',
  'public.notification_events',
  'public.system_notifications',
  'public.activity_log',
  'public.cctv_logs',
  'public.logistics_actions',
  'public.auth_debug_logs',
] as const

export const FK_SAFE_RESET_ORDER = [...RESET_SCOPE_TABLES] as const

export const PROTECTED_TABLES = [
  'public.inventory',
  'public.storage_locations',
  'public.station_manifest',
  'public.user_profiles',
  'storage.objects',
  'storage.buckets',
] as const

export type ResetScopeTable = (typeof RESET_SCOPE_TABLES)[number]
