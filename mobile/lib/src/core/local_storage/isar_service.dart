import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/inventory/models/inventory_model.dart';
import '../../features/loans/models/loan_model.dart';
import '../../features/transactions/models/transaction_model.dart';

class IsarService {
  static late Isar _isar;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        InventoryCollectionSchema,
        LoanCollectionSchema,
        TransactionCollectionSchema,
      ],
      directory: dir.path,
    );
  }

  static Isar get instance => _isar;

  // Inventory logic: Senior Dev "Mirror Sync"
  static Future<void> saveInventoryItems(List<InventoryModel> items) async {
    await _isar.writeTxn(() async {
      // 1. Get all currently cached items
      final currentLocalItems = await _isar.inventoryCollections.where().findAll();
      final remoteIds = items.map((i) => i.id).toSet();

      // 2. Aggressive Pruning: Delete orphans or deleted items
      for (final local in currentLocalItems) {
        // If it's an old record without an ID, or it's not in the new remote list
        if (local.originalId == null || !remoteIds.contains(local.originalId)) {
          await _isar.inventoryCollections.delete(local.id);
        }
      }

      // 3. Update/Insert: Standard logic for remaining items
      for (final item in items) {
        final entity = InventoryCollection.fromModel(item);
        final existing = await _isar.inventoryCollections
            .filter()
            .originalIdEqualTo(item.id)
            .findFirst();
        
        if (existing != null) {
          entity.id = existing.id;
        }
        await _isar.inventoryCollections.put(entity);
      }
    });
  }

  static Stream<List<InventoryModel>> watchInventory() {
    return _isar.inventoryCollections
        .where()
        .watch(fireImmediately: true)
        .map((list) => list.map((e) => e.toModel()).toList());
  }

  // Loan logic
  static Future<void> saveLoans(List<LoanModel> loans) async {
    await _isar.writeTxn(() async {
      for (final loan in loans) {
        final entity = LoanCollection.fromModel(loan);
        final existing = await _isar.loanCollections
            .filter()
            .originalIdEqualTo(loan.id)
            .findFirst();
            
        if (existing != null) {
          entity.id = existing.id;
        }
        await _isar.loanCollections.put(entity);
      }
    });
  }

  static Stream<List<LoanModel>> watchLoans() {
    return _isar.loanCollections
        .where()
        .watch(fireImmediately: true)
        .map((list) => list.map((e) => e.toModel()).toList());
  }

  // Transaction sync logic
  static Future<void> savePendingTransaction(TransactionModel transaction) async {
    await _isar.writeTxn(() async {
      await _isar.transactionCollections.put(TransactionCollection.fromModel(transaction));
    });
  }

  static Future<List<TransactionModel>> getPendingTransactions() async {
    final entities = await _isar.transactionCollections
        .where()
        .filter()
        .isPendingSyncEqualTo(true)
        .findAll();
    return entities.map((e) => e.toModel()).toList();
  }

  static Future<void> deleteTransaction(int id) async {
    await _isar.writeTxn(() async {
      // For transactions, we seek by originalId if it exists, or just id if it's the Isar ID
      await _isar.transactionCollections.delete(id);
    });
  }

  static Future<void> clearAll() async {
    await _isar.writeTxn(() => _isar.clear());
  }
}
