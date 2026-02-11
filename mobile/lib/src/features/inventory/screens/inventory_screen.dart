import 'package:flutter/material.dart';
import '../../../core/design_system/app_theme.dart';
import '../../../core/design_system/app_spacing.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neutralGray50,
      appBar: AppBar(
        title: const Text('CDRRMO Inventory'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: AppTheme.neutralGray300,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Equipment Inventory',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.neutralGray600,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Browse all available emergency equipment',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.neutralGray500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
