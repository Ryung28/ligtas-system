import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../core/design_system/app_theme.dart';
import '../../../core/design_system/app_spacing.dart';
import '../models/inventory_item.dart';

class ItemDetailsSheet extends ConsumerWidget {
  final InventoryModel item;

  const ItemDetailsSheet({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLowStock = item.quantity < 10;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 48,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppTheme.neutralGray200,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              const Gap(AppSpacing.lg),

              // Header
              Row(
                children: [
                  _CategoryIconBox(category: item.category),
                  Gap(AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.neutralGray900,
                              ),
                        ),
                        Gap(AppSpacing.xs),
                        Row(
                          children: [
                            Icon(
                              Icons.qr_code_rounded,
                              size: 16,
                              color: AppTheme.neutralGray500,
                            ),
                            Gap(AppSpacing.xs),
                            Text(
                              item.code,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.neutralGray600,
                                    fontFamily: 'RobotoMono',
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(isLowStock: isLowStock),
                ],
              ),

              Gap(AppSpacing.lg),

              // Details
              Expanded(
                child: ListView(
                  controller: scrollController,
                  shrinkWrap: true,
                  children: [
                    _DetailSection(title: 'Item Information', children: [
                      _DetailRow(icon: Icons.category_rounded, label: 'Category', value: item.category),
                      _DetailRow(icon: Icons.description_rounded, label: 'Description', value: item.description),
                      _DetailRow(icon: Icons.location_on_rounded, label: 'Location', value: item.location ?? 'Storage Area A'),
                    ]),

                    Gap(AppSpacing.lg),

                    _DetailSection(title: 'Stock Information', children: [
                      _DetailRow(icon: Icons.inventory_rounded, label: 'Current Stock', value: '${item.quantity}'),
                      _DetailRow(icon: Icons.inventory_2_rounded, label: 'Minimum Stock', value: '${item.minStockLevel}'),
                      _DetailRow(icon: Icons.tag_rounded, label: 'Unit', value: item.unit ?? 'pcs'),
                    ]),

                    if (item.supplier?.isNotEmpty == true) ...[
                      Gap(AppSpacing.lg),
                      _DetailSection(title: 'Supplier Information', children: [
                        _DetailRow(icon: Icons.business_rounded, label: 'Supplier', value: item.supplier!),
                        if (item.supplierContact?.isNotEmpty == true)
                          _DetailRow(icon: Icons.phone_rounded, label: 'Contact', value: item.supplierContact!),
                      ]),
                    ],

                    if (item.notes?.isNotEmpty == true) ...[
                      Gap(AppSpacing.lg),
                      _DetailSection(title: 'Notes', children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppTheme.neutralGray50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.neutralGray200),
                          ),
                          child: Text(
                            item.notes!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.neutralGray700,
                                ),
                          ),
                        ),
                      ]),
                    ],
                  ],
                ),
              ),

              // Action buttons
              if (isLowStock) ...[
                Gap(AppSpacing.lg),
                _LowStockAlert(quantity: item.quantity),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryIconBox extends StatelessWidget {
  final String category;
  const _CategoryIconBox({required this.category});

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor(category);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(_getCategoryIcon(category), size: 24, color: Colors.white),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'equipment': return AppTheme.primaryBlue;
      case 'vehicles': return AppTheme.secondaryOrange;
      case 'safety gear':
      case 'safety': return AppTheme.warningAmber;
      case 'medical': return AppTheme.successGreen;
      default: return AppTheme.neutralGray600;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'equipment': return Icons.inventory_rounded;
      case 'vehicles': return Icons.directions_car_rounded;
      case 'safety gear':
      case 'safety': return Icons.shield_rounded;
      case 'medical': return Icons.medical_services_rounded;
      default: return Icons.category_rounded;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isLowStock;
  const _StatusBadge({required this.isLowStock});

  @override
  Widget build(BuildContext context) {
    if (isLowStock) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.errorRed,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.errorRed.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_rounded, size: 14, color: Colors.white),
            Gap(AppSpacing.xs),
            Text(
              'Low Stock',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.successGreen.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.successGreen.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_rounded, size: 14, color: AppTheme.successGreen),
          Gap(AppSpacing.xs),
          Text(
            'In Stock',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.successGreen,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetailSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.neutralGray900,
                letterSpacing: 0.5,
              ),
        ),
        Gap(AppSpacing.md),
        ...children,
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.neutralGray400),
          Gap(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.neutralGray500,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.neutralGray900,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LowStockAlert extends StatelessWidget {
  final int quantity;
  const _LowStockAlert({required this.quantity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppTheme.errorRed.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.errorRed.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_rounded, color: AppTheme.errorRed),
          Gap(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Critical Stock Level',
                  style: TextStyle(
                    color: AppTheme.errorRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Only $quantity units remaining.',
                  style: const TextStyle(color: AppTheme.errorRed, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Restock'),
          ),
        ],
      ),
    );
  }
}
