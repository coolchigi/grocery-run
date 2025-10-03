import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/camera_controls_widget.dart';
import './widgets/camera_overlay_widget.dart';
import './widgets/permission_dialog_widget.dart';
import './widgets/preview_controls_widget.dart';

enum ScannerState {
  initializing,
  camera,
  preview,
  processing,
  error,
}

class ReceiptScanner extends StatefulWidget {
  const ReceiptScanner({super.key});

  @override
  State<ReceiptScanner> createState() => _ReceiptScannerState();
}

class _ReceiptScannerState extends State<ReceiptScanner>
    with WidgetsBindingObserver {
  // Camera related
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;

  // State management
  ScannerState _currentState = ScannerState.initializing;
  XFile? _capturedImage;
  String? _errorMessage;
  bool _isProcessing = false;

  // Image picker
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true; // Browser handles permissions

    final status = await Permission.camera.request();
    if (status.isDenied) {
      final result =
          await PermissionDialogWidget.showCameraPermissionDialog(context);
      if (result == true) {
        final newStatus = await Permission.camera.request();
        return newStatus.isGranted;
      }
      return false;
    }
    return status.isGranted;
  }

  Future<void> _initializeCamera() async {
    try {
      setState(() {
        _currentState = ScannerState.initializing;
        _errorMessage = null;
      });

      // Request camera permission
      final hasPermission = await _requestCameraPermission();
      if (!hasPermission) {
        setState(() {
          _currentState = ScannerState.error;
          _errorMessage = 'Camera permission is required to scan receipts';
        });
        return;
      }

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _currentState = ScannerState.error;
          _errorMessage = 'No cameras found on this device';
        });
        return;
      }

      // Select appropriate camera
      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first)
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first);

      // Initialize camera controller
      _cameraController = CameraController(
        camera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      // Apply camera settings (skip unsupported features on web)
      await _applyCameraSettings();

      setState(() {
        _isCameraInitialized = true;
        _currentState = ScannerState.camera;
      });
    } catch (e) {
      setState(() {
        _currentState = ScannerState.error;
        _errorMessage = 'Failed to initialize camera: ${e.toString()}';
      });
    }
  }

  Future<void> _applyCameraSettings() async {
    if (_cameraController == null) return;

    try {
      // Set focus mode (works on most platforms)
      await _cameraController!.setFocusMode(FocusMode.auto);

      // Set flash mode (skip on web as it's not supported)
      if (!kIsWeb) {
        try {
          await _cameraController!.setFlashMode(FlashMode.off);
        } catch (e) {
          // Flash not supported on this device
        }
      }
    } catch (e) {
      // Settings not supported, continue without them
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      setState(() => _isProcessing = true);

      // Add haptic feedback
      if (!kIsWeb) {
        HapticFeedback.lightImpact();
      }

      final XFile photo = await _cameraController!.takePicture();

      setState(() {
        _capturedImage = photo;
        _currentState = ScannerState.preview;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Failed to capture photo: ${e.toString()}';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture photo. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _selectFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _capturedImage = image;
          _currentState = ScannerState.preview;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select image from gallery'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || kIsWeb) return;

    try {
      final newFlashMode = _isFlashOn ? FlashMode.off : FlashMode.torch;
      await _cameraController!.setFlashMode(newFlashMode);
      setState(() => _isFlashOn = !_isFlashOn);
    } catch (e) {
      // Flash not supported
    }
  }

  Future<void> _processReceipt() async {
    if (_capturedImage == null) return;

    setState(() {
      _currentState = ScannerState.processing;
      _isProcessing = true;
    });

    try {
      // Simulate OCR processing with realistic delay
      await Future.delayed(const Duration(seconds: 3));

      // Mock extracted data for demonstration
      final extractedData = {
        'store_name': 'Fresh Market',
        'date': '2025-09-29',
        'time': '14:30',
        'total': '45.67',
        'items': [
          {'name': 'Organic Bananas', 'price': '3.99', 'quantity': '2 lbs'},
          {'name': 'Whole Milk', 'price': '4.29', 'quantity': '1 gal'},
          {
            'name': 'Bread - Whole Wheat',
            'price': '2.89',
            'quantity': '1 loaf'
          },
          {'name': 'Chicken Breast', 'price': '12.99', 'quantity': '2.5 lbs'},
          {'name': 'Mixed Vegetables', 'price': '5.49', 'quantity': '1 bag'},
        ],
        'image_path': _capturedImage!.path,
      };

      // Navigate to OCR review screen with extracted data
      if (mounted) {
        Navigator.pushNamed(
          context,
          '/ocr-review',
          arguments: extractedData,
        );
      }
    } catch (e) {
      setState(() {
        _currentState = ScannerState.error;
        _errorMessage = 'Failed to process receipt. Please try again.';
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Receipt processing failed. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _retakePhoto() {
    setState(() {
      _capturedImage = null;
      _currentState = ScannerState.camera;
      _isProcessing = false;
    });
  }

  void _closeScanner() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildBody(context, theme, colorScheme),
    );
  }

  Widget _buildBody(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    switch (_currentState) {
      case ScannerState.initializing:
        return _buildInitializingView(theme, colorScheme);

      case ScannerState.camera:
        return _buildCameraView(context, theme, colorScheme);

      case ScannerState.preview:
        return _buildPreviewView(context, theme, colorScheme);

      case ScannerState.processing:
        return _buildProcessingView(theme, colorScheme);

      case ScannerState.error:
        return _buildErrorView(context, theme, colorScheme);
    }
  }

  Widget _buildInitializingView(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
          SizedBox(height: 3.h),
          Text(
            'Initializing Camera...',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraView(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    if (!_isCameraInitialized || _cameraController == null) {
      return _buildInitializingView(theme, colorScheme);
    }

    return Stack(
      children: [
        // Camera preview
        Positioned.fill(
          child: CameraPreview(_cameraController!),
        ),

        // Camera overlay with receipt frame
        CameraOverlayWidget(
          isProcessing: _isProcessing,
          statusMessage: _isProcessing ? 'Capturing...' : null,
        ),

        // Camera controls
        CameraControlsWidget(
          onCapture: _capturePhoto,
          onFlashToggle: _toggleFlash,
          onGallerySelect: _selectFromGallery,
          onClose: _closeScanner,
          isFlashOn: _isFlashOn,
          isCapturing: _isProcessing,
          canUseFlash: !kIsWeb,
        ),
      ],
    );
  }

  Widget _buildPreviewView(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    if (_capturedImage == null) {
      return _buildErrorView(context, theme, colorScheme);
    }

    return Stack(
      children: [
        // Image preview
        Positioned.fill(
          child: kIsWeb
              ? Image.network(
                  _capturedImage!.path,
                  fit: BoxFit.contain,
                )
              : Image.network(
                  _capturedImage!.path,
                  fit: BoxFit.contain,
                ),
        ),

        // Preview controls
        PreviewControlsWidget(
          onRetake: _retakePhoto,
          onProcess: _processReceipt,
          onClose: _closeScanner,
          isProcessing: _isProcessing,
        ),
      ],
    );
  }

  Widget _buildProcessingView(ThemeData theme, ColorScheme colorScheme) {
    return CameraOverlayWidget(
      isProcessing: true,
      statusMessage: 'Processing receipt...',
    );
  }

  Widget _buildErrorView(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'error_outline',
              color: colorScheme.error,
              size: 64,
            ),
            SizedBox(height: 3.h),
            Text(
              'Camera Error',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              _errorMessage ?? 'Something went wrong with the camera',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _closeScanner,
                    child: Container(
                      height: 6.h,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Close',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: GestureDetector(
                    onTap: _initializeCamera,
                    child: Container(
                      height: 6.h,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Retry',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
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
}
