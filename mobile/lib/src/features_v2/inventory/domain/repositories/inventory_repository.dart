import '../entities/inventory_item.dart';
import '../entities/inventory_admin_fields.dart';
import '../../../loans/domain/entities/loan_item.dart';

/// The contract for moving inventory data. 
/// Senior Dev Principle: Interface-driven design.
abstract class IInventoryRepository {
  /// Fetch all active inventory items
  Future<List<InventoryItem>> fetchAll({String? warehouseId});

  /// Search for an item by QR code
  Future<InventoryItem?> findByQrCode(String code, {String? warehouseId});

  /// Synchronize local and remote data
  Future<void> syncLocalWithRemote({String? warehouseId});

  /// Watch for remote changes from Supabase Realtime
  Stream<void> watchRemote({String? warehouseId});

  /// 🛡️ THE GOLD STANDARD: Fetch a subset of inventory from local disk (Isar)
  Future<List<InventoryItem>> fetchLocalPaged({required int offset, required int limit, String? category});

  /// 🛡️ METRICS: Get total count of items in local DB
  Future<int> countLocal();

  /// 🛡️ SEARCH BYPASS: Instantly search the entire local DB matching a query
  Future<List<InventoryItem>> searchLocal(String query);

  /// 🛡️ STEEL CAGE: Soft-delete (archive) an item by ID
  Future<void> archiveItem(String id);

  /// Watch local storage for real-time reactivity (Full List)
  Stream<List<InventoryItem>> watchLocal();

  /// 📡 ATOMIC OBSERVATION: Watch a single row for instant UI reactivity
  Stream<InventoryItem?> watchItem(int id);

  /// 🚀 THE ATOMIC COMMIT: Adjust stock levels and record forensic activity
  Future<void> adjustStock({
    required int itemId,
    required double oldQuantity,
    required double newQuantity,
    required String actionType,
    required String reason,
    String? recipientName,
    String? recipientOffice,
    String? warehouseId,
  });

  /// 🛡️ THE DISPATCH COMMANDMENTS: Full Audit Parity with Web
  Future<void> borrowItem({
    required int itemId,
    required int quantity,
    required String borrowerName,
    required String borrowerContact,
    required String borrowerOrganization,
    required String approvedBy,
    required String releasedBy,
    DateTime? expectedReturnDate,
    DateTime? pickupScheduledAt,
    String? purpose,
    String? warehouseId,
  });

  /// 🔄 THE RECEIPT: Complete return assessment with audit sign-off
  Future<void> returnItem({
    required String loanId,
    required String condition,
    String? notes,
    required String receivedByName,
    String? warehouseId,
  });

  /// 🔍 THE RADAR: Find active loans to trigger Smart Return detection
  Future<LoanItem?> getActiveLoan(int itemId, String borrowerName);

  /// 🛠️ ADMIN EDIT: Fetch bucket distribution + location registry info
  Future<InventoryAdminFields> fetchAdminFields(int itemId);

  /// 🛠️ ADMIN EDIT: Update bucket distribution + location
  Future<void> updateAdminFields({
    required int itemId,
    required int qtyGood,
    required int qtyDamaged,
    required int qtyMaintenance,
    required int qtyLost,
    required String storageLocation,
    int? locationRegistryId,
    required String forensicNote,
  });
}
