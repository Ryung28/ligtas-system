import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/dispatch_session.dart';

class DispatchRepository {
  final SupabaseClient _client;

  DispatchRepository(this._client);

  /// 🔎 Search historical activity for borrower auto-fill
  Future<List<BorrowerInfo>> searchBorrowers(String query) async {
    if (query.length < 2) return [];

    try {
      // Searching unique borrowers from past successful logs
      final response = await _client
          .from('borrow_logs')
          .select('borrower_name, borrower_contact, borrower_organization')
          .ilike('borrower_name', '%$query%')
          .limit(20);

      final List<BorrowerInfo> uniqueBorrowers = [];
      final seenNames = <String>{};

      for (var row in (response as List)) {
        final name = row['borrower_name'] as String;
        if (!seenNames.contains(name)) {
          uniqueBorrowers.add(BorrowerInfo(
            id: 'hist-$name',
            name: name,
            contact: row['borrower_contact'] as String? ?? '',
            office: row['borrower_organization'] as String? ?? '',
            isDraft: false,
          ));
          seenNames.add(name);
        }
      }
      return uniqueBorrowers;
    } catch (e) {
      return [];
    }
  }

  /// 🔍 Fetch live stock for an item
  Future<Map<String, dynamic>?> getItemDetails(int id) async {
    try {
      final response = await _client
          .from('inventory')
          .select('stock_available, stock_total, target_stock, low_stock_threshold, image_url, base_name, variant_label')
          .eq('id', id)
          .single();
      return response;
    } catch (e) {
      return null;
    }
  }

  /// 📤 Process the single-item voucher dispatch
  Future<void> submitDispatch({
    required BorrowerInfo borrower,
    required DispatchItem item,
    required String approvedBy,
    required String releasedBy,
    required String? releasedByUserId,
  }) async {
    await _client.rpc('mobile_dispatch_borrow_transaction', params: {
      'p_inventory_id': item.inventoryId,
      'p_item_name': item.itemName,
      'p_quantity': item.quantity,
      'p_borrower_name': borrower.name,
      'p_borrower_contact': borrower.contact,
      'p_borrower_organization': borrower.office ?? 'N/A',
      'p_approved_by_name': approvedBy.isNotEmpty ? approvedBy : null,
      'p_released_by_name': releasedBy,
      'p_released_by_user_id': releasedByUserId,
    });
  }
}

final dispatchRepositoryProvider = Provider<DispatchRepository>((ref) {
  return DispatchRepository(Supabase.instance.client);
});
