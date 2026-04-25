import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../fast_dispatch/model/dispatch_session.dart';

class PersonnelRepository {
  final SupabaseClient _client;

  PersonnelRepository(this._client);

  /// 🛰️ Fetch Unified Personnel Registry
  /// Combines Official User Profiles and Historical Borrowers
  Future<List<BorrowerInfo>> fetchAllPersonnel() async {
    try {
      // 1. Fetch from User Profiles (Official Register)
      final profilesResp = await _client
          .from('user_profiles')
          .select('id, full_name, phone_number, department')
          .eq('status', 'active');

      // 2. Fetch unique historical borrowers from Logs
      final logsResp = await _client
          .from('borrow_logs')
          .select('borrower_name, borrower_contact, borrower_organization')
          .order('created_at', ascending: false)
          .limit(200);

      final Map<String, BorrowerInfo> registry = {};

      // Process Official Profiles first (Higher Priority)
      for (var row in (profilesResp as List)) {
        final name = row['full_name'] as String? ?? '';
        if (name.isEmpty) continue;
        
        registry[name.toLowerCase()] = BorrowerInfo(
          id: row['id'].toString(),
          name: name,
          contact: row['phone_number'] as String? ?? '',
          office: row['department'] as String? ?? '',
          isDraft: false,
        );
      }

      // Merge with Historical Logs (Only if not already in official registry)
      for (var row in (logsResp as List)) {
        final name = row['borrower_name'] as String? ?? '';
        if (name.isEmpty) continue;
        
        final key = name.toLowerCase();
        if (!registry.containsKey(key)) {
          registry[key] = BorrowerInfo(
            id: 'hist-$name',
            name: name,
            contact: row['borrower_contact'] as String? ?? '',
            office: row['borrower_organization'] as String? ?? '',
            isDraft: false,
          );
        }
      }

      return registry.values.toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      return [];
    }
  }
}

final personnelRepositoryProvider = Provider<PersonnelRepository>((ref) {
  return PersonnelRepository(Supabase.instance.client);
});

/// 🧠 Personnel Registry Cache (Eager Load)
final personnelRegistryProvider = FutureProvider<List<BorrowerInfo>>((ref) async {
  return ref.watch(personnelRepositoryProvider).fetchAllPersonnel();
});
