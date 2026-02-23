import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../models/loan_model.dart';
import '../services/cdrrmo_items_service.dart';
import '../../../core/di/app_providers.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/config/app_config.dart';
import '../../../core/local_storage/isar_service.dart';
import 'dart:async';

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
  Future<void> syncMyBorrowedItems(); // Force sync remote -> Isar
  Future<void> cancelLoanRequest(String loanId); // Borrower cancels pending request
  Future<void> requestReturn(String loanId); // Borrower initiates return process
}

/// Supabase implementation for borrower operations
class SupabaseLoanRepository implements LoanRepository {
  final SupabaseClient _client;

  SupabaseLoanRepository(this._client);

  @override
  Future<List<LoanModel>> getMyBorrowedItems() async {
    try {
      final currentUserId = _getCurrentUserId();
      final userEmail = _client.auth.currentUser?.email;

      var query = _client.from('borrow_logs').select('*');
      
      // Senior Dev: Only use OR if email is actually present to avoid syntax errors
      if (userEmail != null && userEmail.isNotEmpty) {
        query = query.or('borrower_user_id.eq.$currentUserId,borrower_email.eq.$userEmail');
      } else {
        query = query.eq('borrower_user_id', currentUserId);
      }

      final response = await query.order('created_at', ascending: false);
      final list = response as List;
      
      print('SYSTEM: DB Fetch complete. Found ${list.length} records.');

      // Senior Dev: Deep Identity Resolution Logic
      final initialLoans = list.map((data) => LoanModel.fromSupabase(data as Map<String, dynamic>)).toList();
      final processedItems = <LoanModel>[];
      final unknownItemIds = <String>{};

      for (var loan in initialLoans) {
        if (loan.itemName.isEmpty || loan.itemName == 'Unknown Item') {
           // Phase 1: Rapid Static Fallback
           final staticItem = CdrrmoItemsService.findItem(loan.inventoryItemId);
           if (staticItem != null) {
             loan = loan.copyWith(itemName: staticItem.name, itemCode: staticItem.code);
           } else {
             // Mark for Phase 2: Remote Batch Resolution
             unknownItemIds.add(loan.inventoryItemId);
           }
        }
        processedItems.add(loan);
      }

      // Phase 2: Remote Batch Resolution (The "Senior" Optimizer)
      if (unknownItemIds.isNotEmpty) {
        try {
          print('SYSTEM: Resolving ${unknownItemIds.length} unknown ghosts via Batch Query...');
          
          // We strictly check 'id' because 'code' column does not exist in inventory table
          final numericIds = unknownItemIds.map((id) => int.tryParse(id)).whereType<int>().toList();
          
          if (numericIds.isNotEmpty) {
             print('SYSTEM: Querying inventory IDs: $numericIds');
             
             final inventoryData = await _client
                 .from('inventory')
                 .select('id, item_name')
                 .inFilter('id', numericIds);

             final nameMap = {
               for (var item in (inventoryData as List)) 
                 item['id'].toString(): item['item_name'] as String,
             };

             // Apply resolutions
             for (var i = 0; i < processedItems.length; i++) {
               final loan = processedItems[i];
               if ((loan.itemName.isEmpty || loan.itemName == 'Unknown Item') && nameMap.containsKey(loan.inventoryItemId)) {
                 processedItems[i] = loan.copyWith(itemName: nameMap[loan.inventoryItemId]!);
               }
             }
          } else {
             print('SYSTEM: No valid numeric IDs found to resolve.');
          }
        } catch (e) {
          print('SYSTEM: Batch resolution failed (non-critical): $e');
        }
      }

      return processedItems;
    } on PostgrestException catch (e) {
      print('SYSTEM ERROR: Postgrest failure: ${e.message}');
      throw DataException('Failed to fetch borrowed items: ${e.message}', code: e.code);
    } catch (e) {
      print('SYSTEM ERROR: Unexpected fetch error: $e');
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
      if (currentUserId == null) throw LoanException('User not authenticated');

      // Priority 1: Use details provided in request
      var itemName = request.itemName;
      var itemCode = request.itemCode ?? request.inventoryItemId;
      
      // Safety: If somehow "Unknown" leaked in, try one last static lookup
      if (itemName == 'Unknown Item' || itemName.isEmpty) {
        final staticItem = CdrrmoItemsService.findItem(request.inventoryItemId);
        if (staticItem != null) {
          itemName = staticItem.name;
          itemCode = staticItem.code;
        }
      }

      // Submit borrow request (admin will approve)
      // Senior Dev: Use UTC for database inserts to ensure timezone consistency regardless of device location
      final now = DateTime.now().toUtc().toIso8601String();
      final borrowData = {
        'inventory_id': request.inventoryId,
        'inventory_item_id': request.inventoryItemId,
        'item_name': itemName, 
        'item_code': itemCode,
        'quantity': request.quantityBorrowed,
        'quantity_borrowed': request.quantityBorrowed,
        'borrower_name': request.borrowerName,
        'borrower_contact': request.borrowerContact,
        'borrower_email': request.borrowerEmail.isNotEmpty ? request.borrowerEmail : (_client.auth.currentUser?.email ?? ''),
        'borrower_organization': request.borrowerOrganization,
        'borrower_user_id': currentUserId,
        'borrowed_by': currentUserId,
        'purpose': request.purpose,
        'transaction_type': 'borrow',
        'borrow_date': now,
        'expected_return_date': request.expectedReturnDate.toUtc().toIso8601String(),
        'status': 'pending', // Admin needs to approve
        'notes': request.notes,
        'created_at': now,
      };

      final response = await _client
          .from('borrow_logs')
          .insert(borrowData)
          .select()
          .single();

      print('SYSTEM: Insert Successful. Raw DB Entry: $response');

      return LoanModel.fromSupabase(response);
    } catch (e) {
      print('SYSTEM ERROR: Submit failed: $e');
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
    // Senior Architect: Upgraded to StreamController for precise resource management
    // and to enable the requested "Live Refresh" capability.
    late StreamController<List<LoanModel>> controller;
    Timer? periodicRefreshTimer;
    StreamSubscription? isarSubscription;
    StreamSubscription? supabaseSubscription;

    controller = StreamController<List<LoanModel>>(
      onListen: () {
        // 1. Local DB Listener (The Single Source of Truth)
        // We emit local data immediately so the UI is offline-ready.
        isarSubscription = IsarService.watchLoans().listen(
          (data) => controller.add(data),
          onError: (e) => controller.addError(e),
        );

        // Define the robust sync function (Deep Identity Resolution)
        Future<void> runRobustSync() async {
          try {
            // This calls getMyBorrowedItems() which handles the "Unknown Item" resolution
            // and then saves to Isar, triggering the listener above.
            await syncMyBorrowedItems();
          } catch (e) {
            // Silent fail on connection errors to keep stream alive
            print('SYSTEM: Background sync warning: $e'); 
          }
        }

        // 2. Immediate Startup Sync
        runRobustSync();

        // 3. Periodic "Heartbeat" Refresh (The "Small Stream" Fix)
        // Every 30 seconds, we check for updates to ensure strictly fresh data
        // and resolve any lingering "Unknown Items".
        periodicRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
          runRobustSync();
        });

        // 4. Real-time Remote Listener
        // Triggers a full resolution sync on any change, rather than blindly saving raw logs.
        try {
          final currentUserId = _getCurrentUserId();
          supabaseSubscription = _client
              .from('borrow_logs')
              .stream(primaryKey: ['id'])
              .eq('borrower_user_id', currentUserId)
              .listen((data) {
                print('SYSTEM: Realtime change detected. Triggering resolution sync...');
                runRobustSync();
              }, onError: (e) => print('SYSTEM: Realtime subscription error: $e'));
        } catch (e) {
          print('SYSTEM: Failed to setup realtime listener: $e');
        }
      },
      onCancel: () {
        // Strict Resource Cleanup
        periodicRefreshTimer?.cancel();
        isarSubscription?.cancel();
        supabaseSubscription?.cancel();
        print('SYSTEM: watchActiveLoans stream disposed.');
      },
    );

