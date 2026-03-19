import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_model.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = Initial;
  const factory AuthState.loading() = Loading;
  const factory AuthState.authenticated(UserModel user) = Authenticated;
  const factory AuthState.pendingApproval(UserModel user) = PendingApproval;
  const factory AuthState.error(String message) = Error;
}

extension AuthStateX on AuthState {
  AsyncValue<AuthState> toAsyncValue() => AsyncValue.data(this);
}
