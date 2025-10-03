import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/date_time_picker_widget.dart';
import './widgets/input_method_cards_widget.dart';
import './widgets/notes_input_widget.dart';
import './widgets/store_selection_widget.dart';

class AddGroceryRun extends StatefulWidget {
  const AddGroceryRun({super.key});

  @override
  State<AddGroceryRun> createState() => _AddGroceryRunState();
}

class _AddGroceryRunState extends State<AddGroceryRun> {
  // Form state
  String? selectedStore;
  DateTime selectedDateTime = DateTime.now();
  String notes = '';
  String? capturedImagePath;
  int manualItemCount = 0;
  double manualTotal = 0.0;
  bool isLoading = false;

  // Camera related
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      if (!kIsWeb) {
        final hasPermission = await _requestCameraPermission();
        if (!hasPermission) return;
      }

      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        final camera = kIsWeb
            ? _cameras.firstWhere(
                (c) => c.lensDirection == CameraLensDirection.front,
                orElse: () => _cameras.first)
            : _cameras.firstWhere(
                (c) => c.lensDirection == CameraLensDirection.back,
                orElse: () => _cameras.first);

        _cameraController = CameraController(
            camera, kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high);

        await _cameraController!.initialize();
        await _applySettings();
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;

    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
      if (!kIsWeb) {
        try {
          await _cameraController!.setFlashMode(FlashMode.auto);
        } catch (e) {
          debugPrint('Flash mode not supported: $e');
        }
      }
    } catch (e) {
      debugPrint('Camera settings error: $e');
    }
  }

  Future<void> _capturePhoto() async {
    try {
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        final XFile photo = await _cameraController!.takePicture();
        setState(() {
          capturedImagePath = photo.path;
        });
      } else {
        // Fallback to image picker
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        );
        if (image != null) {
          setState(() {
            capturedImagePath = image.path;
          });
        }
      }
    } catch (e) {
      debugPrint('Photo capture error: $e');
      _showErrorSnackBar('Failed to capture photo. Please try again.');
    }
  }

  void _onStoreSelected(String store) {
    setState(() {
      selectedStore = store;
    });
  }

  void _onDateTimeChanged(DateTime dateTime) {
    setState(() {
      selectedDateTime = dateTime;
    });
  }

  void _onNotesChanged(String value) {
    if (value.length <= 500) {
      setState(() {
        notes = value;
      });
    }
  }

  void _onScanReceipt() {
    Navigator.pushNamed(context, '/receipt-scanner').then((result) {
      if (result != null && result is Map<String, dynamic>) {
        setState(() {
          capturedImagePath = result['imagePath'] as String?;
        });
      }
    });
  }

  void _onManualEntry() {
    // Navigate to manual entry screen (not implemented in this scope)
    setState(() {
      manualItemCount = 3; // Mock data for demonstration
      manualTotal = 45.67; // Mock data for demonstration
    });
    _showInfoSnackBar('Manual entry feature will be available soon');
  }

  void _onRetakePhoto() {
    setState(() {
      capturedImagePath = null;
    });
    _onScanReceipt();
  }

  void _onProcessReceipt() {
    if (capturedImagePath != null) {
      Navigator.pushNamed(context, '/ocr-review', arguments: {
        'imagePath': capturedImagePath,
        'store': selectedStore,
        'dateTime': selectedDateTime,
      });
    }
  }

  bool _canSave() {
    return selectedStore != null &&
        selectedStore!.isNotEmpty &&
        (capturedImagePath != null || manualItemCount > 0);
  }

  Future<void> _saveGroceryRun() async {
    if (!_canSave()) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Simulate saving process
      await Future.delayed(const Duration(seconds: 2));

      // Mock save success
      _showSuccessSnackBar('Grocery run saved successfully!');

      // Navigate back to dashboard
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/dashboard-home',
        (route) => false,
      );
    } catch (e) {
      _showErrorSnackBar('Failed to save grocery run. Please try again.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
            iconName:
                kIsWeb || Theme.of(context).platform == TargetPlatform.android
                    ? 'arrow_back'
                    : 'close',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
        ),
        title: Text(
          'Add Grocery Run',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: ElevatedButton(
              onPressed: _canSave() && !isLoading ? _saveGroceryRun : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canSave()
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.3),
                foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 4.w,
                      height: 4.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.lightTheme.colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Text(
                      'Save',
                      style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Store Selection
              StoreSelectionWidget(
                selectedStore: selectedStore,
                onStoreSelected: _onStoreSelected,
              ),

              SizedBox(height: 3.h),

              // Date & Time Picker
              DateTimePickerWidget(
                selectedDateTime: selectedDateTime,
                onDateTimeChanged: _onDateTimeChanged,
              ),

              SizedBox(height: 3.h),

              // Input Method Cards
              InputMethodCardsWidget(
                onScanReceipt: _onScanReceipt,
                onManualEntry: _onManualEntry,
                capturedImagePath: capturedImagePath,
                onRetakePhoto: _onRetakePhoto,
                onProcessReceipt: _onProcessReceipt,
                manualItemCount: manualItemCount,
                manualTotal: manualTotal,
              ),

              SizedBox(height: 3.h),

              // Notes Input
              NotesInputWidget(
                notes: notes,
                onNotesChanged: _onNotesChanged,
              ),

              SizedBox(height: 4.h),

              // Save Button (Mobile)
              if (!kIsWeb) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _canSave() && !isLoading ? _saveGroceryRun : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _canSave()
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.3),
                      foregroundColor:
                          AppTheme.lightTheme.colorScheme.onPrimary,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 5.w,
                                height: 5.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.lightTheme.colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                'Saving...',
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'Save Grocery Run',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onPrimary,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 2.h),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
