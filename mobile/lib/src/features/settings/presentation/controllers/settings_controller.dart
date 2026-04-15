import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../features/auth/data/auth_repository.dart';
import '../../../../features/profile/data/profile_repository.dart';
import '../../../../core/local_storage/isar_service.dart';
import '../../../../features_v2/inventory/presentation/providers/inventory_provider.dart';
import '../../domain/settings_user.dart';

part 'settings_controller.g.dart';

@riverpod
class SettingsController extends _$SettingsController {
  @override
  FutureOr<SettingsUser?> build() async {
    final authRepo = ref.read(authRepositoryProvider);
    final profileRepo = ref.read(profileRepositoryProvider);
    
    // 🛡️ AUTH CHECK: Verify session before fetching profile
    final sessionUser = await authRepo.getCurrentUser();
    if (sessionUser == null) return null;
    
    // 🛡️ PROFILE FETCH: Pull real curated metadata from user_profiles
    final profile = await profileRepo.fetchProfile(sessionUser.id);
    
    return SettingsUser(
      id: profile.id,
      email: profile.email ?? '',
      fullName: profile.fullName,
      role: profile.role,
      lguName: profile.organization ?? 'General CDRRMO',
      avatarUrl: null, // TODO: Support avatar uploads
      isOnline: true,
      lastSyncAt: DateTime.now().toIso8601String(), // Phase 2: Implement Real Sync Tracking
    );
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // 🛡️ SECURITY PROTOCOL: Nuclear purge of local cache
      await IsarService.clearAll();
      
      // 🛡️ STATE SANITATION: Flush transactional memory
      ref.invalidate(inventoryNotifierProvider);
      ref.invalidate(selectedCategoryProvider);
      ref.invalidate(inventorySearchQueryProvider);
      
      // 🛡️ AUTH TERMINATION: Sign out from Supabase
      await ref.read(authRepositoryProvider).signOut();
      return null;
    });
  }

  Future<void> syncProfile() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final authRepo = ref.read(authRepositoryProvider);
      final profileRepo = ref.read(profileRepositoryProvider);
      
      final sessionUser = await authRepo.getCurrentUser();
      if (sessionUser == null) return null;
      
      // 🛡️ SYNC PROTOCOL: Refreshing core inventory alongside profile
      await ref.read(inventoryNotifierProvider.notifier).refresh();
      
      final updated = await profileRepo.fetchProfile(sessionUser.id);
      
      return SettingsUser(
        id: updated.id,
        email: updated.email ?? '',
        fullName: updated.fullName,
        role: updated.role,
        lguName: updated.organization ?? 'General CDRRMO',
        isOnline: true,
        lastSyncAt: DateTime.now().toIso8601String(),
      );
    });
  }
}
