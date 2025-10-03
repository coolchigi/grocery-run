import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class PermissionDialogWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onAllow;
  final VoidCallback? onDeny;
  final String allowButtonText;
  final String denyButtonText;

  const PermissionDialogWidget({
    super.key,
    required this.title,
    required this.message,
    this.onAllow,
    this.onDeny,
    this.allowButtonText = 'Allow',
    this.denyButtonText = 'Not Now',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 16.w,
              height: 16.w,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'camera_alt',
                color: colorScheme.primary,
                size: 32,
              ),
            ),

            SizedBox(height: 3.h),

            // Title
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 2.h),

            // Message
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 4.h),

            // Buttons
            Row(
              children: [
                // Deny button
                Expanded(
                  child: GestureDetector(
                    onTap: onDeny,
                    child: Container(
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          denyButtonText,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 3.w),

                // Allow button
                Expanded(
                  child: GestureDetector(
                    onTap: onAllow,
                    child: Container(
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          allowButtonText,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

  static Future<bool?> showCameraPermissionDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PermissionDialogWidget(
        title: 'Camera Access Required',
        message:
            'GroceryTracker needs camera access to scan your receipts and extract purchase information automatically.',
        onAllow: () => Navigator.of(context).pop(true),
        onDeny: () => Navigator.of(context).pop(false),
        allowButtonText: 'Allow Camera',
        denyButtonText: 'Cancel',
      ),
    );
  }

  static Future<bool?> showStoragePermissionDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PermissionDialogWidget(
        title: 'Storage Access Required',
        message:
            'GroceryTracker needs storage access to save receipt images and processed data on your device.',
        onAllow: () => Navigator.of(context).pop(true),
        onDeny: () => Navigator.of(context).pop(false),
        allowButtonText: 'Allow Storage',
        denyButtonText: 'Cancel',
      ),
    );
  }
}
