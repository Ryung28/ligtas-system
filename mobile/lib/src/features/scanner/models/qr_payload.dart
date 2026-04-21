import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'qr_payload.freezed.dart';
part 'qr_payload.g.dart';

@freezed
class LigtasQrPayload with _$LigtasQrPayload {
  const LigtasQrPayload._();

  const factory LigtasQrPayload.equipment({
    required String protocol,
    required String version,
    required String action,
    required int itemId,
    required String itemName,
  }) = _EquipmentPayload;

  const factory LigtasQrPayload.station({
    required String stationId,
    required String locationName,
  }) = _StationPayload;

  const factory LigtasQrPayload.person({
    required String personId,
    required String personName,
    @Default('Field Staff') String role,
  }) = _PersonPayload;

  factory LigtasQrPayload.fromJson(Map<String, dynamic> json) => _$LigtasQrPayloadFromJson(json);

  static LigtasQrPayload? tryParse(String rawData) {
    final sanitized = rawData.trim();
    
    // 🏛️ PRODUCTION-GRADE: URI RESOLVER (ligtas://)
    if (sanitized.startsWith('ligtas://')) {
      try {
        final uri = Uri.parse(sanitized);
        final id = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
        
        // 1. Station Hub Resolver (s/)
        if (uri.host == 'station' || uri.host == 's') {
          return LigtasQrPayload.station(
            stationId: id,
            locationName: uri.queryParameters['name'] ?? 'Tactical Hub',
          );
        }

        // 2. Equipment Asset Resolver (i/)
        if (uri.host == 'item' || uri.host == 'i') {
          return LigtasQrPayload.equipment(
            protocol: 'ligtas',
            version: uri.queryParameters['v'] ?? '2.0',
            action: uri.queryParameters['a'] ?? 'view',
            itemId: int.tryParse(id) ?? 0,
            itemName: uri.queryParameters['name'] ?? 'Unknown Item',
          );
        }

        // 3. Personnel Identity Resolver (p/ or u/)
        if (uri.host == 'person' || uri.host == 'p' || uri.host == 'u' || uri.host == 'user') {
          return LigtasQrPayload.person(
            personId: id,
            personName: uri.queryParameters['name'] ?? 'Unknown Personnel',
            role: uri.queryParameters['role'] ?? 'Field Staff',
          );
        }
      } catch (e) {
        debugPrint('🛡️ [Protocol-Resolver] Deep link mismatch: $e');
      }
    }

    // 🏛️ COMPATIBILITY PIPE: JSON Fallback (Legacy)
    try {
      if (sanitized.startsWith('{')) {
        final Map<String, dynamic> data = jsonDecode(sanitized);
        
        if (data.containsKey('sid')) {
          return LigtasQrPayload.station(
            stationId: data['sid'].toString(),
            locationName: data['loc']?.toString() ?? 'Station Hub',
          );
        }

        if (data['protocol'] == 'ligtas') {
          final processedData = Map<String, dynamic>.from(data);
          processedData['itemId'] = int.tryParse(data['itemId']?.toString() ?? '') ?? 0;
          processedData['itemName'] = (data['itemName'] ?? 'Unknown Item').toString();
          return LigtasQrPayload.fromJson(processedData);
        }
      }
    } catch (_) {}

    // 🏛️ TACTICAL FALLBACK: Pipe Parsing (Legacy)
    try {
      if (sanitized.contains('|')) {
        final parts = sanitized.split('|');
        final firstPart = parts[0];
        
        // 🛡️ STRIKE GUARD: Only treat numeric first segments as items.
        // This prevents staff tags (like EMP-001|John) from being 'eaten' as inventory.
        final itemId = int.tryParse(firstPart);
        if (itemId != null && itemId > 0) {
          return LigtasQrPayload.equipment(
            protocol: 'ligtas',
            version: '2.0',
            action: 'view',
            itemId: itemId,
            itemName: parts.length > 1 ? parts[1] : 'Unknown',
          );
        }

        // If not numeric, treat as Person (Compatibility with legacy staff tags)
        return LigtasQrPayload.person(
          personId: firstPart,
          personName: parts.length > 1 ? parts[1] : 'Unknown Personnel',
        );
      }
    } catch (_) {}

    return null;
  }
}
