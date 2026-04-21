import 'package:supabase_flutter/supabase_flutter.dart';
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

  /// 📤 Process the single-item voucher dispatch
  Future<void> submitDispatch({
    required BorrowerInfo borrower,
    required DispatchItem item,
    required String approvedBy,
    required String releasedBy,
    required String? releasedByUserId,
  }) async {
    // ⚔️ TACTICAL ATOMICITY: We perform the stock check, deduction, and log creation
    // To ensure the dashboard logs match immediately, we must hit 'borrow_logs'
    
    final now = DateTime.now().toIso8601String();

    try {
      // 1. Fetch current stock to prevent race conditions (simple safeguard)
      final inventoryResp = await _client
          .from('inventory')
          .select('stock_available, item_name')
          .eq('id', item.inventoryId)
          .single();
      
      final currentStock = inventoryResp['stock_available'] as int;
      if (currentStock < item.quantity) {
        throw Exception(
          'Insufficient stock for ${inventoryResp['item_name']}. Requested ${item.quantity}, available $currentStock.',
        );
      }

      // 2. Perform transaction-like sequential steps
      // Note: Ideally this would be a Supabase RPC function for true atomicity
      
      // Step A: Deduct stock
      await _client
          .from('inventory')
          .update({'stock_available': currentStock - item.quantity})
          .eq('id', item.inventoryId);

      // Step B: Create the Audit Log (The "Web Log")
      await _client.from('borrow_logs').insert({
        'inventory_id': item.inventoryId,
        'item_name': item.itemName,
        'quantity': item.quantity,
        'borrower_name': borrower.name,
        'borrower_contact': borrower.contact,
        'borrower_organization': borrower.office ?? 'N/A',
        'approved_by_name': approvedBy.isNotEmpty ? approvedBy : null,
        'released_by_name': releasedBy,
        'released_by_user_id': releasedByUserId,
        'transaction_type': 'borrow',
        'status': 'borrowed',
        'borrow_date': now,
        'platform_origin': 'Mobile',
        'created_origin': 'Mobile',
        'last_updated_origin': 'Mobile',
        'created_at': now,
      });

    } catch (e) {
      // Log the error and rethrow for the controller to handle UI feedback
      rethrow;
    }
  }
}
