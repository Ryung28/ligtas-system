import 'package:flutter/foundation.dart';

enum AnomalySeverity { critical, warning, info }

/// Mirrors the 4 categories from the system_intel view:
/// INVENTORY → depletion, LOGISTICS → logistics, OVERDUE → overdue, ACCESS → access
enum AnomalyCategory { depletion, operational, security, logistics, stagnation, overdue, access }

/// 🛡️ STRATEGIC ENTITY: Standardized (Generation-Free)
/// Converted from Freezed to prevent build_runner desyncs in the Analyst Terminal.
class ResourceAnomaly {
  final String id;
  final int? inventoryId; // Local record ID (specfic warehouse row)
  final int? itemId;      // Global item ID (cross-warehouse reference)
  /// [storage_locations] / [inventory.location_registry_id] for this row.
  final int? locationRegistryId;
  final String itemName;
  final String? baseName;
  final String? variantLabel;
  final Map<String, dynamic>? packagingJson;
  /// For exploded bulk-packaging alerts: the specific batch id (e.g. "abc123") inside
  /// packaging_json.batches. Null for aggregate/non-bulk anomalies.
  final String? batchId;
  final String? storageLocation;
  final String reason;
  final AnomalyCategory category;
  final int currentStock;
  final int thresholdStock;
  final int? maxStock; 
  final int aggregateAvailable;
  final int aggregateTotal;
  final String unit;
  final AnomalySeverity severity;
  final DateTime? detectedAt;
  final String? imageUrl; 
  final List<ResourceAnomaly> children;


  // 🛰️ OVERDUE CONTEXT (enriched from borrow_logs via system_intel view)
  final int? borrowId;          // borrow_logs.id — used for force-return
  final String? borrowerName;
  final String? borrowerContact; // borrow_logs.borrower_contact (phone)
  final String? borrowerEmail;   // borrow_logs.borrower_email
  final String? borrowerOrg;     // borrow_logs.borrower_organization
  final int borrowedQty;         // borrow_logs.quantity
  final DateTime? dueDate;       // borrow_logs.expected_return_date
  final DateTime? borrowedAt;    // borrow_logs.borrow_date
  final String? approvedByName;  // borrow_logs.approved_by_name
  final String? releasedByName;  // borrow_logs.released_by_name
  final String? platformOrigin;  // borrow_logs.platform_origin

  final int qtyGood;
  final int qtyDamaged;
  final int qtyMaintenance;
  final int qtyLost;

  const ResourceAnomaly({
    required this.id,
    this.inventoryId,
    this.itemId,
    this.locationRegistryId,
    required this.itemName,
    this.baseName,
    this.variantLabel,
    this.packagingJson,
    this.batchId,
    this.storageLocation,
    required this.reason,
    this.category = AnomalyCategory.depletion,
    this.currentStock = 0,
    this.thresholdStock = 0,
    this.maxStock,
    this.aggregateAvailable = 0,
    this.aggregateTotal = 0,
    this.unit = 'pcs',
    this.severity = AnomalySeverity.warning,
    this.detectedAt,
    this.imageUrl,
    this.children = const [],
    this.borrowId,
    this.borrowerName,
    this.borrowerContact,
    this.borrowerEmail,
    this.borrowerOrg,
    this.borrowedQty = 0,
    this.dueDate,
    this.borrowedAt,
    this.approvedByName,
    this.releasedByName,
    this.platformOrigin,
    this.qtyGood = 0,
    this.qtyDamaged = 0,
    this.qtyMaintenance = 0,
    this.qtyLost = 0,
  });

  bool get isGroup => children.isNotEmpty;

  /// 🛡️ IDENTITY CHECK: Determines if this is a true "Bulk Packaging" item 
  /// (e.g. Box, Carton) vs just a group of physical locations.
  bool get isBulkPackaging => packagingJson != null && packagingJson!['enabled'] == true;

  /// Shelf quantity for UI. Prioritizes aggregate counts for bulk/multi-location items.
  int get displayStock {
    if (aggregateAvailable > 0) return aggregateAvailable;
    return currentStock;
  }

  /// Tactical Name: Prioritizes base name for headers, itemName for box identity.
  String get displayTitle => baseName ?? itemName;

