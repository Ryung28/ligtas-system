import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile/src/core/networking/supabase_client.dart';
import 'package:mobile/src/core/errors/app_exceptions.dart';
import 'package:mobile/src/features/auth/domain/models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final SupabaseClient _supabase;

  // 🛡️ THE SINGLETON DOORMAN: Explicitly targeting Web Client ID
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '135620164017-ql5vhj0rmgqrpaqffavphqr6heodeu9u.apps.googleusercontent.com',
    scopes: ['email', 'profile', 'openid'],
  );

  AuthRepository(this._supabase);

  Session? get currentSession => _supabase.auth.currentSession;
  
  Future<UserModel?> getCurrentUser() async {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) return null;
    
    final profileData = await _supabase
        .from('user_profiles')
        .select()
        .eq('id', authUser.id)
        .maybeSingle();

    if (profileData == null) {
      return UserModel(
        id: authUser.id,
        email: authUser.email,
        displayName: authUser.userMetadata?['full_name'] as String? ?? authUser.userMetadata?['name'] as String?,
        phoneNumber: authUser.userMetadata?['phone_number'] as String?,
        organization: authUser.userMetadata?['organization'] as String?,
        role: 'loading',
      );
    }
    return UserModel.fromSupabase(profileData);
  }

  // 🛡️ THE SMOKING GUN RECOVERY: Simplified flow with return type to detect cancellation
  Future<GoogleSignInAccount?> signInWithGoogle({bool rememberMe = false}) async {
    debugPrint('📡 [Auth-Guard] Initiating Recovery Handshake...');

    try {
      // 1. Silent Attempt (Bypasses picker if already signed in)
      GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();
      
      // 2. Interactive Picker (Only if silent fails)
      if (googleUser == null) {
        debugPrint('📡 [Auth-Guard] Launching Interactive Picker...');
        googleUser = await _googleSignIn.signIn();
      }
      
      if (googleUser == null) {
        debugPrint('📡 [Auth-Guard] Picker closed or cancelled by user.');
        return null; // Exit gracefully so the controller can reset state
      }

      debugPrint('📡 [Auth-Guard] ✅ Account selected: ${googleUser.email}');
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) throw 'Google authentication failed: Missing ID Token';
      
      await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: googleAuth.accessToken,
      );

      debugPrint('📡 [Auth-Guard] 🏆 Session Established.');
      return googleUser;

    } on PlatformException catch (e) {
      debugPrint('🚨 [Auth-Guard] NATIVE_ERROR: ${e.code}');
      // Clear state on error to allow retry
      await _googleSignIn.signOut().catchError((_) => null);
      rethrow;
    } catch (e) {
      debugPrint('🚨 [Auth-Guard] FATAL_ERROR: $e');
      rethrow;
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      throw ExceptionHandler.fromException(e);
    }
  }

  Future<bool> signUp({
    required String email, 
    required String password, 
    required String name,
    String? phone,
    String? organization
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name, 'phone_number': phone, 'organization': organization},
      );
      return response.user != null;
    } catch (e) {
      throw ExceptionHandler.fromException(e);
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut().catchError((_) => null);
      await _supabase.auth.signOut();
    } catch (e) {
      throw ExceptionHandler.fromException(e);
    }
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository(Supabase.instance.client);
}
