import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile/src/features_v2/inventory/domain/entities/inventory_admin_fields.dart';
import 'package:mobile/src/features_v2/inventory/presentation/providers/inventory_provider.dart';

part 'manager_action_prefill_provider.g.dart';

/// Cached list of storage hubs used by the Restock and Edit location dropdowns.
/// Kept separate from inventory_provider to avoid pulling this concern into
/// the main feed. Hits Supabase once per sheet lifecycle; Riverpod caches it.
@riverpod
Future<List<StorageHub>> managerStorageHubs(ManagerStorageHubsRef ref) async {
  final client = Supabase.instance.client;
  final response = await client
      .from('storage_locations')
      .select('id, location_name')
      .order('location_name');

  return (response as List)
      .map((e) => StorageHub(id: e['id'] as int, name: e['location_name'] as String))
      .toList();
}

/// Loads admin bucket fields for a single item — only called when the user
/// switches to Edit mode. The controller watches the isEditLoading flag instead
/// of this provider directly, so it can merge the result into its own state.
@riverpod
Future<InventoryAdminFields> managerEditAdminFields(
  ManagerEditAdminFieldsRef ref,
  int itemId,
) async {
  final repo = ref.watch(inventoryRepositoryProvider);
  return repo.fetchAdminFields(itemId);
}