  /// Identity of the specific physical container.
  String get containerIdentity {
    // 1. Explicit label from database (Gold Standard)
    if (variantLabel != null && variantLabel!.trim().isNotEmpty) {
      return variantLabel!;
    }

    // 2. Extract from item name (Legacy fallback)
    if (itemName != baseName && itemName.contains(' - ')) {
      return itemName.split(' - ').last;
    }
    
    // 3. Smart extraction from brackets
    if (itemName.contains(' (')) {
      final parts = itemName.split(' (');
      final lastPart = parts.last.replaceAll(')', '');
      // Filter out brand names or generic types that aren't container IDs
      final genericNames = {'mega', 'small', 'medium', 'large', 'pcs', 'kg', 'kgs'};
      if (!genericNames.contains(lastPart.toLowerCase())) {
        return lastPart;
      }
    }

    // 4. Fallback to Packaging Metadata — only if we have a usable location name
    if (packagingJson != null && storageLocation != null) {
      final type = packagingJson!['containerType']?.toString() ?? 'Box';
      return '$type @ $storageLocation';
    }

    return (itemName != baseName) ? itemName : 'Primary Container';
  }

  /// Standardized 'Max' Stock for progress bars.
  int get displayTotal => maxStock ?? (aggregateTotal > 0 ? aggregateTotal : currentStock);

  /// ── VISUAL GETTERS (UI Parity with Web Action Center) ──
  String get serviceStatus {
    switch (category) {
      case AnomalyCategory.depletion:  return 'Inventory';
      case AnomalyCategory.logistics:  return 'Logistics';
      case AnomalyCategory.overdue:    return 'Overdue';
      case AnomalyCategory.access:     return 'Access';
      case AnomalyCategory.operational: return 'Operational';
      case AnomalyCategory.security:   return 'Security';
      case AnomalyCategory.stagnation: return 'Stagnation';
    }
  }

  /// Category-based color index mirroring the Web Action Center palette.
  /// Consumers map this to actual colours (e.g. in AnomalyCard).
  AnomalyCategoryTheme get categoryTheme {
    switch (category) {
      case AnomalyCategory.depletion:  return AnomalyCategoryTheme.amber;
      case AnomalyCategory.logistics:  return AnomalyCategoryTheme.blue;
      case AnomalyCategory.overdue:    return AnomalyCategoryTheme.red;
      case AnomalyCategory.access:     return AnomalyCategoryTheme.purple;
      case AnomalyCategory.operational: return AnomalyCategoryTheme.red;
      case AnomalyCategory.security:   return AnomalyCategoryTheme.purple;
      case AnomalyCategory.stagnation: return AnomalyCategoryTheme.blue;
    }
  }

  String get shelfActionLabel {
    switch (category) {
      case AnomalyCategory.depletion:   return 'Restock Item';
      case AnomalyCategory.operational: return 'Triage Unit';
      case AnomalyCategory.logistics:   return 'Verify Queue';
      case AnomalyCategory.overdue:     return 'Chase Return';
      case AnomalyCategory.access:      return 'Review Request';
      case AnomalyCategory.security:    return 'Audit Asset';
      case AnomalyCategory.stagnation:  return 'Audit Asset';
    }
  }

  ResourceAnomaly copyWith({
    String? id,
    int? inventoryId,
    int? locationRegistryId,
    List<ResourceAnomaly>? children,
    String? variantLabel,
    String? batchId,
    String? itemName,
    String? baseName,
    String? storageLocation,
    String? reason,
    AnomalyCategory? category,
    Map<String, dynamic>? packagingJson,
    int? currentStock,
    int? thresholdStock,
    int? maxStock,
    int? aggregateAvailable,
    int? aggregateTotal,
    String? unit,
    AnomalySeverity? severity,
    DateTime? detectedAt,
    String? imageUrl,
  }) {
    return ResourceAnomaly(
      id: id ?? this.id,
      inventoryId: inventoryId ?? this.inventoryId,
      itemId: itemId,
      locationRegistryId: locationRegistryId ?? this.locationRegistryId,
      itemName: itemName ?? this.itemName,
      baseName: baseName ?? this.baseName,
      variantLabel: variantLabel ?? this.variantLabel,
      packagingJson: packagingJson ?? this.packagingJson,
      batchId: batchId ?? this.batchId,
      storageLocation: storageLocation ?? this.storageLocation,
      reason: reason ?? this.reason,
      category: category ?? this.category,
      currentStock: currentStock ?? this.currentStock,
      thresholdStock: thresholdStock ?? this.thresholdStock,
      maxStock: maxStock ?? this.maxStock,
      aggregateAvailable: aggregateAvailable ?? this.aggregateAvailable,
      aggregateTotal: aggregateTotal ?? this.aggregateTotal,
      unit: unit ?? this.unit,
      severity: severity ?? this.severity,
      detectedAt: detectedAt ?? this.detectedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      children: children ?? this.children,
      borrowId: borrowId,
      borrowerName: borrowerName,
      borrowerContact: borrowerContact,
      borrowerEmail: borrowerEmail,
      borrowerOrg: borrowerOrg,
      borrowedQty: borrowedQty,
      dueDate: dueDate,
      borrowedAt: borrowedAt,
      approvedByName: approvedByName,
      releasedByName: releasedByName,
      platformOrigin: platformOrigin,
      qtyGood: qtyGood,
      qtyDamaged: qtyDamaged,
      qtyMaintenance: qtyMaintenance,
      qtyLost: qtyLost,
    );
  }

