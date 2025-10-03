import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EditableItemCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback onDelete;
  final Function(Map<String, dynamic>) onUpdate;
  final bool isUnrecognized;

  const EditableItemCard({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onUpdate,
    this.isUnrecognized = false,
  });

  @override
  State<EditableItemCard> createState() => _EditableItemCardState();
}

class _EditableItemCardState extends State<EditableItemCard> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late int _quantity;
  late String _selectedCategory;
  late bool _isWeightBased;
  bool _isEditing = false;

  final List<String> _categories = [
    'Produce',
    'Dairy',
    'Meat',
    'Bakery',
    'Pantry',
    'Frozen',
    'Beverages',
    'Snacks',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item['name'] ?? '');
    _priceController = TextEditingController(
      text: (widget.item['price'] as double?)?.toStringAsFixed(2) ?? '0.00',
    );
    _quantity = widget.item['quantity'] ?? 1;
    _selectedCategory = widget.item['category'] ?? 'Other';
    _isWeightBased = widget.item['isWeightBased'] ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _updateItem() {
    final updatedItem = Map<String, dynamic>.from(widget.item);
    updatedItem['name'] = _nameController.text;
    updatedItem['price'] = double.tryParse(_priceController.text) ?? 0.0;
    updatedItem['quantity'] = _quantity;
    updatedItem['category'] = _selectedCategory;
    updatedItem['isWeightBased'] = _isWeightBased;
    widget.onUpdate(updatedItem);
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Item',
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        content: Text(
          'Are you sure you want to delete "${_nameController.text}"?',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete();
            },
            child: Text(
              'Delete',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(widget.item['id']),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _showDeleteConfirmation(),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            foregroundColor: AppTheme.lightTheme.colorScheme.onError,
            icon: Icons.delete,
            label: 'Delete',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.isUnrecognized
                ? AppTheme.lightTheme.colorScheme.tertiary
                : AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
            width: widget.isUnrecognized ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.colorScheme.shadow
                  .withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _nameController,
                                style: AppTheme.lightTheme.textTheme.titleSmall,
                                decoration: InputDecoration(
                                  hintText: 'Item name',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  hintStyle: AppTheme
                                      .lightTheme.textTheme.titleSmall
                                      ?.copyWith(
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                onChanged: (_) => _updateItem(),
                              ),
                            ),
                            if (widget.isUnrecognized) ...[
                              SizedBox(width: 2.w),
                              CustomIconWidget(
                                iconName: 'edit',
                                color: AppTheme.lightTheme.colorScheme.tertiary,
                                size: 16,
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 1.h),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedCategory,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 3.w, vertical: 1.h),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: AppTheme
                                          .lightTheme.colorScheme.outline
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: AppTheme
                                          .lightTheme.colorScheme.outline
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                ),
                                items: _categories.map((category) {
                                  return DropdownMenuItem(
                                    value: category,
                                    child: Text(
                                      category,
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedCategory = value;
                                    });
                                    _updateItem();
                                  }
                                },
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Row(
                              children: [
                                Checkbox(
                                  value: _isWeightBased,
                                  onChanged: (value) {
                                    setState(() {
                                      _isWeightBased = value ?? false;
                                    });
                                    _updateItem();
                                  },
                                ),
                                Text(
                                  'Weight',
                                  style:
                                      AppTheme.lightTheme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        TextField(
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}')),
                          ],
                          style: AppTheme.lightTheme.textTheme.titleSmall,
                          decoration: InputDecoration(
                            prefixText: '\$',
                            prefixStyle:
                                AppTheme.lightTheme.textTheme.titleSmall,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 3.w, vertical: 1.h),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppTheme.lightTheme.colorScheme.outline
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppTheme.lightTheme.colorScheme.outline
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                          onChanged: (_) => _updateItem(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quantity',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppTheme.lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: _quantity > 1
                                    ? () {
                                        setState(() {
                                          _quantity--;
                                        });
                                        _updateItem();
                                      }
                                    : null,
                                icon: CustomIconWidget(
                                  iconName: 'remove',
                                  color: _quantity > 1
                                      ? AppTheme.lightTheme.colorScheme.primary
                                      : AppTheme
                                          .lightTheme.colorScheme.onSurface
                                          .withValues(alpha: 0.3),
                                  size: 16,
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 8.w,
                                  minHeight: 4.h,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  _quantity.toString(),
                                  textAlign: TextAlign.center,
                                  style:
                                      AppTheme.lightTheme.textTheme.titleSmall,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _quantity++;
                                  });
                                  _updateItem();
                                },
                                icon: CustomIconWidget(
                                  iconName: 'add',
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  size: 16,
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 8.w,
                                  minHeight: 4.h,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
