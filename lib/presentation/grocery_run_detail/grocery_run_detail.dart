import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/grocery_run_header_widget.dart';
import './widgets/item_list_widget.dart';
import './widgets/notes_section_widget.dart';
import './widgets/receipt_modal_widget.dart';
import './widgets/summary_card_widget.dart';

class GroceryRunDetail extends StatefulWidget {
  const GroceryRunDetail({super.key});

  @override
  State<GroceryRunDetail> createState() => _GroceryRunDetailState();
}

class _GroceryRunDetailState extends State<GroceryRunDetail> {
  bool _isEditMode = false;
  late Map<String, dynamic> _groceryRunData;

  // Mock data for the grocery run detail
  final Map<String, dynamic> _mockGroceryRun = {
    "id": 1,
    "storeName": "Whole Foods Market",
    "date": DateTime.now().subtract(const Duration(days: 2)),
    "duration": "45 minutes",
    "totalAmount": 127.84,
    "receiptImage":
        "https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
    "notes":
        "Found great deals on organic produce. The store was less crowded than usual. Remembered to use the \$5 off coupon for spending over \$100.",
    "items": [
      {
        "id": 1,
        "name": "Organic Bananas",
        "category": "Produce",
        "quantity": "2 lbs",
        "unitPrice": 1.99,
        "total": 3.98,
        "priceComparison": "lower"
      },
      {
        "id": 2,
        "name": "Whole Milk",
        "category": "Dairy",
        "quantity": "1 gallon",
        "unitPrice": 4.49,
        "total": 4.49,
        "priceComparison": "average"
      },
      {
        "id": 3,
        "name": "Free Range Chicken Breast",
        "category": "Meat",
        "quantity": "2.5 lbs",
        "unitPrice": 8.99,
        "total": 22.48,
        "priceComparison": "higher"
      },
      {
        "id": 4,
        "name": "Sourdough Bread",
        "category": "Bakery",
        "quantity": "1 loaf",
        "unitPrice": 3.99,
        "total": 3.99,
        "priceComparison": "average"
      },
      {
        "id": 5,
        "name": "Greek Yogurt",
        "category": "Dairy",
        "quantity": "32 oz",
        "unitPrice": 5.99,
        "total": 5.99,
        "priceComparison": "lower"
      },
      {
        "id": 6,
        "name": "Organic Spinach",
        "category": "Produce",
        "quantity": "5 oz bag",
        "unitPrice": 2.99,
        "total": 2.99,
        "priceComparison": "average"
      },
      {
        "id": 7,
        "name": "Frozen Blueberries",
        "category": "Frozen",
        "quantity": "1 lb bag",
        "unitPrice": 4.99,
        "total": 4.99,
        "priceComparison": "lower"
      },
      {
        "id": 8,
        "name": "Olive Oil",
        "category": "Pantry",
        "quantity": "500ml",
        "unitPrice": 12.99,
        "total": 12.99,
        "priceComparison": "higher"
      },
      {
        "id": 9,
        "name": "Cheddar Cheese",
        "category": "Dairy",
        "quantity": "8 oz block",
        "unitPrice": 6.99,
        "total": 6.99,
        "priceComparison": "average"
      },
      {
        "id": 10,
        "name": "Roma Tomatoes",
        "category": "Produce",
        "quantity": "3 lbs",
        "unitPrice": 1.99,
        "total": 5.97,
        "priceComparison": "lower"
      },
      {
        "id": 11,
        "name": "Pasta",
        "category": "Pantry",
        "quantity": "1 lb box",
        "unitPrice": 1.49,
        "total": 1.49,
        "priceComparison": "average"
      },
      {
        "id": 12,
        "name": "Ice Cream",
        "category": "Frozen",
        "quantity": "1 pint",
        "unitPrice": 5.99,
        "total": 5.99,
        "priceComparison": "higher"
      }
    ]
  };

