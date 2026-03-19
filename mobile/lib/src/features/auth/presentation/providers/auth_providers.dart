import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:mobile/src/features/auth/domain/models/auth_state.dart';
import 'package:mobile/src/features/auth/domain/models/user_model.dart';

part 'auth_providers.g.dart';

/// 🛡️ THE MASTER AUTH PROVIDER
/// Aliased for backward compatibility and to provide a clean AsyncValue<AuthState>
@riverpod
AsyncValue<AuthState> authState(AuthStateRef ref) {
  return ref.watch(authControllerProvider);
}

/// 👤 THE USER IDENTITY PROVIDER
/// Extracts the active UserModel if authenticated or pending.
@riverpod
UserModel? currentUser(CurrentUserRef ref) {
  final authState = ref.watch(authControllerProvider).valueOrNull;
  return authState?.whenOrNull(
    authenticated: (user) => user,
    pendingApproval: (user) => user,
  );
}

/// ⏳ THE GLOBAL LOADING PROVIDER
@riverpod
bool authLoading(AuthLoadingRef ref) {
  return ref.watch(authControllerProvider).isLoading;
}

/// 🏗️ THE ACCESS PERMISSION PROVIDER
@riverpod
bool hasActiveAccess(HasActiveAccessRef ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isActive ?? false;
}
