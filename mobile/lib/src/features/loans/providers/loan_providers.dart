import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/src/features/loans/repositories/loan_repository.dart';
import 'package:mobile/src/core/di/app_providers.dart';
import 'package:mobile/src/features/loans/models/loan_model.dart';
import 'package:mobile/src/features_v2/loans/presentation/providers/loan_provider.dart';

final loanRepositoryProvider = Provider<LoanRepository>((ref) {
  final client = ref.watch(AppProviders.supabaseClientProvider);
  return SupabaseLoanRepository(client);
});

final myBorrowedItemsProvider = StreamProvider<List<LoanModel>>((ref) {
  // 🚀 Bridge: Watch the V2 Reactive Stream and map to Legacy Models
  final v2LoansAsync = ref.watch(myLoansNotifierProvider);

  return v2LoansAsync.when(
    data: (items) => Stream.value(items.map<LoanModel>((i) => LoanModel(
      id: i.id,
      inventoryItemId: i.inventoryItemId,
      itemName: i.itemName,
      itemCode: i.itemCode,
      borrowerName: i.borrowerName,
      borrowerContact: i.borrowerContact,
      borrowerEmail: i.borrowerEmail,
      purpose: i.purpose,
      quantityBorrowed: i.quantityBorrowed,
      borrowDate: i.borrowDate,
      expectedReturnDate: i.expectedReturnDate,
      actualReturnDate: i.actualReturnDate,
      status: i.status,
      notes: i.notes,
      returnNotes: i.returnNotes,
      borrowedBy: i.borrowedBy,
      returnedBy: i.returnedBy,
      daysOverdue: i.daysOverdue,
      daysBorrowed: i.daysBorrowed,
      isPendingSync: i.isPendingSync,
      imageUrl: i.imageUrl,
    )).toList()),
    loading: () => const Stream.empty(),
    error: (e, st) => Stream.error(e, st),
  );
});
