import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/inventory_item.dart';
import '../providers/inventory_providers.dart';
import '../widgets/inventory_details_sheet.dart';

class InventoryController {
  final Ref ref;

  InventoryController(this.ref);

  void refreshData() {
    ref.invalidate(inventoryItemsProvider);
  }

  void showItemDetails(BuildContext context, InventoryModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ItemDetailsSheet(item: item),
    );
  }
}

final inventoryControllerProvider = Provider((ref) => InventoryController(ref));
