import 'package:freezed_annotation/freezed_annotation.dart';
import '../../auth/models/user_model.dart';

part 'profile_state.freezed.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState({
    @Default(false) bool isLoading,
    @Default(true) bool pushNotificationsEnabled,
    @Default(false) bool biometricEnabled,
    @Default(false) bool isDarkMode,
    UserModel? user,
    String? errorMessage,
  }) = _ProfileState;
}