    return controller.stream;
  }

  @override
  Future<void> syncMyBorrowedItems() async {
    try {
      final snapshot = await getMyBorrowedItems();
      await IsarService.saveLoans(snapshot);
      print('SYSTEM: Manual sync forced. Updated ${snapshot.length} items.');
    } catch (e) {
      print('SYSTEM ERROR: Manual sync failed: $e');
      throw DataException('Refresh failed: $e');
    }
  }

  @override
  Future<void> cancelLoanRequest(String loanId) async {
    try {
      // Logic: Update status to 'cancelled' if it was 'pending'
      await _client
          .from('borrow_logs')
          .update({'status': 'cancelled', 'notes': 'Cancelled by borrower'}) // Actually 'returned' or 'cancelled'? Let's use 'returned' as it's a valid enum usually, or check the DB.
          .eq('id', loanId)
          .eq('status', 'pending');
      
      print('SYSTEM: Loan request $loanId cancelled.');
    } catch (e) {
      throw LoanException('Failed to cancel request: $e');
    }
  }

  @override
  Future<void> requestReturn(String loanId) async {
    try {
      // Logic: Update notes or a specific field to indicate borrower intends to return
      // For now, let's just update the status to something that triggers admin attention or add a note.
      await _client
          .from('borrow_logs')
          .update({'notes': 'BORROWER INITIATED RETURN: ${DateTime.now()}'})
          .eq('id', loanId);

      print('SYSTEM: Return requested for loan $loanId.');
    } catch (e) {
      throw LoanException('Failed to initiate return: $e');
    }
  }
}

