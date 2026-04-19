import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/src/core/utils/storage_location_labels.dart';

String? _borrowSiteFromJson(Map<String, dynamic> json) {
  final raw = json['borrowed_from_warehouse'] ?? json['warehouse_id'];
  if (raw == null) return null;
  final s = raw.toString().trim();
  if (s.isEmpty) return null;
  return formatStorageLocationLabel(s);
}

enum EventType {
  assetOut,
  assetIn,
  requisitionApproved,
  requisitionRejected,
  systemSync,
  securityTrigger,
  maintenance,
  requisitionDenied,
  mixed,
}

enum EventStatus {
  transit,
  verified,
  critical,
  synced,
  pending,
  offline,
}

/// 🛡️ SENIOR DEV UNIFIED ENTITY: Manual Implementation
/// Bypasses Freezed to resolve code-gen desync and constructor mismatch errors.
class ActivityEvent {
  final String id;
  final EventType type;
  final String title;
  final String? subtitle;
  final String? referenceId;
  final int? assetId;
  final EventStatus status;
  final DateTime timestamp;
  final String? approvedBy;
  final String? priority;
  
  // Tactical Metadata
  final int quantity; // 🛡️ SSOT: Physical count of items
  final String? quantityDelta;
  final String? locationSource;
  final String? locationTarget;
  final String? actorName;
  final String? actorAvatarUrl;
  final String? notes;

  // 🛰️ NEW COMMAND CONTEXT (Logistics & Authorization)
  final String? approvedByName;
  final String? releasedByName;
  final String? borrowerOrganization;
  final String? borrowerContact;
  final String? createdOrigin;
  final String? lastUpdatedOrigin;
  
  // Visual Evidence Block (SSOT: Relative Paths)
  final String? evidencePath;
  final String? referencePath;
  final String? assetCategory;
  final String? assetCondition;
  final DateTime? verifiedAt;
  final Map<String, dynamic> telemetry;

  const ActivityEvent({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.referenceId,
    this.assetId,
    this.status = EventStatus.pending,
    required this.timestamp,
    this.approvedBy,
    this.priority,
    this.quantity = 1,
    this.quantityDelta,
    this.locationSource,
    this.locationTarget,
    this.actorName,
    this.actorAvatarUrl,
    this.notes,
    this.approvedByName,
    this.releasedByName,
    this.borrowerOrganization,
    this.borrowerContact,
    this.createdOrigin,
    this.lastUpdatedOrigin,
    this.evidencePath,
    this.referencePath,
    this.assetCategory,
    this.assetCondition,
    this.verifiedAt,
    this.telemetry = const {},
  });

  factory ActivityEvent.fromJson(Map<String, dynamic> json) {
    final invId = json['inventory_id'] ?? json['asset_id'] ?? json['referenceId'];
    
    // 🛡️ FORENSIC RESOLUTION: Map both naming conventions (camelCase/snake_case)
    final evidence = json['evidence_image_url'] ?? json['evidenceImageUrl'] ?? json['evidence_path'];
    final reference = json['reference_image_url'] ?? json['referenceImageUrl'] ?? json['reference_path'];

    return ActivityEvent(
      id: json['id']?.toString() ?? '',
      type: _mapType(json['type'] ?? json['transaction_type']),
      title: json['title'] ?? json['item_name'] ?? 'Log Event',
      subtitle: json['subtitle'] ?? (json['borrower_name'] != null ? 'User: ${json['borrower_name']}' : null),
      referenceId: json['referenceId']?.toString() ?? json['inventory_id']?.toString(),
      assetId: invId is int ? invId : (invId is String ? int.tryParse(invId) : null),
      status: _mapStatus(json['status']),
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : (json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now()),
      approvedBy: json['approvedBy'] ?? json['approved_by_user_id'],
      priority: json['priority'],
      quantity: json['quantity'] != null ? (json['quantity'] as num).toInt() : (json['quantity_borrowed'] != null ? (json['quantity_borrowed'] as num).toInt() : 1),
      actorName: json['actorName'] ?? json['borrower_name'],
      locationSource: _borrowSiteFromJson(json),
      locationTarget: json['locationTarget'] ?? json['borrowed_from_warehouse'],
      // 🛰️ HYDRATE NEW CONTEXT
      approvedByName: json['approved_by_name'] ?? json['approvedByName'],
      releasedByName: json['released_by_name'] ?? json['releasedByName'],
      borrowerOrganization: json['borrower_organization'] ?? json['organization'],
      borrowerContact: json['borrower_contact'] ?? json['contact'],
      createdOrigin: (json['created_origin'] ?? json['createdOrigin'])?.toString(),
      lastUpdatedOrigin: (json['last_updated_origin'] ?? json['lastUpdatedOrigin'])?.toString(),
      evidencePath: evidence?.toString(),
      referencePath: reference?.toString(),
      assetCondition: json['assetCondition'] ?? json['return_condition'],
      verifiedAt: json['verifiedAt'] != null ? DateTime.parse(json['verifiedAt']) : (json['verified_at'] != null ? DateTime.parse(json['verified_at']) : null),
      notes: json['notes'] ?? json['return_notes'] ?? json['purpose'],
    );
  }

  static EventType _mapType(dynamic type) {
    final t = type?.toString().toLowerCase();
    if (t == 'asset_in' || t == 'return') return EventType.assetIn;
    if (t == 'asset_out' || t == 'borrow') return EventType.assetOut;
    if (t == 'requisition_approved') return EventType.requisitionApproved;
    if (t == 'requisition_denied') return EventType.requisitionDenied;
    if (t == 'security_trigger') return EventType.securityTrigger;
    if (t == 'maintenance') return EventType.maintenance;
    return EventType.systemSync;
  }

  static EventStatus _mapStatus(dynamic status) {
    final s = status?.toString().toLowerCase();
    if (s == 'borrowed' || s == 'verified') return EventStatus.verified;
    if (s == 'pending') return EventStatus.pending;
    if (s == 'returned' || s == 'synced') return EventStatus.synced;
    return EventStatus.pending;
  }

  String get timeDisplay {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
