import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class CameraControlsWidget extends StatelessWidget {
  final VoidCallback? onCapture;
  final VoidCallback? onFlashToggle;
  final VoidCallback? onGallerySelect;
  final VoidCallback? onClose;
  final bool isFlashOn;
  final bool isCapturing;
  final bool canUseFlash;

  const CameraControlsWidget({
    super.key,
    this.onCapture,
    this.onFlashToggle,
    this.onGallerySelect,
    this.onClose,
    this.isFlashOn = false,
    this.isCapturing = false,
    this.canUseFlash = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Top controls
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.7),
                Colors.transparent,
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Close button
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: CustomIconWidget(
                      iconName: 'close',
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),

                // Flash toggle (only show on mobile)
                if (!kIsWeb && canUseFlash)
                  GestureDetector(
                    onTap: onFlashToggle,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: isFlashOn
                            ? colorScheme.primary.withValues(alpha: 0.8)
                            : Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: isFlashOn ? 'flash_on' : 'flash_off',
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        const Spacer(),

        // Bottom controls
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withValues(alpha: 0.8),
                Colors.transparent,
              ],
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Gallery button
                GestureDetector(
                  onTap: isCapturing ? null : onGallerySelect,
                  child: Container(
                    width: 15.w,
                    height: 15.w,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: CustomIconWidget(
                      iconName: 'photo_library',
                      color: isCapturing
                          ? Colors.white.withValues(alpha: 0.5)
                          : Colors.white,
                      size: 28,
                    ),
                  ),
                ),

                // Capture button
                GestureDetector(
                  onTap: isCapturing ? null : onCapture,
                  child: Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      color: isCapturing
                          ? colorScheme.primary.withValues(alpha: 0.5)
                          : colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isCapturing
                        ? Center(
                            child: SizedBox(
                              width: 8.w,
                              height: 8.w,
                              child: CircularProgressIndicator(
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : CustomIconWidget(
                            iconName: 'camera_alt',
                            color: Colors.white,
                            size: 32,
                          ),
                  ),
                ),

                // Placeholder for symmetry
                SizedBox(width: 15.w),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
