import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/add_item_button.dart';
import './widgets/editable_item_card.dart';
import './widgets/price_discrepancy_widget.dart';
import './widgets/store_info_header.dart';

class OcrReview extends StatefulWidget {
  const OcrReview({super.key});

  @override
  State<OcrReview> createState() => _OcrReviewState();
}

class _OcrReviewState extends State<OcrReview> {
  late List<Map<String, dynamic>> _extractedItems;
  late String _storeName;
  late double _receiptTotal;
  late DateTime _receiptDate;
  bool _isLoading = false;

  // Mock OCR extracted data
  final List<Map<String, dynamic>> _mockExtractedItems = [
{ 'id': '1',
'name': 'Organic Bananas',
'price': 3.49,
'quantity': 1,
'category': 'Produce',
'isWeightBased': true,
'confidence': 0.95,
},
{ 'id': '2',
'name': 'Whole Milk',
'price': 4.29,
'quantity': 1,
'category': 'Dairy',
'isWeightBased': false,
'confidence': 0.98,
},
{ 'id': '3',
'name': 'Bread Loaf',
'price': 2.99,
'quantity': 2,
'category': 'Bakery',
'isWeightBased': false,
'confidence': 0.92,
},
{ 'id': '4',
'name': 'Chicken Breast',
'price': 8.47,
'quantity': 1,
'category': 'Meat',
'isWeightBased': true,
'confidence': 0.88,
},
{ 'id': '5',
'name': 'Tomato Sauce',
'price': 1.89,
'quantity': 3,
'category': 'Pantry',
'isWeightBased': false,
'confidence': 0.75, // Low confidence - will be marked as unrecognized
},
];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _extractedItems = List.from(_mockExtractedItems);
    _storeName = 'Fresh Market Grocery';
    _receiptTotal = 23.45;
    _receiptDate = DateTime.now().subtract(const Duration(hours: 2));
  }

  double get _calculatedTotal {
    return _extractedItems.fold(0.0, (sum, item) {
      final price = item['price'] as double? ?? 0.0;
      final quantity = item['quantity'] as int? ?? 1;
      return sum + (price * quantity);
    });
  }

  List<Map<String, dynamic>> get _unrecognizedItems {
    return _extractedItems.where((item) {
      final confidence = item['confidence'] as double? ?? 1.0;
      return confidence < 0.8;
    }).toList();
  }

  void _updateItem(int index, Map<String, dynamic> updatedItem) {
    setState(() {
      _extractedItems[index] = updatedItem;
    });
  }

  void _deleteItem(int index) {
    setState(() {
      _extractedItems.removeAt(index);
    });
  }

  void _addNewItem() {
    final newItem = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': '',
      'price': 0.0,
      'quantity': 1,
      'category': 'Other',
      'isWeightBased': false,
      'confidence': 1.0,
    };

    setState(() {
      _extractedItems.add(newItem);
    });

    // Scroll to the new item
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _handleReconciliation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Price Reconciliation',
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The calculated total doesn\'t match the receipt total. This could be due to:',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            Text(
              '• Tax not included in item prices',
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
            Text(
              '• Discounts or coupons applied',
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
            Text(
              '• OCR reading errors',
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
            Text(
              '• Missing or extra items',
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
            SizedBox(height: 2.h),
            Text(
              'Please review the items and prices carefully.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveAllItems() async {
    // Validate that all items have names and valid prices
    final invalidItems = _extractedItems.where((item) {
      final name = item['name'] as String? ?? '';
      final price = item['price'] as double? ?? 0.0;
      return name.trim().isEmpty || price <= 0;
    }).toList();

    if (invalidItems.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please complete all item names and prices before saving.',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onError,
            ),
          ),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate saving process
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    // Show success message and navigate back
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Grocery run saved successfully!',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSecondary,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
      ),
    );

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/dashboard-home',
      (route) => false,
    );
  }

  void _startOver() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Start Over',
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        content: Text(
          'This will clear all extracted data and take you back to manual entry. Are you sure?',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/add-grocery-run');
            },
            child: Text(
              'Start Over',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 1,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back_ios',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 20,
          ),
        ),
        title: Text(
          'Review & Edit',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_extractedItems.isEmpty)
            TextButton(
              onPressed: _startOver,
              child: Text(
                'Start Over',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.error,
                ),
              ),
            )
          else
            TextButton(
              onPressed: _isLoading ? null : _saveAllItems,
              child: _isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                    )
                  : Text(
                      'Save All',
                      style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          SizedBox(width: 2.w),
        ],
      ),
      body: Column(
        children: [
          StoreInfoHeader(
            storeName: _storeName,
            total: _receiptTotal,
            date: _receiptDate,
          ),
          Expanded(
            child: _extractedItems.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.only(bottom: 2.h),
                    itemCount: _extractedItems.length + 2, // +2 for discrepancy widget and add button
                    itemBuilder: (context, index) {
                      if (index == _extractedItems.length) {
                        return PriceDiscrepancyWidget(
                          calculatedTotal: _calculatedTotal,
                          receiptTotal: _receiptTotal,
                          onReconcile: _handleReconciliation,
                        );
                      }
                      
                      if (index == _extractedItems.length + 1) {
                        return AddItemButton(onPressed: _addNewItem);
                      }

                      final item = _extractedItems[index];
                      final isUnrecognized = _unrecognizedItems.contains(item);

                      return EditableItemCard(
                        key: ValueKey(item['id']),
                        item: item,
                        isUnrecognized: isUnrecognized,
                        onUpdate: (updatedItem) => _updateItem(index, updatedItem),
                        onDelete: () => _deleteItem(index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'receipt_long',
              color: AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.3),
              size: 64,
            ),
            SizedBox(height: 3.h),
            Text(
              'No Items Detected',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'The receipt couldn\'t be read properly. You can start over with manual entry or try scanning again.',
              textAlign: TextAlign.center,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/receipt-scanner'),
                    child: Text(
                      'Try Again',
                      style: AppTheme.lightTheme.textTheme.labelLarge,
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _startOver,
                    child: Text(
                      'Manual Entry',
                      style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}