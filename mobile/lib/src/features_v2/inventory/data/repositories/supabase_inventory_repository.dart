import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../features/inventory/models/inventory_model.dart'; // Reuse for DTO/Model
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/inventory_admin_fields.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../sources/inventory_local_source.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../loans/domain/entities/loan_item.dart';
import '../../../../core/utils/storage_utils.dart';

/// Senior Architect Choice: The Orchestrator
/// This repository now manages both Remote (Supabase) and Local (Isar)
/// ensuring the user always sees data, even with zero network.
class SupabaseInventoryRepository implements IInventoryRepository {
  final SupabaseClient _client;
  final InventoryLocalDataSource _local;

  SupabaseInventoryRepository(this._client, this._local);

  @override
  Future<List<InventoryItem>> fetchAll({String? warehouseId}) async {
    try {
      // 🛡️ STEEL CAGE: Querying the active_inventory view for mapped data
      var query = _client
          .from('active_inventory')
          .select('*');
      
      // If warehouseId is provided, we still query the catalog but might filter 
      // or handle it differently. For now, let's keep global city-wide view.
      
      final response = await query.order('item_name', ascending: true);
      
      final List<dynamic> data = response;
      
      final items = await compute(_parseAndMapItems, data);

      // Parallel Sync
      _local.saveAll(items);

      return items;
    } catch (e) {
      debugPrint('Fetch Error: ${ExceptionHandler.getDisplayMessage(e)}');
      rethrow; // Let caller handle the error
    }
  }

  /// Watch local storage for real-time reactivity
  @override
  Stream<List<InventoryItem>> watchLocal() => _local.watchItems();

  @override
  Stream<InventoryItem?> watchItem(int id) => _local.watchItem(id);

  @override
  Future<InventoryItem?> findByQrCode(String code, {String? warehouseId}) async {
    try {
      // 🛡️ STEEL CAGE: QR scanning still points to specific location rows
      var query = _client
          .from('active_inventory')
          .select('*')
          .eq('qr_code', code);
      
      final response = await query.maybeSingle();

      if (response != null) {
        final model = InventoryModel.fromJson(response);
        final item = _mapModelToEntity(model);
        _local.saveAll([item]);
        return item;
      }
    } catch (e) {
      debugPrint('QR Lookup Error: ${ExceptionHandler.getDisplayMessage(e)}');
    }
    return _local.findByQrCode(code);
  }

  @override
  Future<void> syncLocalWithRemote({String? warehouseId}) async {
    await fetchAll(warehouseId: warehouseId);
  }

  @override
  Stream<void> watchRemote({String? warehouseId}) {
    // Watch inventory table for changes
    final query = _client.from('inventory').stream(primaryKey: ['id']);

    return query.asyncMap((_) async {
      await fetchAll(warehouseId: warehouseId);
    });
  }

  @override
  Future<void> archiveItem(String id) async {
    try {
      debugPrint('[LIGTAS-Security] 🛡️ Soft-Deleting Item: $id');
      
      await _client
          .from('inventory')
          .update({
            'deleted_at': DateTime.now().toUtc().toIso8601String(),
            'status': 'archived'
          })
          .eq('id', id);

      // Local update
      final items = await _local.watchItems().first;
      final updatedItems = items.where((i) => i.id.toString() != id).toList();
      _local.saveAll(updatedItems);
      
    } catch (e) {
      debugPrint('[LIGTAS-Security] 🛑 Archive failed: $e');
      rethrow;
    }
  }

  @override
  Future<List<InventoryItem>> fetchLocalPaged({required int offset, required int limit, String? category}) async {
    return _local.fetchPagedItems(offset, limit, category: category);
  }

  @override
  Future<int> countLocal() async {
    return _local.countItems();
  }

  @override
  Future<List<InventoryItem>> searchLocal(String query) async {
    return _local.searchLocal(query);
  }

