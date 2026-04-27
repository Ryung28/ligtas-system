/* eslint-disable no-console */
// Keep this list synced with src/features/admin-logbook-reset/reset-scope.ts
const RESET_SCOPE_TABLES = [
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
]

const FK_SAFE_RESET_ORDER = [...RESET_SCOPE_TABLES]

const PROTECTED_TABLES = [
  'public.inventory',
  'public.storage_locations',
  'public.station_manifest',
  'public.user_profiles',
  'storage.objects',
  'storage.buckets',
]

function fail(message) {
  console.error(`logbook-reset-contract: ${message}`)
  process.exit(1)
}

const scope = new Set(RESET_SCOPE_TABLES)
const order = FK_SAFE_RESET_ORDER
const protectedTables = new Set(PROTECTED_TABLES)

if (scope.size !== RESET_SCOPE_TABLES.length) {
  fail('RESET_SCOPE_TABLES has duplicate entries.')
}

if (order.length !== RESET_SCOPE_TABLES.length) {
  fail('FK_SAFE_RESET_ORDER length must match RESET_SCOPE_TABLES length.')
}

for (const table of order) {
  if (!scope.has(table)) {
    fail(`FK_SAFE_RESET_ORDER contains table not in scope: ${table}`)
  }
}

for (const table of RESET_SCOPE_TABLES) {
  if (protectedTables.has(table)) {
    fail(`Protected table is included in reset scope: ${table}`)
  }
}

// Current known FK child->parent edges in your schema.
// Child must appear earlier than parent in FK_SAFE_RESET_ORDER.
const fkEdges = [
  ['public.chat_messages', 'public.chat_rooms'],
  ['public.chat_rooms', 'public.borrow_logs'],
  ['public.notification_reads', 'public.system_notifications'],
  ['public.notification_deliveries', 'public.notification_events'],
]

for (const [child, parent] of fkEdges) {
  const childIdx = order.indexOf(child)
  const parentIdx = order.indexOf(parent)
  if (childIdx === -1 || parentIdx === -1) {
    fail(`FK edge references missing table(s): ${child} -> ${parent}`)
  }
  if (childIdx > parentIdx) {
    fail(
      `FK order violation: ${child} must be cleared before ${parent}.`,
    )
  }
}

console.log('logbook-reset-contract: OK')
