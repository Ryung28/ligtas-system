import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String _pendingTransactionsBox = 'pending_transactions';
  static const String _inventoryBox = 'inventory_cache';
  
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Open boxes with dynamic types (no adapters needed for now)
    await Hive.openBox<Map>(_pendingTransactionsBox);
    await Hive.openBox<Map>(_inventoryBox);
  }
  
  static Box<Map> get pendingTransactionsBox =>
      Hive.box<Map>(_pendingTransactionsBox);
      
  static Box<Map> get inventoryBox =>
      Hive.box<Map>(_inventoryBox);
      
  static Future<void> close() async {
    await Hive.close();
  }
}