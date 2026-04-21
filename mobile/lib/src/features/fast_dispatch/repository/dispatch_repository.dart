import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/dispatch_session.dart';

class DispatchRepository {
  final SupabaseClient _client;

  DispatchRepository(this._client);

  /// 🔎 Search existing borrowers for auto-fill
  Future<List<BorrowerInfo>> searchBorrowers(String query) async {
    if (query.length < 2) return [];

    final response = await _client
        .from('borrowers') // Assuming this table exists based on previous conversations
        .select('id, full_name, phone, organization')
        .ilike('full_name', '%$query%')
        .limit(5);

    return (response as List).map((row) => BorrowerInfo(
      id: row['id'].toString(),
      name: row['full_name'] as String,
      contact: row['phone'] as String? ?? '',
      office: row['organization'] as String? ?? '',
      isDraft: false,
    )).toList();
  }

  /// 📤 Process the multi-item dispatch
  Future<void> submitDispatch({
    required BorrowerInfo borrower,
    required List<DispatchItem> items,
    required String approvedBy,
    required String releasedBy,
  }) async {
    // 🛡️ TACTICAL: This will be implemented in the next phase to use the bulk transaction API
    // For now, we simulate success
    await Future.delayed(const Duration(seconds: 1));
  }
}
