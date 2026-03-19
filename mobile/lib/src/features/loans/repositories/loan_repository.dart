import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile/src/features/loans/models/loan_model.dart';
import 'package:mobile/src/features_v2/loans/domain/entities/loan_item.dart' show LoanStatus;

abstract class LoanRepository {
  Future<List<LoanModel>> fetchMyLoans();
  Future<LoanModel> createLoan(LoanModel request);
  Future<void> returnItem(String loanId);
  Future<void> cancelLoan(String loanId);
  
  // Stats used by dashboard
  Future<LoanStatistics> getLoanStatistics();
  
  // Future list for dashboard
  Future<List<LoanModel>> getMyBorrowedItems();
}

class LoanStatistics {
  final int totalActiveLoans;
  final int totalOverdueLoans;
  final int totalReturnedToday;

  LoanStatistics({
    required this.totalActiveLoans,
    required this.totalOverdueLoans,
    required this.totalReturnedToday,
  });
}

class SupabaseLoanRepository implements LoanRepository {
  final SupabaseClient _client;

  SupabaseLoanRepository(this._client);

  @override
  Future<List<LoanModel>> fetchMyLoans() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      debugPrint('🚫 SupabaseLoanRepository: No logged-in user, returning empty list.');
      return [];
    }
    
    try {
      debugPrint('🚀 SupabaseLoanRepository: Fetching logs for user $userId from "borrow_logs" table...');
      final response = await _client
          .from('borrow_logs')
          .select('*')
          .eq('borrowed_by', userId) // Strict Tenant Isolation
          .order('borrow_date', ascending: false);
      
      final List<dynamic> data = response;
      debugPrint('✅ SupabaseLoanRepository: Received ${data.length} raw rows');
      
      final List<LoanModel> loans = [];
      for (var json in data) {
        try {
          loans.add(_mapJsonToModel(json));
        } catch (e) {
          debugPrint('⚠️ SupabaseLoanRepository: Failed to map loan item: $e');
          // Skip corrupt items instead of failing the whole list
        }
      }
      
      debugPrint('📦 SupabaseLoanRepository: Successfully mapped ${loans.length} loans');
      return loans;
    } catch (e) {
      debugPrint('❌ SupabaseLoanRepository: Critical Fetch Error: $e');
      return [];
    }
  }

  @override
  Future<List<LoanModel>> getMyBorrowedItems() async {
    return fetchMyLoans();
  }

  @override
  Future<LoanStatistics> getLoanStatistics() async {
    final loans = await fetchMyLoans();
    final now = DateTime.now();
    
    final active = loans.where((l) => l.status == LoanStatus.active).length;
    final overdue = loans.where((l) => 
      l.status == LoanStatus.overdue || 
      (l.actualReturnDate == null && l.expectedReturnDate.isBefore(now))
    ).length;
    
    final returnedToday = loans.where((l) => 
      l.status == LoanStatus.returned && 
      l.actualReturnDate != null && 
      l.actualReturnDate!.day == now.day &&
      l.actualReturnDate!.month == now.month &&
      l.actualReturnDate!.year == now.year
    ).length;

    debugPrint('📊 Dashboard Stats: Active: $active, Overdue: $overdue, Returned: $returnedToday');

    return LoanStatistics(
      totalActiveLoans: active,
      totalOverdueLoans: overdue,
      totalReturnedToday: returnedToday,
    );
  }

  @override
  Future<LoanModel> createLoan(LoanModel request) async {
    final response = await _client.from('borrow_logs').insert(request.toJson()).select().single();
    return _mapJsonToModel(response);
  }

  @override
  Future<void> returnItem(String loanId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('borrow_logs').update({
      'status': 'returned',
      'actual_return_date': DateTime.now().toIso8601String(),
    }).eq('id', loanId).eq('borrowed_by', userId);
  }

  @override
  Future<void> cancelLoan(String loanId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('borrow_logs').update({
      'status': 'cancelled',
    }).eq('id', loanId).eq('borrowed_by', userId);
  }

  LoanModel _mapJsonToModel(Map<String, dynamic> data) {
    // Determine status
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

    // Parse dates
    String? borrowDateStr = data['borrow_date'] as String? ?? data['created_at'] as String?;
    DateTime borrowDate = borrowDateStr != null ? DateTime.parse(borrowDateStr).toLocal() : DateTime.now();
    
    final expectedDateStr = data['expected_return_date'] as String? ?? 
                          DateTime.now().add(const Duration(days: 7)).toIso8601String();
    final expectedReturnDate = DateTime.parse(expectedDateStr).toLocal();
    final now = DateTime.now();

    // 🚀 Dynamic Overdue Logic: Essential for accurate field telemetry
    // If it's borrowed OR pending but the date has passed, it IS overdue in the UI
    if ((finalStatus == LoanStatus.active || finalStatus == LoanStatus.pending) && expectedReturnDate.isBefore(now)) {
      finalStatus = LoanStatus.overdue;
    }

    // Calculate derived fields
    final dbDaysBorrowed = now.difference(borrowDate).inDays;
    final dbDaysOverdue = expectedReturnDate.isBefore(now) ? now.difference(expectedReturnDate).inDays : 0;

    return LoanModel(
      id: data['id'].toString(),
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
      borrowedBy: (data['borrowed_by'] ?? data['borrower_user_id'] ?? '').toString(),
      returnedBy: data['returned_by']?.toString(),
      daysBorrowed: dbDaysBorrowed,
      daysOverdue: dbDaysOverdue,
    );
  }
}
