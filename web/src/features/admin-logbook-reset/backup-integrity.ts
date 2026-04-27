import { createHash, createHmac, timingSafeEqual } from 'node:crypto'
import {
  BACKUP_SIGNATURE_ALGORITHM,
  BACKUP_SCHEMA_VERSION,
  LEGACY_SCHEMA_VERSION,
  getMaxBackupImportBytes,
  MAX_BACKUP_IMPORT_ROWS,
} from './backup-config'

export { getMaxBackupImportBytes } from './backup-config'

interface RawSnapshotPayload {
  schema_version?: unknown
  snapshot?: unknown
  rows?: unknown
}

interface SignedEnvelope {
  schema_version: string
  payload_sha256: string
  signature: {
    algorithm: string
    value: string
  }
  payload: RawSnapshotPayload
}

export function createSignedLogbookExportEnvelope(
  payload: unknown,
  signingSecret: string,
): SignedEnvelope {
  const normalizedPayload = normalizeExportPayload(payload)
  const serializedPayload = JSON.stringify(normalizedPayload)
  const digest = sha256Hex(serializedPayload)
  const signature = hmacHex(signingSecret, serializedPayload)
  return {
    schema_version: BACKUP_SCHEMA_VERSION,
    payload_sha256: digest,
    signature: {
      algorithm: BACKUP_SIGNATURE_ALGORITHM,
      value: signature,
    },
    payload: normalizedPayload,
  }
}

export function parseAndValidateImportPayload(
  payload: unknown,
  signingSecret: string,
): RawSnapshotPayload {
  if (!payload || typeof payload !== 'object') {
    throw new Error('Invalid backup payload.')
  }

  const raw = payload as Record<string, unknown>
  const schemaVersion = typeof raw.schema_version === 'string' ? raw.schema_version : ''

  // Block legacy unsigned imports once integrity checks are mandatory.
  if (schemaVersion === LEGACY_SCHEMA_VERSION) {
    throw new Error('Legacy unsigned exports are no longer accepted. Re-export using signed format.')
  }

  if (schemaVersion !== BACKUP_SCHEMA_VERSION) {
    throw new Error('Unsupported backup schema version.')
  }

  const signed = raw as SignedEnvelope
  if (
    !signed.signature ||
    typeof signed.signature !== 'object' ||
    typeof signed.signature.algorithm !== 'string' ||
    typeof signed.signature.value !== 'string'
  ) {
    throw new Error('Missing backup signature.')
  }

  if (signed.signature.algorithm !== BACKUP_SIGNATURE_ALGORITHM) {
    throw new Error('Unsupported backup signature algorithm.')
  }

  const normalizedPayload = normalizeExportPayload(signed.payload)
  const serializedPayload = JSON.stringify(normalizedPayload)
  const expectedDigest = sha256Hex(serializedPayload)

  if (typeof signed.payload_sha256 !== 'string' || signed.payload_sha256 !== expectedDigest) {
    throw new Error('Backup checksum mismatch.')
  }

  const expectedSignature = hmacHex(signingSecret, serializedPayload)
  if (!safeHexEqual(expectedSignature, signed.signature.value)) {
    throw new Error('Backup signature verification failed.')
  }

  const rows = normalizedPayload.rows
  if (!Array.isArray(rows)) {
    throw new Error('Invalid backup payload rows.')
  }

  if (rows.length > MAX_BACKUP_IMPORT_ROWS) {
    throw new Error(`Backup import exceeds max rows (${MAX_BACKUP_IMPORT_ROWS}).`)
  }

  return normalizedPayload
}

function normalizeExportPayload(payload: unknown): RawSnapshotPayload {
  if (!payload || typeof payload !== 'object') {
    throw new Error('Invalid export payload.')
  }
  const typed = payload as RawSnapshotPayload
  if (typed.schema_version !== LEGACY_SCHEMA_VERSION) {
    throw new Error('Unsupported export payload.')
  }
  if (!typed.snapshot || typeof typed.snapshot !== 'object') {
    throw new Error('Export payload snapshot metadata missing.')
  }
  if (!Array.isArray(typed.rows)) {
    throw new Error('Export payload rows missing.')
  }
  return typed
}

function sha256Hex(input: string): string {
  return createHash('sha256').update(input, 'utf8').digest('hex')
}

function hmacHex(secret: string, input: string): string {
  return createHmac('sha256', secret).update(input, 'utf8').digest('hex')
}

function safeHexEqual(a: string, b: string): boolean {
  try {
    const left = Buffer.from(a, 'hex')
    const right = Buffer.from(b, 'hex')
    if (left.length === 0 || right.length === 0 || left.length !== right.length) {
      return false
    }
    return timingSafeEqual(left, right)
  } catch {
    return false
  }
}
