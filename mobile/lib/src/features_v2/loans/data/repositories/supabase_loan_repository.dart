import 'package:flutter/foundation.dart';
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
          .select('*, inventory:inventory_id(image_url)')
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

  Stream<List<LoanItem>> watchLoans({bool isManager = false}) {
    if (isManager) {
      return _local.watchAllLoans();
    }
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
        'pickup_scheduled_at': request.pickupScheduledAt?.toIso8601String(),
        'notes': request.notes,
        'status': 'pending',
        'borrowed_by': userId,
        'platform_origin': 'Mobile',
        'created_origin': 'Mobile',
        'last_updated_origin': 'Mobile',
      }).select('*, inventory:inventory_id(image_url)').single();

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
        'platform_origin': 'Mobile',
        'last_updated_origin': 'Mobile',
        'updated_at': DateTime.now().toIso8601String(),
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
  Future<LoanItem?> fetchById(String loanId) async {
    try {
      final response = await _client
          .from('borrow_logs')
          .select('*, inventory:inventory_id(image_url)')
          .eq('id', loanId)
          .maybeSingle();

      if (response != null) {
        final loan = _mapJsonToEntity(response);
        _local.saveLoans([loan]);
        return loan;
      }
      return null;
    } catch (e) {
      debugPrint('Surgical Loan Fetch Error: $e');
      return null;
    }
  }

  @override
  Stream<void> watchRemote({String? warehouseId}) {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const Stream.empty();

    final query = (warehouseId != null && warehouseId != 'ALL')
        ? _client.from('borrow_logs').stream(primaryKey: ['id']).eq('warehouse_id', warehouseId)
        : _client.from('borrow_logs').stream(primaryKey: ['id']).eq('borrowed_by', userId);

    return query.asyncMap((data) async {
      final loans = data.map((json) => _mapJsonToEntity(json)).toList();
      await _local.saveLoans(loans);
    });
  }

  // --- Manager Operations (WMS Checklist Implementation) ---

  @override
  Future<List<LoanItem>> fetchWarehouseRequests(String? warehouseId) async {
    try {
      var query = _client.from('borrow_logs').select('*, inventory:inventory_id(image_url)');
      
      if (warehouseId != null && warehouseId != 'ALL') {
        query = query.eq('warehouse_id', warehouseId);
      }

      final response = await query.order('created_at', ascending: false);
      
      final List<dynamic> data = response;
      final loans = data.map((json) => _mapJsonToEntity(json)).toList();
      _local.saveLoans(loans);
      return loans;
    } catch (e) {
      throw ExceptionHandler.fromException(e);
    }
  }

  @override
  Future<void> approveLoan(String loanId, String managerName) async {
    try {
      await _client.from('borrow_logs').update({
        'status': 'approved',
        'approved_by': managerName,
        'approved_at': DateTime.now().toIso8601String(),
        'platform_origin': 'Mobile',
        'last_updated_origin': 'Mobile',
      }).eq('id', loanId);
    } catch (e) {
      throw ExceptionHandler.fromException(e);
    }
  }

  @override
  Future<void> confirmHandoff(String loanId, String staffName) async {
    try {
      await _client.from('borrow_logs').update({
        'status': 'borrowed',
        'handed_by': staffName,
        'handed_at': DateTime.now().toIso8601String(),
        'borrow_date': DateTime.now().toIso8601String(),
        'platform_origin': 'Mobile',
        'last_updated_origin': 'Mobile',
      }).eq('id', loanId);
    } catch (e) {
      throw ExceptionHandler.fromException(e);
    }
  }

  @override
  Future<void> confirmReturn(String loanId, {
    required String staffName,
    required String condition,
    String? notes,
  }) async {
    try {
      await _client.from('borrow_logs').update({
        'status': 'returned',
        'actual_return_date': DateTime.now().toIso8601String(),
        'received_by_name': staffName,
        'received_by_user_id': _client.auth.currentUser?.id,
        'return_condition': condition,
        'return_notes': notes,
        'platform_origin': 'Mobile',
        'last_updated_origin': 'Mobile',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', loanId);
    } catch (e) {
      throw ExceptionHandler.fromException(e);
    }
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
    } else if (rawStatus == 'staged') {
      finalStatus = LoanStatus.staged;
    } else if (rawStatus == 'reserved') {
      finalStatus = LoanStatus.reserved;
    } else {
      finalStatus = LoanStatus.active;
    }

    String? borrowDateStr = data['borrow_date'] as String? ?? data['created_at'] as String?;
    DateTime borrowDate = borrowDateStr != null ? DateTime.parse(borrowDateStr).toLocal() : DateTime.now();

    final expectedDateStr = data['expected_return_date'] as String? ?? 
                          DateTime.now().add(const Duration(days: 7)).toIso8601String();
    final expectedReturnDate = DateTime.parse(expectedDateStr).toLocal();
    final now = DateTime.now();

    // Only active handovers should age into overdue.
    if (finalStatus == LoanStatus.active && expectedReturnDate.isBefore(now)) {
      finalStatus = LoanStatus.overdue;
    }

    final dbDaysBorrowed =
        (finalStatus == LoanStatus.active ||
                finalStatus == LoanStatus.overdue ||
                finalStatus == LoanStatus.returned)
            ? now.difference(borrowDate).inDays
            : 0;
    final dbDaysOverdue = expectedReturnDate.isBefore(now) ? now.difference(expectedReturnDate).inDays : 0;

    final borrowedByUid = (data['borrowed_by'] ?? data['borrower_user_id'] ?? '').toString();

    // 🛡️ RELATIONAL EXTRACTION: Support both Map and List join formats
    String? imageUrl;
    final inventoryData = data['inventory'];
    if (inventoryData != null) {
      if (inventoryData is Map) {
        imageUrl = _sanitizeUrl(inventoryData['image_url'] as String?);
      } else if (inventoryData is List && inventoryData.isNotEmpty) {
        final firstItem = inventoryData.first;
        if (firstItem is Map) {
          imageUrl = _sanitizeUrl(firstItem['image_url'] as String?);
        }
      }
    }

    // Secondary fallback check for direct inventory_id join
    if (imageUrl == null && data['inventory_id'] != null && data['inventory_id'] is Map) {
      imageUrl = _sanitizeUrl(data['inventory_id']['image_url'] as String?);
    }

    return LoanItem(
      id: data['id'].toString(),
      userId: borrowedByUid, // Map Database UID to Entity userId
      inventoryItemId: (data['inventory_item_id'] ?? data['inventory_id'] ?? '').toString(),
      itemName: data['item_name'] as String? ?? '',
      itemCode: data['item_code'] as String? ?? '',
      borrowerName: data['borrower_name'] as String? ?? 'Unknown',
      borrowerContact: data['borrower_contact'] as String? ?? '',
      borrowerOrganization: data['borrower_organization'] as String? ?? '',
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
      
      // Audit & Accountability fields (Checklist 2.0 Mapping)
      approvedBy: data['approved_by'] as String?,
      approvedAt: data['approved_at'] != null ? DateTime.parse(data['approved_at']).toLocal() : null,
      handedBy: data['handed_by'] as String?,
      handedAt: data['handed_at'] != null ? DateTime.parse(data['handed_at']).toLocal() : null,
      receivedByName: data['received_by_name'] as String?,
      receivedByUserId: data['received_by_user_id'] as String?,
      returnCondition: data['return_condition'] as String?,
      pickupScheduledAt: data['pickup_scheduled_at'] != null ? DateTime.parse(data['pickup_scheduled_at']).toLocal() : null,

      daysBorrowed: dbDaysBorrowed,
      daysOverdue: dbDaysOverdue,
      isPendingSync: data['is_pending_sync'] as bool? ?? false,
      imageUrl: imageUrl,
    );
  }

  String? _sanitizeUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.isEmpty) return null;
    if (rawUrl.contains('/storage/v1/object/sign/')) {
      return rawUrl
          .replaceAll('/storage/v1/object/sign/', '/storage/v1/object/public/')
          .split('?token=')[0]
          .split('&token=')[0];
    }
    return rawUrl;
  }
}
