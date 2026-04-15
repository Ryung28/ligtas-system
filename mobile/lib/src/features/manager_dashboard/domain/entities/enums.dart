import 'package:freezed_annotation/freezed_annotation.dart';

enum EventType {
  @JsonValue('asset_out')
  assetOut,
  @JsonValue('asset_in')
  assetIn,
  @JsonValue('requisition_approved')
  requisitionApproved,
  @JsonValue('requisition_rejected')
  requisitionRejected,
  @JsonValue('system_sync')
  systemSync,
  @JsonValue('security_trigger')
  securityTrigger,
}

enum EventStatus {
  @JsonValue('transit')
  transit,
  @JsonValue('verified')
  verified,
  @JsonValue('critical')
  critical,
  @JsonValue('synced')
  synced,
  @JsonValue('pending')
  pending,
}
