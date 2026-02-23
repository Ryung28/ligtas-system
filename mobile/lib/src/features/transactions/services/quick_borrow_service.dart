import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/networking/supabase_client.dart';

class QuickBorrowService {
  final _supabase = SupabaseService.client;

  /// Fetches all active borrowings for the current user for the given item.
  Future<List<Map<String, dynamic>>> getActiveBorrows(int itemId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final email = user.email;
      final fullName = user.userMetadata?['full_name'] as String?;
      
      var query = _supabase
          .from('borrow_logs')
          .select('*')
          .eq('inventory_id', itemId)
          .eq('status', 'borrowed');

      String orFilter = 'borrower_user_id.eq.${user.id}';
      if (email != null) orFilter += ',borrower_email.eq.$email';
      if (fullName != null) orFilter += ',borrower_name.ilike."$fullName"';

      final response = await query.or(orFilter);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('SYSTEM: Error detecting active borrows: $e');
      return [];
    }
  }

  /// Performs a return transaction (Full or Partial)
  Future<Map<String, dynamic>> executeReturn({
    required int logId,
    required int itemId,
    required int totalBorrowedQuantity,
    required int returnQuantity,
    String status = 'Good',
    String notes = '',
  }) async {
    try {
      if (returnQuantity > totalBorrowedQuantity) {
          return {'success': false, 'error': 'Cannot return more than borrowed.'};
      }

      final isPartial = returnQuantity < totalBorrowedQuantity;

      if (isPartial) {
        // Step 1: Update original log to reflect remaining quantity
        await _supabase.from('borrow_logs').update({
          'quantity': totalBorrowedQuantity - returnQuantity,
          'quantity_borrowed': totalBorrowedQuantity - returnQuantity,
        }).eq('id', logId);

        // Step 2: Create a NEW log entry for the returned portion (Audit Trail)
        final user = _supabase.auth.currentUser;
        await _supabase.from('borrow_logs').insert({
          'inventory_id': itemId,
          'item_name': 'Returned: (Partial)', 
          'quantity': returnQuantity,
          'borrower_name': user?.userMetadata?['full_name'] ?? 'System',
          'borrower_user_id': user?.id,
          'status': 'returned',
          'actual_return_date': DateTime.now().toIso8601String(),
          'return_notes': 'Partial return from Log #$logId. $notes',
        });
      } else {
        // FULL RETURN: Just mark current log as returned
        await _supabase.from('borrow_logs').update({
          'status': 'returned',
          'actual_return_date': DateTime.now().toIso8601String(),
          'return_notes': notes,
        }).eq('id', logId);
      }

      // 3. Increment inventory stock
      final itemRes = await _supabase
          .from('inventory')
          .select('stock_available')
          .eq('id', itemId)
          .single();
      
      final int currentStock = itemRes['stock_available'] ?? 0;
      await _supabase.from('inventory').update({
        'stock_available': currentStock + returnQuantity,
        'status': status, 
      }).eq('id', itemId);

      return {
        'success': true,
        'message': isPartial 
          ? 'Partial return of $returnQuantity units successful.' 
          : 'Full return of $returnQuantity units successful.',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Return failed: ${e.toString()}',
      };
    }
  }

  /// Performs a quick borrow transaction for the current user.
  /// 1. Fetches item details to ensure availability.
  /// 2. Inserts a borrow log (DB triggers handle stock decrement).
  Future<Map<String, dynamic>> executeQuickBorrow({
    required int itemId,
    required String itemName,
    int quantity = 1,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      // Skip auth check for dev/offline mode - rely on RLS/Backend to handle or accept 'anon'
      // if (user == null) { ... }

      // Step 1: Check inventory availability first (safety check)
      final inventoryResponse = await _supabase
          .from('inventory')
          .select('stock_available')
          .eq('id', itemId)
          .single();

      final int stockAvailable = inventoryResponse['stock_available'] ?? 0;
      if (stockAvailable < quantity) {
        return {
          'success': false, 
          'error': 'Insufficient stock. Only $stockAvailable units left.'
        };
      }

      // Step 2: Create the borrow log
      // We use the authenticated user's email/ID for the borrow log.
      // Note: We match the column names from your web 'borrow_logs' table.
      final logResponse = await _supabase.from('borrow_logs').insert({
        'inventory_id': itemId,
        'inventory_item_id': itemId.toString(), // For compatibility
        'item_name': itemName,
        'quantity': quantity,
        'quantity_borrowed': quantity, // For compatibility
        'borrower_name': user?.userMetadata?['full_name'] ?? user?.email?.split('@').first ?? 'Field Staff',
        'borrower_email': user?.email ?? '',
        'borrower_contact': user?.phone ?? '',
        'borrower_user_id': user?.id, // CRUCIAL: Link log to this user
        'borrowed_by': user?.id,      // Standard field
        'borrower_organization': 'CDRRMO Field Team', // Default for mobile app
        'purpose': 'Field Deployment (via QR Scan)',
        'transaction_type': 'borrow',
        'status': 'borrowed',
        'borrow_date': DateTime.now().toUtc().toIso8601String(),
        'expected_return_date': DateTime.now().toUtc().add(const Duration(days: 7)).toIso8601String(), // Default 1 week
      }).select().single();

      return {
        'success': true,
        'message': 'Successfully borrowed $itemName',
        'data': logResponse,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection failed: ${e.toString()}',
      };
    }
  }
}
