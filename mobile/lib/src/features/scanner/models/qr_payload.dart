import 'dart:convert';

/// Represents the data structure in the LIGTAS QR Code generated from the web dashboard.
class LigtasQrPayload {
  final String protocol;
  final String version;
  final String action;
  final int itemId;
  final String itemName;

  LigtasQrPayload({
    required this.protocol,
    required this.version,
    required this.action,
    required this.itemId,
    required this.itemName,
  });

  /// Validates and parses a JSON string into a LigtasQrPayload.
  /// Returns null if the format is invalid or not a Ligtas protocol QR.
  static LigtasQrPayload? tryParse(String rawData) {
    try {
      final Map<String, dynamic> data = jsonDecode(rawData);
      
      // Strict protocol check
      if (data['protocol'] != 'ligtas') return null;
      
      return LigtasQrPayload(
        protocol: data['protocol'] as String,
        version: data['version'] as String,
        action: data['action'] as String,
        // Senior Dev Fix: Handle both int and string ID types safely
        itemId: int.tryParse(data['itemId'].toString()) ?? 0,
        itemName: (data['itemName'] ?? 'Unknown Item').toString(),
      );
    } catch (_) {
      return null;
    }
  }

  bool get isBorrowAction => action == 'borrow';
  bool get isReturnAction => action == 'return';
}
