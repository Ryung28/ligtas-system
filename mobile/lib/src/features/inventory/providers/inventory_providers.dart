import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/src/features/inventory/models/inventory_model.dart';
import 'package:mobile/src/core/di/app_providers.dart';

import 'package:mobile/src/features_v2/inventory/presentation/providers/inventory_provider.dart';
import 'package:mobile/src/features_v2/inventory/domain/entities/inventory_item.dart';

final inventoryItemsProvider = StreamProvider<List<InventoryModel>>((ref) {
  final v2Stream = ref.watch(allInventoryStreamProvider.stream);
  
  return v2Stream.map((items) => items.map((i) => InventoryModel(
    id: i.id,
    name: i.name,
    description: i.description,
    category: i.category,
    quantity: i.totalStock,
    available: i.availableStock,
    location: i.location,
    qrCode: i.qrCode,
    status: i.status,
    code: i.code,
    minStockLevel: i.minStockLevel,
    unit: i.unit,
    imageUrl: i.imageUrl ?? '',
    updatedAt: i.lastUpdated,
  )).toList());
});

final categoryIconProvider = Provider.family<IconData, String>((ref, category) {
  final c = category.toLowerCase();
  if (c.contains('comms') || c.contains('radio')) return Icons.settings_input_antenna_rounded;
  if (c.contains('bolt') || c.contains('power') || c.contains('gen')) return Icons.bolt_rounded;
  if (c.contains('med') || c.contains('aid')) return Icons.medical_services_rounded;
  if (c.contains('dron') || c.contains('fly')) return Icons.flight_takeoff_rounded;
  if (c.contains('resc') || c.contains('life') || c.contains('safe')) return Icons.health_and_safety_rounded;
  if (c.contains('tool') || c.contains('work')) return Icons.construction_rounded;
  if (c.contains('vehi') || c.contains('truck')) return Icons.local_shipping_rounded;
  if (c.contains('ppe') || c.contains('gear')) return Icons.masks_rounded;
  if (c.contains('logi') || c.contains('ware')) return Icons.warehouse_rounded;
  return Icons.inventory_2_outlined;
});
