import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum EventType {
  assetOut,
  assetIn,
  requisitionApproved,
  requisitionRejected,
  systemSync,
  securityTrigger,
  maintenance,
  requisitionDenied,
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
  final String? quantityDelta;
  final String? locationSource;
  final String? locationTarget;
  final String? actorName;
  final String? actorAvatarUrl;
  final String? notes;
  
  // Visual Evidence Block
  final String? evidenceImageUrl;
  final String? referenceImageUrl;
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
    this.quantityDelta,
    this.locationSource,
    this.locationTarget,
    this.actorName,
    this.actorAvatarUrl,
    this.notes,
    this.evidenceImageUrl,
    this.referenceImageUrl,
    this.assetCategory,
    this.assetCondition,
    this.verifiedAt,
    this.telemetry = const {},
  });

  factory ActivityEvent.fromJson(Map<String, dynamic> json) {
    final invId = json['inventory_id'] ?? json['asset_id'] ?? json['referenceId'];
    return ActivityEvent(
      id: json['id']?.toString() ?? '',
      type: _mapType(json['type'] ?? json['transaction_type']),
      title: json['title'] ?? json['item_name'] ?? 'Log Event',
      subtitle: json['subtitle'] ?? (json['borrower_name'] != null ? 'User: ${json['borrower_name']}' : null),
      referenceId: json['referenceId']?.toString() ?? json['inventory_id']?.toString(),
      assetId: invId is int ? invId : (invId is String ? int.tryParse(invId) : null),
      status: _mapStatus(json['status']),
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : (json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now()),
      approvedBy: json['approvedBy'],
      priority: json['priority'],
      actorName: json['actorName'] ?? json['borrower_name'],
      locationTarget: json['locationTarget'] ?? json['borrowed_from_warehouse'],
      evidenceImageUrl: json['evidenceImageUrl'],
      referenceImageUrl: json['referenceImageUrl'],
      assetCondition: json['assetCondition'],
      verifiedAt: json['verifiedAt'] != null ? DateTime.parse(json['verifiedAt']) : null,
      notes: json['notes'],
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