  /// The Buffer Zone: Mapping DTO -> Entity (Single Item)
  InventoryItem _mapModelToEntity(InventoryModel model) {
    return InventoryItem(
      id: model.id,
      name: model.name,
      description: model.description,
      category: model.category,
      totalStock: model.quantity,
      availableStock: model.available,
      location: model.location.isNotEmpty ? model.location : (model.primaryLocation ?? ''),
      qrCode: model.qrCode,
      status: model.status,
      code: model.code,
      minStockLevel: model.minStockLevel,
      unit: model.unit,
      imageUrl: StorageUtils.resolveAssetUrl(model.imageUrl),
      lastUpdated: model.updatedAt,
      
      // Multi-location fields
      aggregateTotal: model.aggregateTotal,
      aggregateAvailable: model.aggregateAvailable,
      variants: model.variants.map((v) => InventoryVariant(
        id: v['id'] as int,
        location: v['location'] as String? ?? 'Unknown',
        stockAvailable: v['stock_available'] as int? ?? 0,
        stockTotal: v['stock_total'] as int? ?? 0,
        status: v['status'] as String? ?? 'Good',
      )).toList(),
    );
  }
  
  @override
  Future<void> adjustStock({
    required int itemId,
    required double oldQuantity,
    required double newQuantity,
    required String actionType,
    required String reason,
    String? recipientName,
    String? recipientOffice,
    String? warehouseId,
  }) async {
    try {
      await _client.rpc('adjust_inventory_item', params: {
        'p_item_id': itemId,
        'p_old_quantity': oldQuantity.toInt(),
        'p_new_quantity': newQuantity.toInt(),
        'p_action_type': actionType,
        'p_forensic_note': reason,
        'p_item_name': 'Manual Adjustment',
        'p_recipient_name': recipientName,
        'p_recipient_office': recipientOffice,
      });

      // Refresh local cache
      await fetchAll(warehouseId: warehouseId);
    } catch (e) {
      throw Exception('Failed to adjust stock: $e');
    }
  }