  factory ResourceAnomaly.fromJson(Map<String, dynamic> json) {
    try {
      final metadata = (json['metadata'] as Map<String, dynamic>? ?? {});
      
      return ResourceAnomaly(
        id: json['id'].toString(),
        inventoryId: _readNullableInt(metadata['inventory_id'] ?? json['inventory_id']),
        itemId: _readNullableInt(metadata['item_id']),
        locationRegistryId: _readNullableInt(metadata['location_registry_id']),
        itemName: json['title']?.toString() ?? metadata['item_name']?.toString() ?? 'System Alert',
        baseName: (metadata['base_name'] ?? metadata['item_name'])?.toString(),
        variantLabel: metadata['variant_label']?.toString(),
        packagingJson: metadata['packaging_json'] is Map<String, dynamic> 
            ? metadata['packaging_json'] as Map<String, dynamic> 
            : null,
        storageLocation: (metadata['storage_location'] ?? metadata['location'])?.toString(),
        reason: json['message']?.toString() ?? 'Check required.',
        imageUrl: metadata['image_url']?.toString(),
        category: _mapCategory(json['category'] as String?),
        severity: _mapSeverity(json['priority'] as String?),
        currentStock: (metadata['stock_available'] as num?)?.toInt() ?? 0,
        thresholdStock: (metadata['low_stock_threshold'] ?? metadata['minStockLevel'] as num?)?.toInt() ?? 0,
        maxStock: (metadata['target_stock'] ?? metadata['max_stock'] ?? metadata['goal'] as num?)?.toInt(),
        aggregateAvailable: (metadata['aggregate_available'] as num?)?.toInt() ?? 0,
        aggregateTotal: (metadata['aggregate_total'] as num?)?.toInt() ?? 0,
        unit: (metadata['unit'] as String?) ?? 'pcs',
        detectedAt: json['created_at'] != null 
            ? DateTime.parse(json['created_at']) 
            : DateTime.now(),
        // 🛰️ HYDRATE OVERDUE CONTEXT
        borrowId: (metadata['borrow_id'] as num?)?.toInt(),
        borrowerName: metadata['borrower_name']?.toString(),
        borrowerContact: metadata['borrower_contact']?.toString(),
        borrowerEmail: metadata['borrower_email']?.toString(),
        borrowerOrg: metadata['borrower_organization']?.toString(),
        borrowedQty: (metadata['quantity'] as num?)?.toInt() ?? 0,
        dueDate: DateTime.tryParse(
          (metadata['due_date'] ??
                  metadata['expected_return_date'] ??
                  metadata['return_date'] ??
                  json['expected_return_date'] ??
                  json['due_date'])
              ?.toString() ??
              '',
        ),
        borrowedAt: DateTime.tryParse(
          (metadata['borrowed_at'] ??
                  metadata['borrow_date'] ??
                  metadata['handed_at'] ??
                  json['borrowed_at'] ??
                  json['borrow_date'])
              ?.toString() ??
              '',
        ),
        approvedByName: metadata['approved_by_name']?.toString(),
        releasedByName: (metadata['released_by_name'] ?? metadata['handed_by'])?.toString(),
        platformOrigin: metadata['platform_origin']?.toString(),
        qtyGood: (metadata['qty_good'] as num?)?.toInt() ?? 0,
        qtyDamaged: (metadata['qty_damaged'] as num?)?.toInt() ?? 0,
        qtyMaintenance: (metadata['qty_maintenance'] as num?)?.toInt() ?? 0,
        qtyLost: (metadata['qty_lost'] as num?)?.toInt() ?? 0,
      );
    } catch (e) {
      debugPrint('🚨 ResQTrack-CORE: Faulty anomaly deserialization: $e');
      rethrow;
    }
  }

