/// Human-readable labels for [inventory.storage_location] / [borrow_logs.borrowed_from_warehouse]
/// slugs — mirrors `web/lib/supabase.ts` `STORAGE_LOCATION_LABELS`.
String formatStorageLocationLabel(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return t;
  switch (t.toLowerCase()) {
    case 'lower_warehouse':
      return 'Lower Warehouse';
    case '2nd_floor_warehouse':
      return '2nd Floor Warehouse';
    case 'office':
      return 'Office';
    case 'field':
      return 'Field';
    default:
      return t;
  }
}