  @override
  void initState() {
    super.initState();
    _groceryRunData = Map<String, dynamic>.from(_mockGroceryRun);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 1,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: CustomIconWidget(
            iconName: 'arrow_back_ios',
            color: colorScheme.onSurface,
            size: 20,
          ),
        ),
        title: Text(
          "Grocery Run Details",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _toggleEditMode,
            icon: CustomIconWidget(
              iconName: _isEditMode ? 'check' : 'edit',
              color: colorScheme.primary,
              size: 24,
            ),
            tooltip: _isEditMode ? 'Save Changes' : 'Edit Run',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy),
                    SizedBox(width: 12),
                    Text('Duplicate Run'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Delete Run', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with store info and receipt thumbnail
            GroceryRunHeaderWidget(
              groceryRun: _groceryRunData,
              onEditPressed: _toggleEditMode,
              onReceiptTapped: _showReceiptModal,
            ),

            SizedBox(height: 3.h),

            // Summary card with totals and category breakdown
            SummaryCardWidget(
              groceryRun: _groceryRunData,
            ),

            SizedBox(height: 3.h),

            // Items list grouped by category
            Text(
              "Items (${(_groceryRunData["items"] as List).length})",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),

            SizedBox(height: 2.h),

            ItemListWidget(
              items:
                  (_groceryRunData["items"] as List<Map<String, dynamic>>?) ??
                      [],
              onItemEdit: _handleItemEdit,
              onItemDelete: _handleItemDelete,
            ),

            SizedBox(height: 3.h),

            // Notes section
            NotesSectionWidget(
              notes: _groceryRunData["notes"] as String?,
              onNotesChanged: _handleNotesChanged,
              isEditable: _isEditMode,
            ),

            SizedBox(height: 10.h), // Extra space for floating button
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _shareGroceryRun,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: CustomIconWidget(
          iconName: 'share',
          color: colorScheme.onPrimary,
          size: 20,
        ),
        label: Text(
          'Share',
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });

    if (!_isEditMode) {
      // Save changes
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Changes saved successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showReceiptModal() {
    final receiptImage = _groceryRunData["receiptImage"] as String?;
    if (receiptImage != null) {
      showDialog(
        context: context,
        builder: (context) => ReceiptModalWidget(
          receiptImageUrl: receiptImage,
        ),
      );
    }
  }

  void _handleItemEdit(int index, Map<String, dynamic> item) {
    HapticFeedback.selectionClick();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Item'),
        content: Text(
            'Edit functionality for "${item["name"]}" would be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${item["name"]} updated')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _handleItemDelete(int index) {
    setState(() {
      final items = _groceryRunData["items"] as List<Map<String, dynamic>>;
      if (index >= 0 && index < items.length) {
        items.removeAt(index);
        // Recalculate total
        final newTotal = items.fold<double>(
            0.0, (sum, item) => sum + (item["total"] as double? ?? 0.0));
        _groceryRunData["totalAmount"] = newTotal;
      }
    });
    HapticFeedback.lightImpact();
  }

  void _handleNotesChanged(String newNotes) {
    setState(() {
      _groceryRunData["notes"] = newNotes;
    });
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'duplicate':
        HapticFeedback.selectionClick();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Grocery run duplicated'),
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 'delete':
        _showDeleteConfirmation();
        break;
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Grocery Run'),
        content: const Text(
            'Are you sure you want to delete this grocery run? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to previous screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Grocery run deleted'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorLight,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _shareGroceryRun() {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Share Grocery Run',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 3.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShareOption(
                    context,
                    'PDF Export',
                    'picture_as_pdf',
                    () => _exportAsPDF(),
                  ),
                  _buildShareOption(
                    context,
                    'Text Summary',
                    'text_snippet',
                    () => _shareAsText(),
                  ),
                  _buildShareOption(
                    context,
                    'CSV Export',
                    'table_chart',
                    () => _exportAsCSV(),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShareOption(
      BuildContext context, String label, String iconName, VoidCallback onTap) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: iconName,
                color: colorScheme.primary,
                size: 24,
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _exportAsPDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF export functionality would be implemented here'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareAsText() {
    final storeName =
        _groceryRunData["storeName"] as String? ?? "Unknown Store";
    final date = _formatDate(_groceryRunData["date"] as DateTime?);
    final total = _groceryRunData["totalAmount"] as double? ?? 0.0;
    final items = _groceryRunData["items"] as List<Map<String, dynamic>>? ?? [];

    final textSummary = '''
Grocery Run Summary
Store: $storeName
Date: $date
Total: \$${total.toStringAsFixed(2)}

Items (${items.length}):
${items.map((item) => '• ${item["name"]} - \$${(item["total"] as double? ?? 0.0).toStringAsFixed(2)}').join('\n')}

Generated by GroceryTracker
''';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Text summary copied to clipboard'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Text Summary'),
                content: SingleChildScrollView(
                  child: Text(textSummary),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _exportAsCSV() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CSV export functionality would be implemented here'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return "Unknown Date";
    return "${dateTime.month}/${dateTime.day}/${dateTime.year}";
  }
}