  static int? _readNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static AnomalyCategory _mapCategory(String? val) {
    switch (val?.toUpperCase()) {
      case 'INVENTORY':   return AnomalyCategory.depletion;
      case 'LOGISTICS':   return AnomalyCategory.logistics;
      case 'OVERDUE':     return AnomalyCategory.overdue;
      case 'ACCESS':      return AnomalyCategory.access;
      case 'OPERATIONAL': return AnomalyCategory.operational;
      default:            return AnomalyCategory.depletion;
    }
  }

  static AnomalySeverity _mapSeverity(String? val) {
    if (val == 'CRITICAL') return AnomalySeverity.critical;
    if (val == 'WARNING') return AnomalySeverity.warning;
    return AnomalySeverity.info;
  }
}

/// Palette tokens that map AnomalyCategory to a visual theme.
/// Keeps colour decisions out of the entity layer.
enum AnomalyCategoryTheme { amber, blue, red, purple }

int _severitySortRank(AnomalySeverity s) {
  switch (s) {
    case AnomalySeverity.critical:
      return 0;
    case AnomalySeverity.warning:
      return 1;
    case AnomalySeverity.info:
      return 2;
  }
}

/// Web dashboard [LogisticsIntelQueue] / Action Center order:
/// CRITICAL → WARNING → INFO, then [detectedAt] descending (newest first),
/// then stable [id]. Matches `priorityWeight` + `created_at` sort on web.
List<ResourceAnomaly> sortResourceAnomaliesLikeActionCenter(List<ResourceAnomaly> items) {
  int actionCenterPriority(AnomalySeverity s) {
    switch (s) {
      case AnomalySeverity.critical:
        return 3;
      case AnomalySeverity.warning:
        return 2;
      case AnomalySeverity.info:
        return 1;
    }
  }

  final out = List<ResourceAnomaly>.from(items);
  out.sort((a, b) {
    final pa = actionCenterPriority(a.severity);
    final pb = actionCenterPriority(b.severity);
    if (pa != pb) return pb.compareTo(pa);

    final ta = a.detectedAt;
    final tb = b.detectedAt;
    if (ta != null && tb != null) {
      final byTime = tb.compareTo(ta);
      if (byTime != 0) return byTime;
    } else if (ta == null && tb != null) {
      return 1;
    } else if (ta != null && tb == null) {
      return -1;
    }
    return a.id.compareTo(b.id);
  });
  return out;
}

/// Sort by [ResourceAnomaly.detectedAt] ascending or descending.
/// Missing timestamps sort last when [newestFirst] is true, first when false;
/// then severity (critical first), then stable [id].
List<ResourceAnomaly> sortResourceAnomaliesByRecency(
  List<ResourceAnomaly> items, {
  required bool newestFirst,
}) {
  final out = List<ResourceAnomaly>.from(items);
  out.sort((a, b) {
    final ta = a.detectedAt;
    final tb = b.detectedAt;
    if (ta == null && tb != null) return newestFirst ? 1 : -1;
    if (ta != null && tb == null) return newestFirst ? -1 : 1;
    if (ta != null && tb != null) {
      final byTime = newestFirst ? tb.compareTo(ta) : ta.compareTo(tb);
      if (byTime != 0) return byTime;
    }
    final bySev = _severitySortRank(a.severity).compareTo(_severitySortRank(b.severity));
    if (bySev != 0) return bySev;
    return a.id.compareTo(b.id);
  });
  return out;
}

/// Pure chronological order (e.g. alert queue time toggle). Not Action Center order.
List<ResourceAnomaly> sortResourceAnomaliesNewestFirst(List<ResourceAnomaly> items) {
  return sortResourceAnomaliesByRecency(items, newestFirst: true);
}
