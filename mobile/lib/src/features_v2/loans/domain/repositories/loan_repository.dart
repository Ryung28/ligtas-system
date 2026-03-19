import '../entities/loan_item.dart';

abstract class ILoanRepository {
  /// Fetch all loans for the current user
  Future<List<LoanItem>> fetchMyLoans();

  /// Create a new loan request
  Future<LoanItem> createLoan(LoanItem request);

  /// Return an item
  Future<void> returnItem(String loanId);

  /// Cancel a loan request
  Future<void> cancelLoan(String loanId);

  /// Watch for remote changes from Supabase Realtime
  Stream<void> watchRemote();
}
