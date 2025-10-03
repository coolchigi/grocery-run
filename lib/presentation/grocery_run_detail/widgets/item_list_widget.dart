import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ItemListWidget extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final Function(int, Map<String, dynamic>)? onItemEdit;
  final Function(int)? onItemDelete;

  const ItemListWidget({
    super.key,
    required this.items,
    this.onItemEdit,
    this.onItemDelete,
  });

  @override
  State<ItemListWidget> createState() => _ItemListWidgetState();
}

class _ItemListWidgetState extends State<ItemListWidget> {
  final Map<String, bool> _expandedCategories = {};
  final Map<String, GlobalKey> _categoryKeys = {};

  @override
  void initState() {
    super.initState();
    _initializeCategories();
  }

  void _initializeCategories() {
    final categories = _getCategories();
    for (final category in categories) {
      _expandedCategories[category] = true;
      _categoryKeys[category] = GlobalKey();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final groupedItems = _groupItemsByCategory();

    if (groupedItems.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: 'shopping_cart_outlined',
              color: colorScheme.onSurface.withValues(alpha: 0.4),
              size: 48,
            ),
            SizedBox(height: 2.h),
            Text(
              "No items found",
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: groupedItems.entries.map((entry) {
        final category = entry.key;
        final categoryItems = entry.value;
        final isExpanded = _expandedCategories[category] ?? true;

        return Container(
          margin: EdgeInsets.only(bottom: 2.h),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildCategoryHeader(
                  context, category, categoryItems.length, isExpanded),
              if (isExpanded) ...[
                ...categoryItems.asMap().entries.map((itemEntry) {
                  final itemIndex = widget.items.indexOf(itemEntry.value);
                  return _buildItemCard(context, itemEntry.value, itemIndex);
                }).toList(),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryHeader(
      BuildContext context, String category, int itemCount, bool isExpanded) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categoryColor = _getCategoryColor(category);

    return GestureDetector(
      onTap: () {
        setState(() {
          _expandedCategories[category] = !isExpanded;
        });
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: categoryColor.withValues(alpha: 0.1),
          borderRadius: isExpanded
              ? const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                )
              : BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: categoryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    "$itemCount ${itemCount == 1 ? 'item' : 'items'}",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: isExpanded ? 'expand_less' : 'expand_more',
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(
      BuildContext context, Map<String, dynamic> item, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final name = item["name"] as String? ?? "Unknown Item";
    final quantity = item["quantity"] as String? ?? "1";
    final unitPrice = item["unitPrice"] as double? ?? 0.0;
    final total = item["total"] as double? ?? 0.0;
    final priceComparison = item["priceComparison"] as String?;

    return Dismissible(
      key: Key("item_$index"),
      background: Container(
        color: colorScheme.primary.withValues(alpha: 0.1),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 4.w),
        child: CustomIconWidget(
          iconName: 'edit',
          color: colorScheme.primary,
          size: 24,
        ),
      ),
      secondaryBackground: Container(
        color: AppTheme.errorLight.withValues(alpha: 0.1),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 4.w),
        child: CustomIconWidget(
          iconName: 'delete',
          color: AppTheme.errorLight,
          size: 24,
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          widget.onItemEdit?.call(index, item);
          return false;
        } else if (direction == DismissDirection.endToStart) {
          return await _showDeleteConfirmation(context, name);
        }
        return false;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          widget.onItemDelete?.call(index);
          _showUndoSnackBar(context, name, index, item);
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (priceComparison != null) ...[
                        SizedBox(width: 2.w),
                        _buildPriceComparisonBadge(context, priceComparison),
                      ],
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      Text(
                        "Qty: $quantity",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        "Unit: \$${unitPrice.toStringAsFixed(2)}",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 3.w),
            Text(
              "\$${total.toStringAsFixed(2)}",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceComparisonBadge(BuildContext context, String comparison) {
    final theme = Theme.of(context);
    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    switch (comparison.toLowerCase()) {
      case 'higher':
        badgeColor = AppTheme.errorLight;
        badgeText = 'High';
        badgeIcon = Icons.trending_up;
        break;
      case 'lower':
        badgeColor = AppTheme.successLight;
        badgeText = 'Low';
        badgeIcon = Icons.trending_down;
        break;
      default:
        badgeColor = AppTheme.warningLight;
        badgeText = 'Avg';
        badgeIcon = Icons.trending_flat;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            badgeIcon,
            size: 12,
            color: badgeColor,
          ),
          SizedBox(width: 1.w),
          Text(
            badgeText,
            style: theme.textTheme.labelSmall?.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(
      BuildContext context, String itemName) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Item'),
            content: Text('Are you sure you want to delete "$itemName"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showUndoSnackBar(BuildContext context, String itemName, int index,
      Map<String, dynamic> item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$itemName deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Handle undo functionality
            setState(() {
              // Re-add item logic would go here
            });
          },
        ),
      ),
    );
  }

  Map<String, List<Map<String, dynamic>>> _groupItemsByCategory() {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final item in widget.items) {
      final category = item["category"] as String? ?? "Other";
      grouped.putIfAbsent(category, () => []).add(item);
    }

    return grouped;
  }

  List<String> _getCategories() {
    return widget.items
        .map((item) => item["category"] as String? ?? "Other")
        .toSet()
        .toList();
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'produce':
        return const Color(0xFF10B981);
      case 'dairy':
        return const Color(0xFF3B82F6);
      case 'meat':
        return const Color(0xFFEF4444);
      case 'bakery':
        return const Color(0xFFF59E0B);
      case 'frozen':
        return const Color(0xFF8B5CF6);
      case 'pantry':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF9CA3AF);
    }
  }
}
