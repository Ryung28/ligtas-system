import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'qr_payload.freezed.dart';
part 'qr_payload.g.dart';

@freezed
class LigtasQrPayload with _$LigtasQrPayload {
  const LigtasQrPayload._();

  const factory LigtasQrPayload({
    required String protocol,
    required String version,
    required String action,
    required int itemId,
    required String itemName,
  }) = _LigtasQrPayload;

  factory LigtasQrPayload.fromJson(Map<String, dynamic> json) => _$LigtasQrPayloadFromJson(json);

  static LigtasQrPayload? tryParse(String rawData) {
    try {
      final Map<String, dynamic> data = jsonDecode(rawData);
      if (data['protocol'] != 'ligtas') return null;
      
      // Senior Dev Fix: Ensure itemId is treated correctly during parsing
      final processedData = Map<String, dynamic>.from(data);
      processedData['itemId'] = int.tryParse(data['itemId']?.toString() ?? '') ?? 0;
      processedData['itemName'] = (data['itemName'] ?? 'Unknown Item').toString();

      return LigtasQrPayload.fromJson(processedData);
    } catch (_) {
      return null;
    }
  }

  bool get isBorrowAction => action == 'borrow';
  bool get isReturnAction => action == 'return';
}
