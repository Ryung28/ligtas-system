import 'package:freezed_annotation/freezed_annotation.dart';

part 'presence.freezed.dart';
part 'presence.g.dart';

@freezed
class UserPresence with _$UserPresence {
  const factory UserPresence({
    @Default('') String userId,
    required DateTime lastSeen,
    @Default(false) bool isOnline,
  }) = _UserPresence;

  factory UserPresence.fromJson(Map<String, dynamic> json) => _$UserPresenceFromJson(json);
}
