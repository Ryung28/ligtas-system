import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system/app_theme.dart';
import '../../../core/design_system/app_spacing.dart';
import '../../../core/design_system/components/app_card.dart'; // For AppEmptyState if it exists there
import '../models/inventory_item.dart';
import '../providers/inventory_providers.dart';
import 'inventory_card.dart';

// Assuming AppEmptyState is defined in a global location or I need to find it.
// Looking at the original file, it was used but not defined there.
// I'll define a local version if I can't find it, but the user asked for reusability.

class InventoryList extends ConsumerWidget {
  final AsyncValue<List<InventoryModel>> inventoryItemsAsync;
  final String searchQuery;
  final String selectedCategory;
  final String statusFilter;
  final Function(InventoryModel) onItemTap;

  const InventoryList({
    super.key,
    required this.inventoryItemsAsync,
    required this.searchQuery,
    required this.selectedCategory,
    required this.statusFilter,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return inventoryItemsAsync.when(
      data: (items) {
        final filteredItems = items.where((item) {
          // Apply search filter
          final matchesSearch = searchQuery.isEmpty ||
              item.name.toLowerCase().contains(searchQuery) ||
              item.code.toLowerCase().contains(searchQuery);

          // Apply category filter
          final matchesCategory = selectedCategory == 'All' ||
              item.category.toLowerCase().contains(selectedCategory.toLowerCase());

          // Apply status filter
          final matchesFilter = switch (statusFilter) {
            'all' => true,
            'active' => item.status == 'active',
            'low_stock' => item.quantity < 10,
            _ => true,
          };

          return matchesSearch && matchesCategory && matchesFilter;
        }).toList();

        if (filteredItems.isEmpty) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: () async => ref.read(inventoryItemsProvider.notifier).refresh(),
          color: AppTheme.primaryBlue,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              return InventoryCard(
                item: filteredItems[index],
                onTap: () => onItemTap(filteredItems[index]),
                animationDelay: Duration(milliseconds: index * 40),
              );
            },
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator.adaptive(),
      ),
      error: (error, stack) => _buildErrorState(context, ref, error),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    bool hasFilters = searchQuery.isNotEmpty || selectedCategory != 'All';
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFilters ? Icons.search_off_rounded : Icons.inventory_2_outlined,
            size: 64,
            color: AppTheme.neutralGray300,
          ),
          Gap(AppSpacing.lg),
          Text(
            statusFilter == 'low_stock'
                ? 'No low stock items'
                : hasFilters
                    ? 'No items found'
                    : 'Inventory is empty',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.neutralGray700,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Gap(AppSpacing.xs),
          Text(
            statusFilter == 'low_stock'
                ? 'All items have sufficient stock'
                : hasFilters
                    ? 'Try adjusting your search or filters'
                    : 'Add new items to your inventory',
            style: TextStyle(color: AppTheme.neutralGray500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.errorRed),
            Gap(AppSpacing.lg),
            const Text(
              'Error loading inventory',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Gap(AppSpacing.sm),
            Text(
              error.toString(),
              style: TextStyle(color: AppTheme.neutralGray600),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            Gap(AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () => ref.read(inventoryItemsProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
