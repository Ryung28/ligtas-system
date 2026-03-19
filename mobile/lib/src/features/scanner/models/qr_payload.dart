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
    // 1. Try JSON Parsing (Classic Protocol)
    try {
      if (rawData.startsWith('{')) {
        final Map<String, dynamic> data = jsonDecode(rawData);
        if (data['protocol'] != 'ligtas') return null;
        
        final processedData = Map<String, dynamic>.from(data);
        processedData['itemId'] = int.tryParse(data['itemId']?.toString() ?? '') ?? 0;
        processedData['itemName'] = (data['itemName'] ?? 'Unknown Item').toString();

        return LigtasQrPayload.fromJson(processedData);
      }
    } catch (_) {}

    // 2. Try Tactical Pipe Parsing (ID|SERIAL or ID|NAME)
    // Format: "123|LIG-001"
    try {
      if (rawData.contains('|')) {
        final parts = rawData.split('|');
        final itemId = int.tryParse(parts[0]) ?? 0;
        final identifier = parts.length > 1 ? parts[1] : 'Unknown';
        
        if (itemId > 0) {
          return LigtasQrPayload(
            protocol: 'ligtas',
            version: '2.0',
            action: 'view',
            itemId: itemId,
            itemName: identifier, // Use serial as display name if name not present
          );
        }
      }
    } catch (_) {}

    return null;
  }

  bool get isBorrowAction => action == 'borrow';
  bool get isReturnAction => action == 'return';
}