  @override
  Future<InventoryAdminFields> fetchAdminFields(int itemId) async {
    try {
      final response = await _client
          .from('inventory')
          .select(
            'id, qty_good, qty_damaged, qty_maintenance, qty_lost, stock_total, stock_available, storage_location, location_registry_id',
          )
          .eq('id', itemId)
          .maybeSingle();

      if (response == null) {
        throw Exception('Inventory item not found for admin edit (id=$itemId)');
      }

      final qtyGood = (response['qty_good'] ?? 0) as num;
      final qtyDamaged = (response['qty_damaged'] ?? 0) as num;
      final qtyMaintenance = (response['qty_maintenance'] ?? 0) as num;
      final qtyLost = (response['qty_lost'] ?? 0) as num;

      final stockTotal = (response['stock_total'] ?? 0) as num;
      final stockAvailable = (response['stock_available'] ?? 0) as num;

      final storageLocation = (response['storage_location'] ?? '') as String;
      final locationRegistryIdRaw = response['location_registry_id'];
      final locationRegistryId =
          locationRegistryIdRaw == null ? null : (locationRegistryIdRaw as num).toInt();

      return InventoryAdminFields(
        qtyGood: qtyGood.toInt(),
        qtyDamaged: qtyDamaged.toInt(),
        qtyMaintenance: qtyMaintenance.toInt(),
        qtyLost: qtyLost.toInt(),
        stockTotal: stockTotal.toInt(),
        stockAvailable: stockAvailable.toInt(),
        storageLocation: storageLocation,
        locationRegistryId: locationRegistryId,
      );
    } catch (e) {
      debugPrint('fetchAdminFields error: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateAdminFields({
    required int itemId,
    required int qtyGood,
    required int qtyDamaged,
    required int qtyMaintenance,
    required int qtyLost,
    required String storageLocation,
    int? locationRegistryId,
    required String forensicNote,
  }) async {
    try {
      // Used for future audit column wiring; keep reference to avoid analyzer warnings.
      if (forensicNote.trim().isEmpty) {
        // no-op; validation happens in UI / calling layer
      }

      if (qtyGood < 0 || qtyDamaged < 0 || qtyMaintenance < 0 || qtyLost < 0) {
        throw Exception('Bucket quantities cannot be negative');
      }

      final stockTotal = qtyGood + qtyDamaged + qtyMaintenance + qtyLost;
      if (stockTotal < 1) {
        throw Exception('Total stock must be at least 1');
      }

      // Keep parity with web: base status is always "Good"; bucket distribution
      // is represented via qty_* columns.
      await _client.from('inventory').update({
        'qty_good': qtyGood,
        'qty_damaged': qtyDamaged,
        'qty_maintenance': qtyMaintenance,
        'qty_lost': qtyLost,
        'stock_total': stockTotal,
        'stock_available': qtyGood,
        'status': 'Good',
        'storage_location': storageLocation,
        'location_registry_id': locationRegistryId,
        // If the DB has an audit/forensic column you can wire it here.
        // For now, we keep the note for future extension.
      }).eq('id', itemId);

      // Refresh local cache
      await fetchAll();
    } catch (e) {
      throw Exception('Failed to update admin fields: $e');
    }
  }

  @override
  Future<void> borrowItem({
    required int itemId,
    required int quantity,
    required String borrowerName,
    required String borrowerContact,
    required String borrowerOrganization,
    required String approvedBy,
    required String releasedBy,
    DateTime? expectedReturnDate,
    DateTime? pickupScheduledAt, // 🛡️ NEW: Support for reservations
    String? purpose,
    String? warehouseId,
  }) async {
    try {
      final user = _client.auth.currentUser;
      final isScheduled = pickupScheduledAt != null;
      
      // 1. Check stock availability
      final itemData = await _client
          .from('inventory')
          .select('item_name, stock_available, quantity, item_type')
          .eq('id', itemId)
          .single();
      
      final currentAvailable = (itemData['stock_available'] ?? 0) as int;
      final currentTotal = (itemData['quantity'] ?? 0) as int;
      final isConsumable = (itemData['item_type'] == 'consumable');

      if (currentAvailable < quantity) {
        throw Exception('Insufficient stock. Only $currentAvailable available.');
      }

      final now = DateTime.now().toUtc().toIso8601String();

      // 2. Insert into borrow_logs
      // 🛡️ LOGIC: If scheduled, status is 'staged' and borrow_date is null
      await _client.from('borrow_logs').insert({
        'inventory_id': itemId,
        'inventory_item_id': itemId.toString(),
        'item_name': itemData['item_name'],
        'quantity': quantity,
        'quantity_borrowed': quantity,
        'borrower_name': borrowerName,
        'borrower_contact': borrowerContact,
        'borrower_organization': borrowerOrganization,
        'purpose': purpose ?? '',
        'approved_by_name': approvedBy,
        'released_by_name': releasedBy.isEmpty ? 'Unknown' : releasedBy,
        'released_by_user_id': user?.id,
        'borrowed_by': user?.id,
        'transaction_type': isConsumable ? 'dispense' : 'borrow',
        'status': isConsumable ? 'dispensed' : (isScheduled ? 'staged' : 'borrowed'),
        'borrow_date': isScheduled ? null : now,
        'pickup_scheduled_at': pickupScheduledAt?.toUtc().toIso8601String(),
        'actual_return_date': isConsumable ? now : null,
        'expected_return_date': isConsumable ? null : expectedReturnDate?.toUtc().toIso8601String(),
        'warehouse_id': warehouseId,
        'created_at': now,
      });

      // 3. TACTICAL SYNC: Decrement stock
      await _client.from('inventory').update({
        'stock_available': currentAvailable - quantity,
        // Only decrement total stock for consumables or immediate dispatches
        if (isConsumable) 'quantity': currentTotal - quantity,
      }).eq('id', itemId);

      // 4. Local Refresh
      await fetchAll(warehouseId: warehouseId);
    } catch (e) {
      debugPrint('Borrow Error: $e');
      throw Exception('Failed to dispatch item: $e');
    }
  }

  @override
  Future<void> returnItem({
    required String loanId,
    required String condition,
    String? notes,
    required String receivedByName,
    String? warehouseId,
  }) async {
    try {
      final user = _client.auth.currentUser;

      // 1. Fetch Log
      final log = await _client
          .from('borrow_logs')
          .select('inventory_id, quantity, status')
          .eq('id', int.parse(loanId))
          .single();

      if (log['status'] == 'returned') return;

      // 2. Update Log
      await _client.from('borrow_logs').update({
        'status': 'returned',
        'actual_return_date': DateTime.now().toUtc().toIso8601String(),
        'received_by_name': receivedByName,
        'received_by_user_id': user?.id,
        'return_condition': condition.toLowerCase(),
        'return_notes': notes,
      }).eq('id', int.parse(loanId));

      // 3. Update Inventory (Increment)
      final itemData = await _client
          .from('inventory')
          .select('stock_available')
          .eq('id', log['inventory_id'])
          .single();
      
      final currentStock = (itemData['stock_available'] ?? 0) as int;
      final quantityToReturn = (log['quantity'] ?? 0) as int;

      await _client.from('inventory').update({
        'stock_available': currentStock + quantityToReturn,
      }).eq('id', log['inventory_id']);

      // 4. Local Refresh
      await fetchAll(warehouseId: warehouseId);
    } catch (e) {
      debugPrint('Return Error: $e');
      throw Exception('Failed to process return: $e');
    }
  }

  @override
  Future<LoanItem?> getActiveLoan(int itemId, String borrowerName) async {
    try {
      final response = await _client
          .from('borrow_logs')
          .select('*')
          .eq('inventory_id', itemId)
          .ilike('borrower_name', borrowerName.trim())
          .eq('status', 'borrowed')
          .maybeSingle();

      if (response == null) return null;
      
      return _mapLogToLoanItem(response);
    } catch (e) {
      debugPrint('Active Loan Search Error: $e');
      return null;
    }
  }

  LoanItem _mapLogToLoanItem(Map<String, dynamic> data) {
    String? borrowDateStr = data['borrow_date'] as String? ?? data['created_at'] as String?;
    DateTime borrowDate = borrowDateStr != null ? DateTime.parse(borrowDateStr).toLocal() : DateTime.now();
    final expectedDateStr = data['expected_return_date'] as String? ?? DateTime.now().add(const Duration(days: 7)).toIso8601String();
    final expectedReturnDate = DateTime.parse(expectedDateStr).toLocal();

    return LoanItem(
      id: data['id'].toString(),
      inventoryItemId: (data['inventory_id'] ?? '').toString(),
      itemName: data['item_name'] as String? ?? '',
      itemCode: data['item_code'] as String? ?? '',
      borrowerName: data['borrower_name'] as String? ?? 'Unknown',
      borrowerContact: data['borrower_contact'] as String? ?? '',
      borrowerOrganization: data['borrower_organization'] as String? ?? '',
      purpose: data['purpose'] as String? ?? '',
      quantityBorrowed: (data['quantity'] ?? 1) as int,
      borrowDate: borrowDate,
      expectedReturnDate: expectedReturnDate,
      status: LoanStatus.active,
      borrowedBy: (data['borrowed_by'] ?? '').toString(),
    );
  }
}

/// 🛡️ GLOBAL ISOLATE WORKER: Parses and maps inventory items off the main thread.
List<InventoryItem> _parseAndMapItems(List<dynamic> data) {
  return data.map((json) {
    final model = InventoryModel.fromJson(json);
    return InventoryItem(
      id: model.id,
      name: model.name,
      description: model.description,
      category: model.category,
      totalStock: model.quantity,
      availableStock: model.available,
      location: model.location.isNotEmpty ? model.location : (model.primaryLocation ?? ''),
      qrCode: model.qrCode,
      status: model.status,
      code: model.code,
      minStockLevel: model.minStockLevel,
      unit: model.unit,
      imageUrl: StorageUtils.resolveAssetUrl(model.imageUrl),
      lastUpdated: model.updatedAt,
      
      // Multi-location fields
      aggregateTotal: model.aggregateTotal,
      aggregateAvailable: model.aggregateAvailable,
      variants: model.variants.map((v) => InventoryVariant(
        id: v['id'] as int,
        location: v['location'] as String? ?? 'Unknown',
        stockAvailable: v['stock_available'] as int? ?? 0,
        stockTotal: v['stock_total'] as int? ?? 0,
        status: v['status'] as String? ?? 'Good',
      )).toList(),
    );
  }).toList();
}

