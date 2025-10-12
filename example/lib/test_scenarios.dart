import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zeb_permissions_helper/zeb_permissions_helper.dart';

class TestScenarios {
  static final ZebPermissionsHelper helper = ZebPermissionsHelper();

  /// Test 1: Single permission with default settings
  static Future<void> testSinglePermission(BuildContext context) async {
    final result = await helper.requestPermission(
      context,
      Permission.camera,
      requestConfig: const SingleRequestConfig(
        showPurposeDialog: true,
      ),
    );

    _showResultSnackbar(context, 'Camera: ${result.isGranted}');
  }

  /// Test 2: Single permission with custom dialog
  static Future<void> testSinglePermissionCustomDialog(
      BuildContext context) async {
    final result = await helper.requestPermission(
      context,
      Permission.location,
      requestConfig: SingleRequestConfig(
        package: PermissionPackage.location,
        dialogText: const DialogText(
          title: 'Custom Location Access',
          explanation: 'We need location for customized features...',
          caution: 'Please enable location in settings for full functionality',
        ),
        showPurposeDialog: true,
      ),
    );

    _showResultSnackbar(
        context, 'Location: ${result.isGranted} (${result.usedPackage})');
  }

  /// Test 3: Multiple permissions at once
  static Future<void> testMultiplePermissions(BuildContext context) async {
    final results = await helper.requestMultiplePermissions(
      context,
      [Permission.camera, Permission.microphone, Permission.photos],
      requestConfigs: {
        Permission.camera: const SingleRequestConfig(showPurposeDialog: false),
      },
    );

    final summary =
        results.map((r) => '${r.permission}: ${r.isGranted}').join(', ');
    _showResultSnackbar(context, 'Multiple: $summary');
  }

  /// Test 4: Sequential permissions (onboarding flow)
  static Future<void> testSequentialPermissions(BuildContext context) async {
    final results = await helper.requestPermissionsSequentially(
      context,
      sequentialConfig: SequentialRequestConfig(
        permissions: [
          Permission.camera,
          Permission.location,
          Permission.notification,
        ],
        packageOverrides: {
          Permission.location: PermissionPackage.location,
          Permission.notification: PermissionPackage.notifications,
        },
        showPurposeDialogs: true,
        delayBetweenRequests: const Duration(milliseconds: 500),
      ),
    );

    final summary =
        results.map((r) => '${r.permission}: ${r.isGranted}').join(', ');
    _showResultSnackbar(context, 'Sequential: $summary');
  }

  /// Test 5: Check permission status
  static Future<void> testPermissionStatus(BuildContext context) async {
    final isCameraGranted = await helper.isPermissionGranted(Permission.camera);
    final status = await helper.getPermissionStatus(Permission.location);

    _showResultSnackbar(
        context, 'Camera granted: $isCameraGranted, Location status: $status');
  }

  /// Test 6: Edge case - unknown permission
  static Future<void> testUnknownPermission(BuildContext context) async {
    // This tests the fallback mechanism
    final result = await helper.requestPermission(
      context,
      Permission.unknown, // This might not exist, but tests error handling
      requestConfig: const SingleRequestConfig(showPurposeDialog: false),
    );

    _showResultSnackbar(
        context, 'Unknown permission handled: ${result.isGranted}');
  }

  static void _showResultSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
