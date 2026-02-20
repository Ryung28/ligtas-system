import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../core/design_system/app_theme.dart';
import '../../../core/design_system/app_spacing.dart';

class InventorySearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String searchQuery;
  final String selectedCategory;
  final Function(String) onSearchChanged;
  final Function(String) onCategoryChanged;
  final VoidCallback onClearSearch;

  const InventorySearchBar({
    super.key,
    required this.controller,
    required this.searchQuery,
    required this.selectedCategory,
    required this.onSearchChanged,
    required this.onCategoryChanged,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: AppTheme.neutralGray50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.neutralGray200),
            ),
            child: TextField(
              controller: controller,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search equipment...',
                hintStyle: TextStyle(
                  color: AppTheme.neutralGray400,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppTheme.neutralGray400,
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: onClearSearch,
                        icon: Icon(
                          Icons.close_rounded,
                          color: AppTheme.neutralGray400,
                          size: 20,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
          ),
          const Gap(AppSpacing.sm),
          
          // Category Filter Chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _CategoryChip(
                  label: 'All',
                  isSelected: selectedCategory == 'All',
                  onTap: () => onCategoryChanged('All'),
                ),
                const Gap(AppSpacing.xs),
                _CategoryChip(
                  label: 'Equipment',
                  isSelected: selectedCategory == 'Equipment',
                  onTap: () => onCategoryChanged('Equipment'),
                ),
                const Gap(AppSpacing.xs),
                _CategoryChip(
                  label: 'Vehicles',
                  isSelected: selectedCategory == 'Vehicles',
                  onTap: () => onCategoryChanged('Vehicles'),
                ),
                const Gap(AppSpacing.xs),
                _CategoryChip(
                  label: 'Safety Gear',
                  isSelected: selectedCategory == 'Safety Gear',
                  onTap: () => onCategoryChanged('Safety Gear'),
                ),
                const Gap(AppSpacing.xs),
                _CategoryChip(
                  label: 'Medical',
                  isSelected: selectedCategory == 'Medical',
                  onTap: () => onCategoryChanged('Medical'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryBlue : AppTheme.neutralGray600,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 13,
      ),
      selectedColor: AppTheme.primaryBlue.withOpacity(0.12),
      checkmarkColor: AppTheme.primaryBlue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryBlue : AppTheme.neutralGray200,
        ),
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}
