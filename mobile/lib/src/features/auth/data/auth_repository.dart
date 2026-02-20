import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/networking/supabase_client.dart';
import '../models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  // Get current user session
  Session? get currentSession => _supabase.auth.currentSession;
  
  // Get current user data mapped to UserModel
  Future<UserModel?> getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    
    return UserModel(
      id: user.id,
      email: user.email,
      displayName: user.userMetadata?['full_name'] as String? ?? user.userMetadata?['name'] as String?,
      phoneNumber: user.userMetadata?['phone_number'] as String?,
      organization: user.userMetadata?['organization'] as String?,
    );
  }

  // Google Sign In
  Future<void> signInWithGoogle({bool rememberMe = false}) async {
    // 🛡️ CRITICAL: Use the WEB CLIENT ID here, even for Android!
    // This allows Supabase to receive the 'idToken' for verification.
    const webClientId = '60786143704-9lhl4pt1ojr9q5t06494dbhs7ccv8d62.apps.googleusercontent.com';

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
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  // Standard Sign Up
  Future<void> signUp({
    required String email, 
    required String password, 
    required String name,
    String? phone,
    String? organization
  }) async {
    await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': name,
        'phone_number': phone,
        'organization': organization,
      },
    );
  }

  // Sign Out (Handles both Supabase and Google)
  Future<void> signOut() async {
    final googleSignIn = GoogleSignIn();
    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.signOut();
    }
    await _supabase.auth.signOut();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(Supabase.instance.client);
});
