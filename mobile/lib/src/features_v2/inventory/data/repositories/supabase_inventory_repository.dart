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
  Future<List<InventoryItem>> fetchAll({String? warehouseId, DateTime? updatedAfter}) async {
    try {
      // 🛡️ STEEL CAGE: Querying the active_inventory view for mapped data
      var query = _client.from('active_inventory').select('*');

      // 🔄 DIFFERENTIAL SYNC: If we have a last sync date, only fetch what's new/changed
      // Note: active_inventory view must contain 'updated_at' column
      if (updatedAfter != null) {
        query = query.gt('updated_at', updatedAfter.toIso8601String());
      }

      final response = await query
          .order('item_name', ascending: true)
          .timeout(const Duration(seconds: 15)); // 🛡️ Resilience timeout

      final List<dynamic> data = response;
      final items = await compute(_parseAndMapItems, data);

      // Parallel Sync: Only save if we actually got items
      if (items.isNotEmpty) {
        await _local.saveAll(items);
      }

      return items;
    } catch (e, st) {
      // 🛡️ Map to structured AppException for the UI to handle properly
      final failure = ExceptionHandler.fromException(e);
      debugPrint('🛡️ SupabaseInventoryRepository.fetchAll failed: $failure');
      Error.throwWithStackTrace(failure, st);
    }
  }

  /// Watch local storage for real-time reactivity
  @override
  Stream<List<InventoryItem>> watchLocal() => _local.watchItems();

  @override
  Stream<InventoryItem?> watchItem(int id) => _local.watchItem(id);

  @override
  Future<InventoryItem?> findByQrCode(
    String code, {
    String? warehouseId,
  }) async {
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
        await _local.saveAll([item]);
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
  Future<InventoryItem?> fetchById(int id) async {
    try {
      final response =
          await _client
              .from('active_inventory')
              .select('*')
              .eq('id', id)
              .maybeSingle();

      if (response != null) {
        final model = InventoryModel.fromJson(response);
        final item = _mapModelToEntity(model);
        await _local.saveAll([item]);
        return item;
      }
      return null;
    } catch (e) {
      debugPrint('Surgical Fetch Error: $e');
      return null;
    }
  }

  @override
  Future<void> archiveItem(String id) async {
    try {
      debugPrint('[ResQTrack-Security] 🛡️ Hard-Deleting Item: $id');

      // 1. Check for active borrows
      final activeBorrows = await _client
          .from('borrow_logs')
          .select('id')
          .eq('inventory_id', id)
          .eq('status', 'borrowed');

      if ((activeBorrows as List).isNotEmpty) {
        throw Exception(
          '⚠️ STRATEGIC BLOCK: Cannot archive resource. Resolve active borrows (Mark as Returned or Lost) first.',
        );
      }

      // 2. Hard Delete
      await _client.from('inventory').delete().eq('id', id);

      // 3. Local update
      final items = await _local.watchItems().first;
      final updatedItems = items.where((i) => i.id.toString() != id).toList();
      await _local.saveAll(updatedItems);
    } catch (e) {
      debugPrint('[ResQTrack-Security] 🛑 Archive failed: $e');
      rethrow;
    }
  }

  @override
  Future<List<InventoryItem>> fetchLocalPaged({
    required int offset,
    required int limit,
    String? category,
  }) async {
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
      location:
          model.location.isNotEmpty
              ? model.location
              : (model.primaryLocation ?? ''),
      qrCode: model.qrCode,
      status: model.status,
      code: model.code,
      modelNumber: model.modelNumber,
      minStockLevel: model.minStockLevel,
      targetStock: model.targetStock,
      unit: model.unit,
      imageUrl: StorageUtils.resolveAssetUrl(model.imageUrl),
      restockAlertEnabled: model.restockAlertEnabled,
      lastUpdated: model.updatedAt,
      qtyGood: model.qtyGood,
      qtyDamaged: model.qtyDamaged,
      qtyMaintenance: model.qtyMaintenance,
      qtyLost: model.qtyLost,
      // Multi-location fields
      aggregateTotal: model.aggregateTotal,
      aggregateAvailable: model.aggregateAvailable,
      variants: inventoryVariantsFromModelMaps(model.variants),
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
      await _client.rpc(
        'adjust_inventory_item',
        params: {
          'p_item_id': itemId,
          'p_old_quantity': oldQuantity.toInt(),
          'p_new_quantity': newQuantity.toInt(),
          'p_action_type': actionType,
          'p_forensic_note': reason,
          'p_item_name': 'Manual Adjustment',
          'p_recipient_name': recipientName,
          'p_recipient_office': recipientOffice,
        },
      );

      // Refresh local cache
      await fetchAll(warehouseId: warehouseId);
    } catch (e) {
      throw Exception('Failed to adjust stock: $e');
    }
  }

  @override
  Future<InventoryAdminFields> fetchAdminFields(int itemId) async {
    try {
      final response =
          await _client
              .from('inventory')
              .select(
                'id, qty_good, qty_damaged, qty_maintenance, qty_lost, stock_total, stock_available, storage_location, location_registry_id, target_stock',
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
          locationRegistryIdRaw == null
              ? null
              : (locationRegistryIdRaw as num).toInt();

      return InventoryAdminFields(
        qtyGood: qtyGood.toInt(),
        qtyDamaged: qtyDamaged.toInt(),
        qtyMaintenance: qtyMaintenance.toInt(),
        qtyLost: qtyLost.toInt(),
        stockTotal: stockTotal.toInt(),
        stockAvailable: stockAvailable.toInt(),
        storageLocation: storageLocation,
        locationRegistryId: locationRegistryId,
        targetStock: (response['target_stock'] ?? 0) as int,
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
      await _client
          .from('inventory')
          .update({
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
          })
          .eq('id', itemId);

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
      final itemData =
          await _client
              .from('inventory')
              .select('item_name, stock_available, stock_total, item_type')
              .eq('id', itemId)
              .single();

      final currentAvailable = (itemData['stock_available'] ?? 0) as int;
      final isConsumable = (itemData['item_type'] == 'consumable');

      if (currentAvailable < quantity) {
        throw Exception(
          'Insufficient stock. Only $currentAvailable available.',
        );
      }

      final now = DateTime.now().toUtc().toIso8601String();

      // 2. Insert into borrow_logs
      // 🛡️ TACTICAL ALIGNMENT: Match web parity for status and transaction types.
      // Database triggers handle the stock math automatically upon insertion.
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
        'status':
            isConsumable
                ? 'dispensed'
                : (isScheduled ? 'reserved' : 'borrowed'),
        // Keep borrow_date non-null to satisfy DB constraints for reserved rows.
        'borrow_date':
            isScheduled
                ? pickupScheduledAt.toUtc().toIso8601String()
                : now,
        'pickup_scheduled_at': pickupScheduledAt?.toUtc().toIso8601String(),
        'actual_return_date': isConsumable ? now : null,
        'expected_return_date':
            isConsumable ? null : expectedReturnDate?.toUtc().toIso8601String(),
        'warehouse_id': warehouseId,
        'created_at': now,
        'platform_origin': 'Mobile',
        'created_origin': 'Mobile',
        'last_updated_origin': 'Mobile',
      });

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
      final log =
          await _client
              .from('borrow_logs')
              .select('inventory_id, quantity, status')
              .eq('id', int.parse(loanId))
              .single();

      if (log['status'] == 'returned') return;

      // 2. Update Log
      await _client
          .from('borrow_logs')
          .update({
            'status': 'returned',
            'actual_return_date': DateTime.now().toUtc().toIso8601String(),
            'received_by_name': receivedByName,
            'received_by_user_id': user?.id,
            'return_condition': condition.toLowerCase(),
            'return_notes': notes,
          })
          .eq('id', int.parse(loanId));

      // 3. Update Inventory (Increment)
      final itemData =
          await _client
              .from('inventory')
              .select('stock_available')
              .eq('id', log['inventory_id'])
              .single();

      final currentStock = (itemData['stock_available'] ?? 0) as int;
      final quantityToReturn = (log['quantity'] ?? 0) as int;

      await _client
          .from('inventory')
          .update({'stock_available': currentStock + quantityToReturn})
          .eq('id', log['inventory_id']);

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
      final response =
          await _client
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
    String? borrowDateStr =
        data['borrow_date'] as String? ?? data['created_at'] as String?;
    DateTime borrowDate =
        borrowDateStr != null
            ? DateTime.parse(borrowDateStr).toLocal()
            : DateTime.now();
    final expectedDateStr =
        data['expected_return_date'] as String? ??
        DateTime.now().add(const Duration(days: 7)).toIso8601String();
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

  @override
  Future<void> updateItemMetadata({
    required int itemId,
    required String name,
    required String category,
    String? brand,
    String? equipmentType,
    String? serialNumber,
    String? modelNumber,
    String? expiryDate,
    int? targetStock,
    int? lowStockThreshold,
    String? imageUrl,
  }) async {
    try {
      // 🔒 IDENTITY LOCK: Update base metadata
      await _client
          .from('inventory')
          .update({
            'item_name': name,
            'category': category,
            if (brand != null) 'brand': brand,
            if (equipmentType != null) 'equipment_type': equipmentType,
            if (serialNumber != null) 'serial_number': serialNumber,
            if (modelNumber != null) 'model_number': modelNumber,
            if (expiryDate != null) 'expiry_date': expiryDate,
            if (targetStock != null) 'target_stock': targetStock,
            if (lowStockThreshold != null)
              'low_stock_threshold': lowStockThreshold,
            if (imageUrl != null) 'image_url': imageUrl,
          })
          .eq('id', itemId);

      // Refresh local cache
      await fetchAll();
    } catch (e) {
      throw Exception('Failed to update metadata: $e');
    }
  }

  @override
  Future<void> releaseReservedItem(int logId) async {
    try {
      final user = _client.auth.currentUser;
      final userName =
          user?.userMetadata?['full_name'] ?? user?.email ?? 'Authorized Staff';
      final now = DateTime.now().toUtc().toIso8601String();

      // 1. Check item type
      final logData = await _client
          .from('borrow_logs')
          .select('inventory_id, inventory!inner(item_type)')
          .eq('id', logId)
          .maybeSingle();

      bool isConsumable = false;
      if (logData != null && logData['inventory'] != null) {
        final itemType = logData['inventory']['item_type'];
        isConsumable = itemType == 'consumable';
      }

      await _client
          .from('borrow_logs')
          .update({
            'status': isConsumable ? 'dispensed' : 'borrowed',
            'borrow_date': now,
            'released_by_user_id': user?.id,
            'released_by_name': userName,
            'last_updated_origin': 'Mobile',
          })
          .eq('id', logId);

      // Refresh local cache
      // (Optionally sync transactions if we have a separate transaction repo. Parity forces full fetch.)
      await fetchAll();
    } catch (e) {
      throw Exception('Failed to release reserved item: $e');
    }
  }

  @override
  Future<void> createItem({
    required String name,
    required String category,
    required int initialStock,
    String? storageLocation,
    String? unit,
    String? serialNumber,
    String? modelNumber,
    int? targetStock,
    int? lowStockThreshold,
    String? imageUrl,
  }) async {
    try {
      final trimmedName = name.trim();
      final trimmedCategory = category.trim();
      if (trimmedName.isEmpty) {
        throw Exception('Item name is required.');
      }
      if (trimmedCategory.isEmpty) {
        throw Exception('Category is required.');
      }
      if (initialStock < 0) {
        throw Exception('Initial stock cannot be negative.');
      }

      final now = DateTime.now().toUtc().toIso8601String();
      final location = (storageLocation ?? '').trim();
      final normalizedUnit = (unit ?? '').trim().isEmpty ? 'pcs' : unit!.trim();

      await _client.from('inventory').insert({
        'item_name': trimmedName,
        'base_name': trimmedName,
        'category': trimmedCategory,
        'item_type': 'equipment',
        'stock_total': initialStock,
        'stock_available': initialStock,
        'qty_good': initialStock,
        'qty_damaged': 0,
        'qty_maintenance': 0,
        'qty_lost': 0,
        'status': 'Good',
        'storage_location': location.isEmpty ? 'lower_warehouse' : location,
        'unit': normalizedUnit,
        'serial_number': serialNumber?.trim().isNotEmpty == true
            ? serialNumber!.trim()
            : null,
        'model_number': modelNumber?.trim().isNotEmpty == true
            ? modelNumber!.trim()
            : null,
        'target_stock': targetStock ?? 0,
        'low_stock_threshold': lowStockThreshold ?? 20,
        'image_url': imageUrl,
        'created_at': now,
        'updated_at': now,
      });

      await fetchAll();
    } catch (e) {
      throw Exception('Failed to create inventory item: $e');
    }
  }
}

List<InventoryVariant> inventoryVariantsFromModelMaps(
  List<Map<String, dynamic>> maps,
) {
  final out = <InventoryVariant>[];
  for (final v in maps) {
    try {
      out.add(inventoryVariantFromJsonMap(v));
    } catch (_) {}
  }
  return out;
}

/// 🛡️ GLOBAL ISOLATE WORKER: Parses and maps inventory items off the main thread.
List<InventoryItem> _parseAndMapItems(List<dynamic> data) {
  final out = <InventoryItem>[];
  for (final raw in data) {
    if (raw is! Map) continue;
    final Map<String, dynamic> json;
    try {
      json = Map<String, dynamic>.from(raw);
    } catch (_) {
      continue;
    }
    try {
      final model = InventoryModel.fromJson(json);

      final qtyGood = model.qtyGood;
      final qtyDamaged = model.qtyDamaged;
      final qtyMaintenance = model.qtyMaintenance;
      final qtyLost = model.qtyLost;
      final expiryRaw = json['expiry_date'] as String?;
      final expiryDate = expiryRaw != null ? DateTime.tryParse(expiryRaw) : null;
      final expiryAlertDays = (json['expiry_alert_days'] as num?)?.toInt() ?? 15;

      final variants = inventoryVariantsFromModelMaps(model.variants);

      out.add(
        InventoryItem(
          id: model.id,
          name: model.name,
          description: model.description,
          category: model.category,
          totalStock: model.quantity,
          availableStock: model.available,
          location:
              model.location.isNotEmpty
                  ? model.location
                  : (model.primaryLocation ?? ''),
          qrCode: model.qrCode,
          status: model.status,
          code: model.code,
          modelNumber: model.modelNumber,
          minStockLevel: model.minStockLevel,
          targetStock: model.targetStock,
          unit: model.unit,
          imageUrl: StorageUtils.resolveAssetUrl(model.imageUrl),
          restockAlertEnabled: model.restockAlertEnabled,
          lastUpdated: model.updatedAt,
          expiryDate: expiryDate,
          expiryAlertDays: expiryAlertDays,
          qtyGood: qtyGood,
          qtyDamaged: qtyDamaged,
          qtyMaintenance: qtyMaintenance,
          qtyLost: qtyLost,
          aggregateTotal: model.aggregateTotal,
          aggregateAvailable: model.aggregateAvailable,
          variants: variants,
        ),
      );
    } catch (_) {
      // Skip one bad API row instead of failing the entire sync + Isar write.
    }
  }
  return out;
}
