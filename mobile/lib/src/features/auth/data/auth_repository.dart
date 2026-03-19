import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/networking/supabase_client.dart';
import '../../../core/errors/app_exceptions.dart';
import '../models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final SupabaseClient _supabase;

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

  // Google Sign In
  Future<void> signInWithGoogle({bool rememberMe = false}) async {
    // 🛡️ CRITICAL: Use the WEB CLIENT ID here, even for Android!
    // This allows Supabase to receive the 'idToken' for verification.
    const webClientId = '135620164017-ql5vhj0rmgqrpaqffavphqr6heodeu9u.apps.googleusercontent.com';

    // Set this to null if not using iOS yet to prevent initialization errors
    const String? iosClientId = null; 

    final googleSignIn = GoogleSignIn(
      clientId: iosClientId,
      serverClientId: webClientId,
    );

    // Force account choice if 'Remember Me' is NOT checked
    if (!rememberMe) {
      await googleSignIn.signOut();
    }

    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) throw 'Sign in cancelled by user';

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
    } catch (e) {
      // Ensure we sign out of Google if Supabase login fails or is cancelled
      // This allows the user to try again cleanly
      await googleSignIn.signOut();
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
  /// Returns [true] if user is auto-logged in, [false] if email verification is needed.
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
      
      // 🛡️ TACTICAL SHIFT: Email Confirmation is handle manually via Admin Approval
      // We always return true if the user record was successfully provisioned.
      return response.user != null;
    } catch (e) {
      throw ExceptionHandler.fromException(e);
    }
  }

  // Sign Out (Handles both Supabase and Google)
  Future<void> signOut() async {
    try {
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
      await _supabase.auth.signOut();
    } catch (e) {
      throw ExceptionHandler.fromException(e);
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(Supabase.instance.client);
});
