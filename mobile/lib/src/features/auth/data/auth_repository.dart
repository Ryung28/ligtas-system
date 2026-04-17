import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/networking/supabase_client.dart';
import '../../../core/errors/app_exceptions.dart';
import '../domain/models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AuthRepository {
  final SupabaseClient _supabase;

  // 🛡️ THE SINGLETON DOORMAN
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '135620164017-ql5vhj0rmgqrpaqffavphqr6heodeu9u.apps.googleusercontent.com',
    scopes: ['email', 'profile', 'openid'],
  );

  AuthRepository(this._supabase);

  // Get current user session
  Session? get currentSession => _supabase.auth.currentSession;
  
  // Get current user data mapped to UserModel
  Future<UserModel?> getCurrentUser() async {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) return null;
    
    // Fetch profile data from user_profiles
    final profileData = await _supabase
        .from('user_profiles')
        .select()
        .eq('id', authUser.id)
        .maybeSingle();

    if (profileData == null) {
      // Fallback to basic metadata if profile doesn't exist yet
      return UserModel(
        id: authUser.id,
        email: authUser.email,
        displayName: authUser.userMetadata?['full_name'] as String? ?? authUser.userMetadata?['name'] as String?,
        phoneNumber: authUser.userMetadata?['phone_number'] as String?,
        organization: authUser.userMetadata?['organization'] as String?,
      );
    }

    return UserModel.fromSupabase(profileData);
  }

  // 🛡️ THE SMOKING GUN RECOVERY: Added return type to detect cancellation
  Future<GoogleSignInAccount?> signInWithGoogle({bool rememberMe = false}) async {
    debugPrint('📡 [Auth-Guard] Initiating Recovery Handshake...');

    try {
      // 🛡️ RESET: Clear existing state to prevent focus-lock and force account selection
      await _googleSignIn.signOut().catchError((_) => null);
      
      // Interactive Picker: Always force selection when this method is called manually
      debugPrint('📡 [Auth-Guard] Launching Interactive Picker...');
      final googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        debugPrint('📡 [Auth-Guard] Picker cancelled by user.');
        return null; 
      }

      debugPrint('📡 [Auth-Guard] ✅ Account selected: ${googleUser.email}');

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) throw 'Google authentication failed: Missing ID Token';
      
      // Sign in with Supabase using the ID Token flow
      await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      debugPrint('📡 [Auth-Guard] 🏆 Session Established.');
      return googleUser;

    } on PlatformException catch (e) {
      debugPrint('🚨 [Auth-Guard] NATIVE_ERROR: Code: ${e.code} | Msg: ${e.message}');
      await _googleSignIn.signOut().catchError((_) => null);
      rethrow;
    } catch (e) {
      debugPrint('🚨 [Auth-Guard] FATAL_ERROR: $e');
      await _googleSignIn.signOut().catchError((_) => null);
      rethrow;
    }
  }

  // Standard Sign In
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      throw ExceptionHandler.fromException(e);
    }
  }

  // Standard Sign Up
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
        data: {
          'full_name': name,
          'phone_number': phone,
          'organization': organization,
        },
      );
      return response.user != null;
    } catch (e) {
      throw ExceptionHandler.fromException(e);
    }
  }

  // Sign Out (Handles both Supabase and Google)
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut().catchError((_) => null);
      await _supabase.auth.signOut();
    } catch (e) {
      throw ExceptionHandler.fromException(e);
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(Supabase.instance.client);
});
