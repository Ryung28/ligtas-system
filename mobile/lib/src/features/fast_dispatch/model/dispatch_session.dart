import 'package:freezed_annotation/freezed_annotation.dart';
import '../../scanner/models/qr_payload.dart';

part 'dispatch_session.freezed.dart';
part 'dispatch_session.g.dart';

@freezed
class BorrowerInfo with _$BorrowerInfo {
  const factory BorrowerInfo({
    required String id,
    required String name,
    required String contact,
    String? office,
    @Default(false) bool isDraft,
  }) = _BorrowerInfo;

  factory BorrowerInfo.fromPersonPayload(LigtasQrPayload payload) {
    return payload.maybeWhen(
      person: (id, name, role, phone) => BorrowerInfo(
        id: id,
        name: name,
        contact: phone ?? '',
        office: role,
        isDraft: false,
      ),
      orElse: () => throw Exception('Invalid payload for borrower'),
    );
  }

  factory BorrowerInfo.fromJson(Map<String, dynamic> json) => _$BorrowerInfoFromJson(json);
}

@freezed
class DispatchItem with _$DispatchItem {
  const factory DispatchItem({
    required int inventoryId,
    required String itemName,
    String? imageUrl,
    @Default(1) int quantity,
    @Default(0) int stockAvailable,
    @Default(0) int targetStock,
    @Default(20) int lowStockThreshold,
  }) = _DispatchItem;

  factory DispatchItem.fromJson(Map<String, dynamic> json) => _$DispatchItemFromJson(json);
}

@freezed
class DispatchState with _$DispatchState {
  const factory DispatchState({
    BorrowerInfo? borrower,
    DispatchItem? selectedItem,
    String? approvedBy,
    @Default(false) bool isSubmitting,
    String? error,
  }) = _DispatchState;
}
