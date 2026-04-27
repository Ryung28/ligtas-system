export const BACKUP_SIGNATURE_ALGORITHM = 'HMAC-SHA256'
export const BACKUP_SCHEMA_VERSION = 'logbook-export-v2'
export const LEGACY_SCHEMA_VERSION = 'logbook-export-v1'

export const MAX_BACKUP_IMPORT_BYTES = 10 * 1024 * 1024
export const MAX_BACKUP_IMPORT_ROWS = 250000

export function getMaxBackupImportBytes(): number {
  return MAX_BACKUP_IMPORT_BYTES
}

export function getMaxBackupImportRows(): number {
  return MAX_BACKUP_IMPORT_ROWS
}
