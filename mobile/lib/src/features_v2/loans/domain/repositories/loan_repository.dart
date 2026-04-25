import '../entities/loan_item.dart';

abstract class ILoanRepository {
  /// Fetch all loans for the current user
  Future<List<LoanItem>> fetchMyLoans({String? userId});

  /// Create a new loan request
  Future<LoanItem> createLoan(LoanItem request);

  /// Return an item
  Future<void> returnItem(String loanId);

  /// Cancel a loan request
  Future<void> cancelLoan(String loanId);

  // --- Manager Operations (WMS Checklist) ---
  
  /// Fetch all requests for a specific warehouse (Manager View)
  Future<List<LoanItem>> fetchWarehouseRequests(String? warehouseId);

  /// Approve a pending request (Audit included)
  Future<void> approveLoan(String loanId, String managerName);

  /// Confirm physical handoff (Audit included)
  Future<void> confirmHandoff(String loanId, String staffName);

  /// Confirm return with condition and notes (Audit included)
  Future<void> confirmReturn(String loanId, {
    required String staffName,
    required String condition,
    String? notes,
  });

  /// Surgical fetch for a specific log by its primary key
  Future<LoanItem?> fetchById(String loanId);

  /// Watch for remote changes from Supabase Realtime
  Stream<void> watchRemote({String? warehouseId, String? userId});
}
