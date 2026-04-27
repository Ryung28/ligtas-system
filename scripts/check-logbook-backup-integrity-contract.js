/* eslint-disable no-console */
const fs = require('node:fs')
const path = require('node:path')

function fail(message) {
  console.error(`logbook-backup-integrity-contract: ${message}`)
  process.exit(1)
}

const root = process.cwd()
const integrityPath = path.join(
  root,
  'src',
  'features',
  'admin-logbook-reset',
  'backup-integrity.ts',
)
const configPath = path.join(
  root,
  'src',
  'features',
  'admin-logbook-reset',
  'backup-config.ts',
)
const actionsPath = path.join(root, 'app', 'actions', 'logbook-reset-actions.ts')
const exportRoutePath = path.join(root, 'app', 'api', 'admin', 'logbook-export', 'route.ts')

const integritySource = fs.readFileSync(integrityPath, 'utf8')
const configSource = fs.readFileSync(configPath, 'utf8')
const actionsSource = fs.readFileSync(actionsPath, 'utf8')
const exportRouteSource = fs.readFileSync(exportRoutePath, 'utf8')

const requiredConfigSignals = [
  "const BACKUP_SCHEMA_VERSION = 'logbook-export-v2'",
  "const LEGACY_SCHEMA_VERSION = 'logbook-export-v1'",
  'MAX_BACKUP_IMPORT_BYTES',
  'MAX_BACKUP_IMPORT_ROWS',
]

for (const signal of requiredConfigSignals) {
  if (!configSource.includes(signal)) {
    fail(`Missing backup-config signal: ${signal}`)
  }
}

const requiredIntegritySignals = [
  'timingSafeEqual',
  'Legacy unsigned exports are no longer accepted',
  'Backup checksum mismatch.',
  'Backup signature verification failed.',
]

for (const signal of requiredIntegritySignals) {
  if (!integritySource.includes(signal)) {
    fail(`Missing integrity guard signal in backup-integrity.ts: ${signal}`)
  }
}

if (!actionsSource.includes('parseAndValidateImportPayload')) {
  fail('Import action must verify signature before calling RPC.')
}

if (!exportRouteSource.includes('createSignedLogbookExportEnvelope')) {
  fail('Export route must emit signed backup envelope.')
}

console.log('logbook-backup-integrity-contract: OK')
