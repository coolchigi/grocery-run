import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class CameraOverlayWidget extends StatelessWidget {
  final bool isProcessing;
  final String? statusMessage;

  const CameraOverlayWidget({
    super.key,
    this.isProcessing = false,
    this.statusMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      children: [
        // Dark overlay with cutout for receipt frame
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withValues(alpha: 0.6),
          child: CustomPaint(
            painter: ReceiptFramePainter(
              frameColor: colorScheme.primary,
              backgroundColor: Colors.black.withValues(alpha: 0.6),
            ),
          ),
        ),

        // Receipt positioning guide
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Receipt frame container
              Container(
                width: 75.w,
                height: 45.h,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colorScheme.primary,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    // Corner guides
                    ...List.generate(
                        4,
                        (index) => _buildCornerGuide(
                              context,
                              index,
                              colorScheme.primary,
                            )),

                    // Center crosshair
                    Center(
                      child: CustomIconWidget(
                        iconName: 'center_focus_weak',
                        color: colorScheme.primary.withValues(alpha: 0.7),
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              // Instruction text
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusMessage ?? 'Align receipt within frame',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),

        // Processing overlay
        if (isProcessing)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withValues(alpha: 0.8),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Processing Receipt...',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Extracting text and data',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCornerGuide(BuildContext context, int index, Color color) {
    final positions = [
      Alignment.topLeft,
      Alignment.topRight,
      Alignment.bottomLeft,
      Alignment.bottomRight,
    ];

    return Positioned.fill(
      child: Align(
        alignment: positions[index],
        child: Container(
          width: 20,
          height: 20,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border(
              top: index < 2
                  ? BorderSide(color: color, width: 3)
                  : BorderSide.none,
              bottom: index >= 2
                  ? BorderSide(color: color, width: 3)
                  : BorderSide.none,
              left: index % 2 == 0
                  ? BorderSide(color: color, width: 3)
                  : BorderSide.none,
              right: index % 2 == 1
                  ? BorderSide(color: color, width: 3)
                  : BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}

class ReceiptFramePainter extends CustomPainter {
  final Color frameColor;
  final Color backgroundColor;

  ReceiptFramePainter({
    required this.frameColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final framePaint = Paint()
      ..color = frameColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Calculate frame dimensions
    final frameWidth = size.width * 0.75;
    final frameHeight = size.height * 0.45;
    final frameLeft = (size.width - frameWidth) / 2;
    final frameTop = (size.height - frameHeight) / 2;

    final frameRect =
        Rect.fromLTWH(frameLeft, frameTop, frameWidth, frameHeight);

    // Draw background with cutout
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(frameRect, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
