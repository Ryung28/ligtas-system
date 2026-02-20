import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/user_model.dart'; // Assuming this exists or I will create/use it

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(UserModel user) = _Authenticated;
  const factory AuthState.error(String message) = _Error;
}
