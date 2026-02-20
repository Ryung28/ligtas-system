import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local_storage/isar_service.dart';
import '../networking/supabase_client.dart';
import '../../features/transactions/models/transaction_model.dart';
import '../../features/inventory/models/inventory_model.dart';

// Simple provider without code generation
final syncRepositoryProvider = FutureProvider<SyncRepository>((ref) async {
  final repo = SyncRepository();
  await repo.init();
  return repo;
});

class SyncRepository {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isOnline = false;
  bool _isSyncing = false;

  Future<void> init() async {
    // Initialize connectivity monitoring
    _initConnectivityListener();
    
    // Check initial connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    _isOnline = !connectivityResult.contains(ConnectivityResult.none);
    
    // If online, attempt initial sync
    if (_isOnline) {
      _syncPendingTransactions();
    }
  }

  void _initConnectivityListener() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      final wasOnline = _isOnline;
      _isOnline = !results.contains(ConnectivityResult.none);
      
      log('Connectivity changed: $_isOnline');
      
      // If we just came online, sync pending transactions
      if (!wasOnline && _isOnline && !_isSyncing) {
        _syncPendingTransactions();
      }
    });
  }

  /// Creates a new transaction (borrow/return)
  /// Handles both online and offline scenarios
  Future<bool> createTransaction(TransactionModel transaction) async {
    try {
      if (_isOnline) {
        // Try to send directly to Supabase
        final response = await SupabaseService.client
            .from('transactions')
            .insert(transaction.toJson())
            .select()
            .single();
            
        log('Transaction synced to Supabase: ${response['id']}');
        
        // Update inventory availability if successful
        await _updateInventoryAvailability(
          transaction.inventoryId, 
          transaction.quantity,
          transaction.status == 'borrowed' ? -1 : 1,
        );
        
        return true;
      } else {
        // Save to local storage for later sync
        final pendingTransaction = transaction.copyWith(
          isPendingSync: true,
          createdAt: DateTime.now(),
        );
        
        await IsarService.savePendingTransaction(pendingTransaction);
        log('Transaction saved locally for sync: ${transaction.borrowerName}');
        
        // Update local inventory cache
        await _updateLocalInventoryAvailability(
          transaction.inventoryId,
          transaction.quantity,
          transaction.status == 'borrowed' ? -1 : 1,
        );
        
        return true;
      }
    } catch (e) {
      log('Error creating transaction: $e');
      
      // If online request failed, save locally as fallback
      if (_isOnline) {
        final pendingTransaction = transaction.copyWith(
          isPendingSync: true,
          createdAt: DateTime.now(),
        );
        
        await IsarService.savePendingTransaction(pendingTransaction);
        log('Transaction saved locally as fallback: ${transaction.borrowerName}');
      }
      
      return false;
    }
  }

  /// Syncs all pending transactions to Supabase
  Future<void> _syncPendingTransactions() async {
    if (_isSyncing || !_isOnline) return;
    
    _isSyncing = true;
    log('Starting sync of pending transactions...');
    
    try {
      final pendingTransactions = await IsarService.getPendingTransactions();
      
      if (pendingTransactions.isEmpty) {
        log('No pending transactions to sync');
        _isSyncing = false;
        return;
      }
      
      log('Syncing ${pendingTransactions.length} pending transactions');
      
      for (final transaction in pendingTransactions) {
        if (transaction.id == null) continue;
        
        try {
          final response = await SupabaseService.client
              .from('transactions')
              .insert(transaction.toJson())
              .select()
              .single();
              
          log('Synced transaction: ${response['id']}');
          
          // Update inventory availability on server
          await _updateInventoryAvailability(
            transaction.inventoryId,
            transaction.quantity,
            transaction.status == 'borrowed' ? -1 : 1,
          );
          
          // Delete synced transaction from Isar
          await IsarService.deleteTransaction(transaction.id!);
          
        } catch (e) {
          log('Failed to sync transaction: $e');
          // Continue with next transaction
        }
      }
      
      // Delete synced transactions
      for (final key in keysToDelete) {
        await pendingBox.delete(key);
      }
      
      log('Sync completed');
      
    } catch (e) {
      log('Error during sync: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Updates inventory availability on server
  Future<void> _updateInventoryAvailability(
    int inventoryId, 
    int quantity, 
    int multiplier,
  ) async {
    try {
      await SupabaseService.client.rpc('update_inventory_availability', params: {
        'item_id': inventoryId,
        'quantity_change': quantity * multiplier,
      });
    } catch (e) {
      log('Error updating inventory availability: $e');
    }
  }

  /// Updates local inventory cache
  Future<void> _updateLocalInventoryAvailability(
    int inventoryId,
    int quantity,
    int multiplier,
  ) async {
    // Note: With Isar, we should ideally fetch the object, mutate it, and save.
    // However, since we are using Freezed + Isar, we treat it as immutable.
    try {
      final isar = IsarService.instance;
      final item = await isar.inventoryModels.get(inventoryId);
      if (item != null) {
        final updated = item.copyWith(
          available: item.available + (quantity * multiplier),
        );
        await IsarService.saveInventoryItems([updated]);
      }
    } catch (e) {
      log('Error updating local inventory: $e');
    }
  }

  /// Gets inventory items (online from Supabase, offline from cache)
  Future<List<InventoryModel>> getInventoryItems() async {
    try {
      if (_isOnline) {
        // Fetch from Supabase and cache locally
        final response = await SupabaseService.client
            .from('inventory')
            .select()
            .eq('status', 'active');
            
        final items = (response as List)
            .map((item) => InventoryModel.fromJson(item))
            .toList();
            
        // Cache items locally in Isar
        await IsarService.saveInventoryItems(items);
        
        return items;
      } else {
        // Return cached items from Isar
        return IsarService.instance.inventoryModels.where().findAll();
      }
    } catch (e) {
      log('Error getting inventory items: $e');
      return [];
    }
  }

  /// Gets item by QR code
  Future<InventoryModel?> getItemByQrCode(String qrCode) async {
    final items = await getInventoryItems();
    try {
      return items.firstWhere((item) => item.qrCode == qrCode);
    } catch (e) {
      return null;
    }
  }

  /// Gets sync status
  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  
  int get pendingTransactionsCount => 
      IsarService.instance.transactionModels.where().filter().isPendingSyncEqualTo(true).countSync();

  void dispose() {
    _connectivitySubscription.cancel();
  }
}