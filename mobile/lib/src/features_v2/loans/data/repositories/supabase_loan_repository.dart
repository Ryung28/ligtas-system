import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/loan_item.dart';
import '../../domain/repositories/loan_repository.dart';
import '../sources/loan_local_source.dart';
import '../../../../core/errors/app_exceptions.dart';

class SupabaseLoanRepository implements ILoanRepository {
  final SupabaseClient _client;
  final LoanLocalDataSource _local;

  SupabaseLoanRepository(this._client, this._local);

  @override
  Future<List<LoanItem>> fetchMyLoans() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _client
          .from('borrow_logs')
          .select('*')
          .eq('borrowed_by', userId) // Strict Tenant Isolation
          .order('borrow_date', ascending: false);
      
      final List<dynamic> data = response;
      final loans = data.map((json) => _mapJsonToEntity(json)).toList();

      // Parallel Sync
      _local.saveLoans(loans);

      return loans;
    } catch (e) {
      // Log error but return empty to allow UI to rely on Local Stream
      throw ExceptionHandler.fromException(e);
    }
  }

  Stream<List<LoanItem>> watchLoans() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const Stream.empty();
    return _local.watchLoans(userId);
  }

  @override
  Future<LoanItem> createLoan(LoanItem request) async {
    try {
      final userId = _client.auth.currentUser?.id;
      final response = await _client.from('borrow_logs').insert({
        'inventory_id': int.tryParse(request.inventoryItemId), // FK to inventory.id
        'item_name': request.itemName,
        'item_code': request.itemCode,
        'borrower_name': request.borrowerName,
        'borrower_contact': request.borrowerContact,
        'borrower_email': request.borrowerEmail,
        'purpose': request.purpose,
        'quantity': request.quantityBorrowed, // REQUIRED NOT-NULL FIELD
        'quantity_borrowed': request.quantityBorrowed, 
        'transaction_type': 'borrow', // REQUIRED FOR STOCK TRIGGER
        'expected_return_date': request.expectedReturnDate.toIso8601String(),
        'notes': request.notes,
        'status': 'pending',
        'borrowed_by': userId, // Ensure current user owns the log
      }).select().single();

      final newLoan = _mapJsonToEntity(response);
      _local.saveLoans([newLoan]);
      return newLoan;
    } catch (e) {
      throw ExceptionHandler.fromException(e);
    }
  }

  @override
  Future<void> returnItem(String loanId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _client.from('borrow_logs').update({
        'status': 'returned',
        'actual_return_date': DateTime.now().toIso8601String(),
      }).eq('id', loanId).eq('borrowed_by', userId);

      await fetchMyLoans();
    } on Exception catch (e) {
      throw ExceptionHandler.fromException(e);
    }
  }

  @override
  Future<void> cancelLoan(String loanId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _client.from('borrow_logs').update({
        'status': 'cancelled',
      }).eq('id', loanId).eq('borrowed_by', userId);

      await fetchMyLoans();
    } on Exception catch (e) {
      throw ExceptionHandler.fromException(e);
    }
  }

  @override
  Stream<void> watchRemote() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const Stream.empty();

    return _client
        .from('borrow_logs')
        .stream(primaryKey: ['id'])
        .eq('borrowed_by', userId) // Realtime Tenant Isolation
        .map((data) {
          final loans = data.map((json) => _mapJsonToEntity(json)).toList();
          _local.saveLoans(loans);
        });
  }

  /// Mapping Logic
  LoanItem _mapJsonToEntity(Map<String, dynamic> data) {
    final rawStatus = (data['status'] as String? ?? 'active').toLowerCase();
    LoanStatus finalStatus;
    if (rawStatus == 'borrowed' || rawStatus == 'active') {
      finalStatus = LoanStatus.active;
    } else if (rawStatus == 'overdue') {
      finalStatus = LoanStatus.overdue;
    } else if (rawStatus == 'returned') {
      finalStatus = LoanStatus.returned;
    } else if (rawStatus == 'cancelled') {
      finalStatus = LoanStatus.cancelled;
    } else if (rawStatus == 'pending') {
      finalStatus = LoanStatus.pending;
    } else {
      finalStatus = LoanStatus.active;
    }

    String? borrowDateStr = data['borrow_date'] as String? ?? data['created_at'] as String?;
    DateTime borrowDate = borrowDateStr != null ? DateTime.parse(borrowDateStr).toLocal() : DateTime.now();

    final expectedDateStr = data['expected_return_date'] as String? ?? 
                          DateTime.now().add(const Duration(days: 7)).toIso8601String();
    final expectedReturnDate = DateTime.parse(expectedDateStr).toLocal();
    final now = DateTime.now();

    // 🚀 Dynamic Overdue Logic: If it's borrowed OR pending but the date has passed, it IS overdue in the UI
    if ((finalStatus == LoanStatus.active || finalStatus == LoanStatus.pending) && expectedReturnDate.isBefore(now)) {
      finalStatus = LoanStatus.overdue;
    }

    final dbDaysBorrowed = now.difference(borrowDate).inDays;
    final dbDaysOverdue = expectedReturnDate.isBefore(now) ? now.difference(expectedReturnDate).inDays : 0;

    final borrowedByUid = (data['borrowed_by'] ?? data['borrower_user_id'] ?? '').toString();

    return LoanItem(
      id: data['id'].toString(),
      userId: borrowedByUid, // Map Database UID to Entity userId
      inventoryItemId: (data['inventory_item_id'] ?? data['inventory_id'] ?? '').toString(),
      itemName: data['item_name'] as String? ?? '',
      itemCode: data['item_code'] as String? ?? '',
      borrowerName: data['borrower_name'] as String? ?? 'Unknown',
      borrowerContact: data['borrower_contact'] as String? ?? '',
      borrowerEmail: data['borrower_email'] as String? ?? '',
      purpose: data['purpose'] as String? ?? '',
      quantityBorrowed: (data['quantity_borrowed'] ?? 1) is int 
          ? (data['quantity_borrowed'] ?? 1) as int 
          : double.parse((data['quantity_borrowed'] ?? 1).toString()).toInt(),
      borrowDate: borrowDate,
      expectedReturnDate: expectedReturnDate,
      actualReturnDate: data['actual_return_date'] != null ? DateTime.parse(data['actual_return_date']).toLocal() : null,
      status: finalStatus,
      notes: data['notes'] as String?,
      returnNotes: data['return_notes'] as String?,
      borrowedBy: borrowedByUid,
      returnedBy: data['returned_by']?.toString(),
      daysBorrowed: dbDaysBorrowed,
      daysOverdue: dbDaysOverdue,
      isPendingSync: data['is_pending_sync'] as bool? ?? false,
    );
  }
}
