import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SummaryCardWidget extends StatelessWidget {
  final Map<String, dynamic> groceryRun;

  const SummaryCardWidget({
    super.key,
    required this.groceryRun,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final items = (groceryRun["items"] as List<Map<String, dynamic>>?) ?? [];
    final totalAmount = groceryRun["totalAmount"] as double? ?? 0.0;
    final categoryBreakdown = _calculateCategoryBreakdown(items);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Shopping Summary",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  context,
                  "Total Amount",
                  "\$${totalAmount.toStringAsFixed(2)}",
                  CustomIconWidget(
                    iconName: 'attach_money',
                    color: AppTheme.successLight,
                    size: 24,
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  "Items",
                  "${items.length}",
                  CustomIconWidget(
                    iconName: 'shopping_cart',
                    color: colorScheme.primary,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Text(
            "Spending by Category",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          ...categoryBreakdown.entries
              .map((entry) => _buildCategoryBreakdown(
                  context, entry.key, entry.value, totalAmount))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      BuildContext context, String label, String value, Widget icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          icon,
          SizedBox(height: 1.h),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(
      BuildContext context, String category, double amount, double total) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final percentage = total > 0 ? (amount / total) * 100 : 0.0;
    final categoryColor = _getCategoryColor(category);

    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                "\$${amount.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: colorScheme.outline.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Map<String, double> _calculateCategoryBreakdown(
      List<Map<String, dynamic>> items) {
    final Map<String, double> breakdown = {};

    for (final item in items) {
      final category = item["category"] as String? ?? "Other";
      final total = item["total"] as double? ?? 0.0;
      breakdown[category] = (breakdown[category] ?? 0.0) + total;
    }

    return breakdown;
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
