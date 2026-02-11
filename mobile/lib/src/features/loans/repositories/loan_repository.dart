import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../models/loan_model.dart';
import '../services/cdrrmo_items_service.dart';
import '../../../core/di/app_providers.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/config/app_config.dart';

/// Repository interface for borrower operations (not admin)
abstract class LoanRepository {
  Future<List<LoanModel>> getMyBorrowedItems(); // User's borrowed items only
  Future<List<LoanModel>> getActiveLoans(); // For compatibility
  Future<List<LoanModel>> getOverdueLoans(); // User's overdue items
  Future<List<LoanModel>> getLoanHistory({int limit = 50}); // User's history
  Future<LoanModel> createLoan(CreateLoanRequest request); // Submit borrow request
  Future<LoanModel> returnLoan(ReturnLoanRequest request); // Not used by borrowers
  Future<LoanModel> updateLoan(LoanModel loan); // Not used by borrowers
  Future<void> deleteLoan(String loanId); // Not used by borrowers
  Future<LoanStatistics> getLoanStatistics(); // User's stats only
  Stream<List<LoanModel>> watchActiveLoans(); // User's items stream
}

/// Supabase implementation for borrower operations
class SupabaseLoanRepository implements LoanRepository {
  final SupabaseClient _client;

  SupabaseLoanRepository(this._client);

  @override
  Future<List<LoanModel>> getMyBorrowedItems() async {
    try {
      final currentUserId = _getCurrentUserId();

      final response = await _client
          .from('borrow_logs')
          .select('*')
          .eq('borrower_user_id', currentUserId)
          .order('created_at', ascending: false);

      return response
          .map((data) => LoanModel.fromSupabase(data))
          .toList();
    } on PostgrestException catch (e) {
      throw DataException('Failed to fetch borrowed items: ${e.message}', code: e.code);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw DataException('Failed to fetch your borrowed items: $e');
    }
  }

  /// Helper method to get current user ID with proper error handling
  String _getCurrentUserId() {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) {
      throw const AuthException('User not authenticated');
    }
    return currentUserId;
  }

  @override
  Future<List<LoanModel>> getActiveLoans() async {
    return getMyBorrowedItems();
  }

  @override
  Future<List<LoanModel>> getOverdueLoans() async {
    try {
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw LoanException('User not authenticated');
      }

      final now = DateTime.now().toIso8601String();
      final response = await _client
          .from('borrow_logs')
          .select('*')
          .eq('borrower_user_id', currentUserId)
          .eq('status', 'borrowed')
          .lt('expected_return_date', now)
          .order('expected_return_date', ascending: true);

      return response
          .map((data) => LoanModel.fromSupabase(data))
          .toList();
    } catch (e) {
      throw LoanException('Failed to fetch overdue items: $e');
    }
  }

  @override
  Future<List<LoanModel>> getLoanHistory({int limit = 50}) async {
    try {
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw LoanException('User not authenticated');
      }

      final response = await _client
          .from('borrow_logs')
          .select('*')
          .eq('borrower_user_id', currentUserId)
          .order('created_at', ascending: false)
          .limit(limit);

      return response
          .map((data) => LoanModel.fromSupabase(data))
          .toList();
    } catch (e) {
      throw LoanException('Failed to fetch loan history: $e');
    }
  }

  @override
  Future<LoanModel> createLoan(CreateLoanRequest request) async {
    try {
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw LoanException('User not authenticated');
      }

      // Get current user profile for borrower info
      final userProfile = await _client.auth.getUser();
      final userEmail = userProfile.user?.email ?? '';

      // Get item details from CDRRMO items service
      final item = CdrrmoItemsService.findItem(request.inventoryItemId);
      final itemName = item?.name ?? 'Unknown Item';
      final itemCode = item?.code ?? request.inventoryItemId;

      // Submit borrow request (admin will approve)
      final borrowData = {
        'inventory_item_id': request.inventoryItemId,
        'item_name': itemName, // Real item name from CDRRMO service
        'item_code': itemCode, // Real item code
        'quantity': request.quantityBorrowed, // ADDED: Match DB not-null constraint
        'quantity_borrowed': request.quantityBorrowed,
        'borrower_name': request.borrowerName,
        'borrower_contact': request.borrowerContact,
        'borrower_email': request.borrowerEmail.isNotEmpty ? request.borrowerEmail : userEmail,
        'borrower_organization': request.borrowerOrganization,
        'borrower_user_id': currentUserId,
        'borrowed_by': currentUserId,
        'purpose': request.purpose,
        'borrow_date': DateTime.now().toIso8601String(),
        'expected_return_date': request.expectedReturnDate.toIso8601String(),
        'status': 'pending', // Admin needs to approve
        'notes': request.notes,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from('borrow_logs')
          .insert(borrowData)
          .select()
          .single();

      return LoanModel.fromSupabase(response);
    } catch (e) {
      throw LoanException('Failed to submit borrow request: $e');
    }
  }

  @override
  Future<LoanModel> returnLoan(ReturnLoanRequest request) async {
    throw LoanException('Return requests must be processed by admin staff');
  }

  @override
  Future<LoanModel> updateLoan(LoanModel loan) async {
    throw LoanException('Loan updates must be done by admin staff');
  }

  @override
  Future<void> deleteLoan(String loanId) async {
    throw LoanException('Only admin staff can delete loans');
  }

  @override
  Future<LoanStatistics> getLoanStatistics() async {
    try {
      final myItems = await getMyBorrowedItems();
      
      final activeCount = myItems.where((l) => l.status == LoanStatus.active && l.daysOverdue == 0).length;
      final overdueCount = myItems.where((l) => l.daysOverdue > 0).length;
      final returnedCount = myItems.where((l) => l.status == LoanStatus.returned).length;
      final totalItems = myItems.fold<int>(0, (sum, loan) => sum + loan.quantityBorrowed);

      return LoanStatistics(
        totalActiveLoans: activeCount,
        totalOverdueLoans: overdueCount,
        totalReturnedToday: returnedCount,
        totalItemsBorrowed: totalItems,
        averageLoanDuration: 0.0,
      );
    } catch (e) {
      throw LoanException('Failed to fetch your statistics: $e');
    }
  }

  @override
  Stream<List<LoanModel>> watchActiveLoans() {
    try {
      final currentUserId = _getCurrentUserId();

      return _client
          .from('borrow_logs')
          .stream(primaryKey: ['id'])
          .eq('borrower_user_id', currentUserId)
          .order('created_at', ascending: false)
          .map((data) => data
              .map((item) => LoanModel.fromSupabase(item))
              .toList());
    } catch (e) {
      return Stream.error(ExceptionHandler.fromException(e as Exception));
    }
  }
}

