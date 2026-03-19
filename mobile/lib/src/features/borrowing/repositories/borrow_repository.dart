import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class BorrowRepository {
  Future<void> submitPreBorrowRequest(Map<String, dynamic> payload);
}

class BorrowRepositoryImpl implements BorrowRepository {
  final SupabaseClient _supabase;

  BorrowRepositoryImpl(this._supabase);

  @override
  Future<void> submitPreBorrowRequest(Map<String, dynamic> payload) async {
    try {
      // Architectural Constraint: Feature-First Siloing
      // Supabase client calls are isolated inside the Data layer (Repositories)
      await _supabase.from('borrow_logs').insert(payload);
      
      // Note: RLS violation on system_notifications is bypassed because
      // the new 'handle_new_borrow_request' PostgreSQL trigger runs as SECURITY DEFINER
      // automating the notification process securely on the Server-side.
    } on PostgrestException catch (e) {
      // Constraint: Require try-catch with typed PostgrestException handling
      throw Exception('Database Error (${e.code}): ${e.message}');
    } catch (e) {
      // Constraint: Do not catch generic Exception without type checking
      if (e is Exception) {
        throw Exception('An unexpected pre-borrow error occurred: $e');
      }
      rethrow;
    }
  }
}

// Global Provider for the Borrow UI
final borrowRepositoryProvider = Provider<BorrowRepository>((ref) {
  return BorrowRepositoryImpl(Supabase.instance.client);
});
