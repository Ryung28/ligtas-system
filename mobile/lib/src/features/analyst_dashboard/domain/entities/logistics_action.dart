import 'package:freezed_annotation/freezed_annotation.dart';

part 'logistics_action.freezed.dart';
part 'logistics_action.g.dart';

enum ActionType {
  @JsonValue('dispense')
  dispense,
  @JsonValue('dispose')
  dispose,
  @JsonValue('audit')
  audit,
  @JsonValue('return')
  returnItem,
  @JsonValue('adjustment')
  adjustment,
  @JsonValue('unknown')
  unknown,
}

enum ActionStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('completed')
  completed,
  @JsonValue('flagged')
  flagged,
  @JsonValue('unknown')
  unknown,
}

@freezed
class LogisticsAction with _$LogisticsAction {
  const LogisticsAction._();

  const factory LogisticsAction({
    @JsonKey(fromJson: _idToString) required String id,
    @JsonKey(name: 'item_name') required String itemName,
    @JsonKey(name: 'item_id', fromJson: _idToString) required String itemId, // 🛡️ SYNC: Changed from inventory_id to item_id
    @JsonKey(name: 'type', fromJson: _typeFromJson) required ActionType type, // 🛡️ SYNC: Correct DB column name
    @JsonKey(fromJson: _statusFromJson) @Default(ActionStatus.pending) ActionStatus status,
    @JsonKey(name: 'quantity', fromJson: _toInt) required int quantity, // 🛡️ SYNC: Correct DB column name
    @JsonKey(name: 'requester_id', fromJson: _idToString) String? requesterId,
    @JsonKey(name: 'requester_name', fromJson: _idToString) String? requesterName,
    @JsonKey(name: 'recipient_name', fromJson: _idToString) String? recipientName,
    @JsonKey(name: 'recipient_office', fromJson: _idToString) String? recipientOffice,
    @JsonKey(name: 'warehouse_id', fromJson: _idToString) String? warehouseId,
    @JsonKey(name: 'bin_location', fromJson: _idToString) String? binLocation,
    @JsonKey(name: 'forensic_note', fromJson: _idToString) String? forensicNote,
    @JsonKey(name: 'forensic_image_url', fromJson: _idToString) String? forensicImageUrl,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _LogisticsAction;

  factory LogisticsAction.fromJson(Map<String, dynamic> json) =>
      _$LogisticsActionFromJson(json);

  String get typeLabel {
    switch (type) {
      case ActionType.dispense: return 'DISPENSE REQUEST';
      case ActionType.dispose: return 'DISPOSAL AUDIT';
      case ActionType.audit: return 'PHYSICAL AUDIT';
      case ActionType.returnItem: return 'RETURN HANDOVER';
      case ActionType.adjustment: return 'STOCK INTAKE/CORRECTION';
      case ActionType.unknown: return 'UNKNOWN LOGISTICAL EVENT';
    }
  }

  String get actionVerb {
    switch (type) {
      case ActionType.dispense: return 'CONFIRM DISPENSE';
      case ActionType.dispose: return 'AUTHORIZE DISPOSAL';
      case ActionType.audit: return 'VERIFY STOCK';
      case ActionType.returnItem: return 'ACCEPT RETURN';
      case ActionType.adjustment: return 'RESTOCK ASSET';
      case ActionType.unknown: return 'REVIEW DATA';
    }
  }
}

String _idToString(dynamic value) {
  if (value == null) return '';
  return value.toString();
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  return int.tryParse(value.toString()) ?? 0;
}

ActionType _typeFromJson(String? value) {
  return ActionType.values.firstWhere(
    (e) => e.name == value || (value != null && value.toLowerCase() == 'return' && e == ActionType.returnItem),
    orElse: () => ActionType.unknown,
  );
}

ActionStatus _statusFromJson(String? value) {
  return ActionStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => ActionStatus.unknown,
  );
}
