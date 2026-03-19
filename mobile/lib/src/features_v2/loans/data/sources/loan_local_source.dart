import 'package:isar/isar.dart';
import '../../../../core/local_storage/isar_service.dart';
import '../../../../features/loans/models/loan_model.dart'; // Reuse the Collection Schema
import '../../domain/entities/loan_item.dart';

class LoanLocalDataSource {
  final Isar _isar = IsarService.instance;

  Stream<List<LoanItem>> watchLoans(String userId) {
    return _isar.loanCollections
        .filter()
        .borrowedByEqualTo(userId)
        .watch(fireImmediately: true)
        .map((list) => list.map((e) => _mapCollectionToEntity(e)).toList());
  }

  Future<void> saveLoans(List<LoanItem> loans) async {
    await _isar.writeTxn(() async {
      for (final loan in loans) {
        final existing = await _isar.loanCollections
            .filter()
            .originalIdEqualTo(loan.id)
            .findFirst();
        
        final col = _mapEntityToCollection(loan);
        if (existing != null) col.id = existing.id;
        
        await _isar.loanCollections.put(col);
      }
    });
  }

  LoanItem _mapCollectionToEntity(LoanCollection col) {
    return LoanItem(
      id: col.originalId,
      userId: col.borrowedBy, // Explicit UID linkage
      inventoryItemId: col.inventoryItemId,
      itemName: col.itemName,
      itemCode: col.itemCode,
      borrowerName: col.borrowerName,
      borrowerContact: col.borrowerContact,
      borrowerEmail: col.borrowerEmail ?? '',
      purpose: col.purpose,
      quantityBorrowed: col.quantityBorrowed,
      borrowDate: col.borrowDate,
      expectedReturnDate: col.expectedReturnDate,
      actualReturnDate: col.actualReturnDate,
      status: LoanStatus.values.byName(col.status.name),
      notes: col.notes,
      returnNotes: col.returnNotes,
      borrowedBy: col.borrowedBy,
      returnedBy: col.returnedBy,
      daysOverdue: col.daysOverdue,
      daysBorrowed: col.daysBorrowed,
      isPendingSync: col.isPendingSync,
    );
  }

  LoanCollection _mapEntityToCollection(LoanItem item) {
    final col = LoanCollection()
      ..originalId = item.id
      ..inventoryItemId = item.inventoryItemId
      ..itemName = item.itemName
      ..itemCode = item.itemCode
      ..borrowerName = item.borrowerName
      ..borrowerContact = item.borrowerContact
      ..borrowerEmail = item.borrowerEmail
      ..purpose = item.purpose
      ..quantityBorrowed = item.quantityBorrowed
      ..borrowDate = item.borrowDate
      ..expectedReturnDate = item.expectedReturnDate
      ..actualReturnDate = item.actualReturnDate
      ..status = LoanStatus.values.byName(item.status.name)
      ..notes = item.notes
      ..returnNotes = item.returnNotes
      ..borrowedBy = item.borrowedBy
      ..returnedBy = item.returnedBy
      ..daysOverdue = item.daysOverdue
      ..daysBorrowed = item.daysBorrowed
      ..isPendingSync = item.isPendingSync;
    
    return col;
  }
}

// Helper: Mapping between Enum names for Isar stability
typedef LoanModelStatus = LoanStatus;
