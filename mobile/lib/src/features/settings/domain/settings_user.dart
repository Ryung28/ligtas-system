import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_user.freezed.dart';
part 'settings_user.g.dart';

@freezed
class SettingsUser with _$SettingsUser {
  const factory SettingsUser({
    @Default('') String id,
    @Default('') String email,
    @Default('') String fullName,
    @Default('') String role,
    @Default('') String lguName,
    @Default(null) String? avatarUrl,
    @Default(false) bool isOnline,
    @Default('') String lastSyncAt,
  }) = _SettingsUser;

  factory SettingsUser.fromJson(Map<String, dynamic> json) => _$SettingsUserFromJson(json);
}
