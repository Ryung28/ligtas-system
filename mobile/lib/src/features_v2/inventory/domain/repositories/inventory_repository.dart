import '../entities/inventory_item.dart';

/// The contract for moving inventory data. 
/// Senior Dev Principle: Interface-driven design.
abstract class IInventoryRepository {
  /// Fetch all active inventory items
  Future<List<InventoryItem>> fetchAll();

  /// Search for an item by QR code
  Future<InventoryItem?> findByQrCode(String code);

  /// Synchronize local and remote data
  Future<void> syncLocalWithRemote();

  /// Watch for remote changes from Supabase Realtime
  Stream<void> watchRemote();

  /// 🛡️ STEEL CAGE: Soft-delete (archive) an item by ID
  Future<void> archiveItem(String id);
}
