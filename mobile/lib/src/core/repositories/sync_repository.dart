import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local_storage/hive_service.dart';
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
            .insert(transaction.toSupabase())
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
        
        await HiveService.pendingTransactionsBox.add(pendingTransaction.toJson());
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
        
        await HiveService.pendingTransactionsBox.add(pendingTransaction.toJson());
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
      final pendingBox = HiveService.pendingTransactionsBox;
      final pendingTransactions = pendingBox.values
          .map((item) => TransactionModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      
      if (pendingTransactions.isEmpty) {
        log('No pending transactions to sync');
        _isSyncing = false;
        return;
      }
      
      log('Syncing ${pendingTransactions.length} pending transactions');
      
      final keysToDelete = <dynamic>[];
      
      for (final entry in pendingBox.toMap().entries) {
        final key = entry.key;
        final transactionData = entry.value;
        
        try {
          final transaction = TransactionModel.fromJson(Map<String, dynamic>.from(transactionData));
          
          // Send to Supabase
          final response = await SupabaseService.client
              .from('transactions')
              .insert(transaction.toSupabase())
              .select()
              .single();
              
          log('Synced transaction: ${response['id']}');
          
          // Update inventory availability on server
          await _updateInventoryAvailability(
            transaction.inventoryId,
            transaction.quantity,
            transaction.status == 'borrowed' ? -1 : 1,
          );
          
          // Mark for deletion
          keysToDelete.add(key);
          
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
    try {
      final inventoryBox = HiveService.inventoryBox;
      final cachedItem = inventoryBox.get(inventoryId.toString());
      
      if (cachedItem != null) {
        final currentAvailable = cachedItem['available'] as int;
        cachedItem['available'] = currentAvailable + (quantity * multiplier);
        await inventoryBox.put(inventoryId.toString(), cachedItem);
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
            .map((item) => InventoryModel.fromSupabase(item))
            .toList();
            
        // Cache items locally
        final inventoryBox = HiveService.inventoryBox;
        for (final item in items) {
          await inventoryBox.put(item.id.toString(), item.toJson());
        }
        
        return items;
      } else {
        // Return cached items
        final inventoryBox = HiveService.inventoryBox;
        final cachedItems = inventoryBox.values
            .map((item) => InventoryModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
            
        return cachedItems;
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
      HiveService.pendingTransactionsBox.length;

  void dispose() {
    _connectivitySubscription.cancel();
  }
}