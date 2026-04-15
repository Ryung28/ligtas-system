import 'package:flutter/foundation.dart';

enum AnomalySeverity { critical, warning, info }
enum AnomalyCategory { depletion, operational, security, logistics, stagnation }

/// 🛡️ STRATEGIC ENTITY: Standardized (Generation-Free)
/// Converted from Freezed to prevent build_runner desyncs in the Analyst Terminal.
class ResourceAnomaly {
  final String id;
  final int? inventoryId;
  final String itemName;
  final String reason;
  final AnomalyCategory category;
  final int currentStock;
  final int thresholdStock;
  final int? maxStock; // 🛡️ NEW: ADAPTIVE MAX FALLBACK
  final AnomalySeverity severity;
  final DateTime? detectedAt;
  final String? imageUrl; // 🛡️ NEW: VISUAL EVIDENCE HANDLE

  final int qtyGood;
  final int qtyDamaged;
  final int qtyMaintenance;
  final int qtyLost;

  const ResourceAnomaly({
    required this.id,
    this.inventoryId,
    required this.itemName,
    required this.reason,
    this.category = AnomalyCategory.depletion,
    this.currentStock = 0,
    this.thresholdStock = 0,
    this.maxStock,
    this.severity = AnomalySeverity.warning,
    this.detectedAt,
    this.imageUrl,
    this.qtyGood = 0,
    this.qtyDamaged = 0,
    this.qtyMaintenance = 0,
    this.qtyLost = 0,
  });

  /// ── VISUAL GETTERS (UI Parity) ──
  /// Restores compatibility with AnomalyCard widgets without code generation.
  String get serviceStatus {
    switch (category) {
      case AnomalyCategory.depletion: return 'Depletion';
      case AnomalyCategory.operational: return 'Critical Failure';
      case AnomalyCategory.logistics: return 'Logistics Lag';
      case AnomalyCategory.security: return 'Security Alert';
      case AnomalyCategory.stagnation: return 'Stagnation';
    }
  }

  String get shelfActionLabel {
    if (category == AnomalyCategory.depletion) return 'Restock Item';
    if (category == AnomalyCategory.operational) return 'Triage Unit';
    if (category == AnomalyCategory.logistics) return 'Verify Queue';
    return 'Audit Asset';
  }

  factory ResourceAnomaly.fromJson(Map<String, dynamic> json) {
    try {
      final metadata = (json['metadata'] as Map<String, dynamic>? ?? {});
      
      return ResourceAnomaly(
        id: json['id'].toString(),
        inventoryId: (metadata['item_id'] ?? metadata['inventory_id'] ?? json['inventory_id']) as int?,
        itemName: json['title']?.toString() ?? 'System Alert',
        reason: json['message']?.toString() ?? 'Check required.',
        imageUrl: metadata['image_url']?.toString(),
        category: _mapCategory(json['category'] as String?),
        severity: _mapSeverity(json['priority'] as String?),
        currentStock: (metadata['stock_available'] as num?)?.toInt() ?? 0,
        thresholdStock: (metadata['low_stock_threshold'] ?? metadata['minStockLevel'] as num?)?.toInt() ?? 0, // 🛡️ NO MORE GHOST 5
        maxStock: (metadata['target_stock'] ?? metadata['max_stock'] ?? metadata['goal'] as num?)?.toInt(),
        detectedAt: json['created_at'] != null 
            ? DateTime.parse(json['created_at']) 
            : DateTime.now(),
        qtyGood: (metadata['qty_good'] as num?)?.toInt() ?? 0,
        qtyDamaged: (metadata['qty_damaged'] as num?)?.toInt() ?? 0,
        qtyMaintenance: (metadata['qty_maintenance'] as num?)?.toInt() ?? 0,
        qtyLost: (metadata['qty_lost'] as num?)?.toInt() ?? 0,
      );
    } catch (e) {
      debugPrint('🚨 LIGTAS-CORE: Faulty anomaly deserialization: $e');
      rethrow;
    }
  }

  static AnomalyCategory _mapCategory(String? val) {
    switch (val?.toUpperCase()) {
      case 'INVENTORY': return AnomalyCategory.depletion;
      case 'LOGISTICS': return AnomalyCategory.logistics;
      case 'OVERDUE': return AnomalyCategory.logistics;
      case 'OPERATIONAL': return AnomalyCategory.operational;
      default: return AnomalyCategory.depletion;
    }
  }

  static AnomalySeverity _mapSeverity(String? val) {
    if (val == 'CRITICAL') return AnomalySeverity.critical;
    if (val == 'WARNING') return AnomalySeverity.warning;
    return AnomalySeverity.info;
  }
}
