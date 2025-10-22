import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';

import 'models.dart';
import 'permission_strings.dart';
import 'permission_abstraction.dart';
import 'utils.dart';

/// A helper class to simplify permission requests with optional
/// purpose dialogs and permanent-denial handling.
class ZebPermissionsHelper {
  final ZebPermissionsConfig config;

  ZebPermissionsHelper({this.config = const ZebPermissionsConfig()});

  Map<ZebPermission, AppPermissionData> get _permissionData {
    final merged =
        Map<ZebPermission, AppPermissionData>.from(defaultPermissionData);
    if (config.overrides != null) merged.addAll(config.overrides!);
    return merged;
  }

  /// Request a single permission.
  Future<PermissionRequestResult> requestPermission(
    BuildContext context,
    ZebPermission permission, {
    SingleRequestConfig? requestConfig,
  }) async {
    final data = _permissionData[permission] ?? _createFallbackData(permission);

    final package = getPackageForPermission(
      permission,
      preferredPackage: requestConfig?.package,
      defaultPackage: config.defaultPackage,
    );

    // Check status first
    final permissionStatus = await _getPermissionStatus(permission, package);
    if (permissionStatus.isGranted || permissionStatus.isLimited) {
      return PermissionRequestResult(
        isGranted: true,
        permission: permission,
        usedPackage: package,
      );
    }

    // Handle permanent denial
    if (permissionStatus.isPermanentlyDenied) {
      if (context.mounted) {
        await _showPermanentlyDeniedDialog(context, data);
      }
      return PermissionRequestResult(
        isGranted: false,
        permission: permission,
        usedPackage: package,
      );
    }

    // Show purpose dialog (if allowed)
    final shouldShowDialog =
        requestConfig?.showPurposeDialog ?? config.showDialogsByDefault;
    if (shouldShowDialog && context.mounted) {
      final dialogText = requestConfig?.dialogText ?? data.dialogText;
      await _showPurposeDialog(
          context, dialogText.title, dialogText.explanation);
    }

    bool isGranted = false;
    if (context.mounted) {
      // Request the permission
      isGranted = await _requestPermissionWithPackage(
        context,
        permission,
        package,
      );
    }

    return PermissionRequestResult(
      isGranted: isGranted,
      permission: permission,
      usedPackage: package,
    );
  }

  /// Request multiple permissions sequentially.
  Future<List<PermissionRequestResult>> requestPermissionsSequentially(
    BuildContext context, {
    required SequentialRequestConfig sequentialConfig,
  }) async {
    final results = <PermissionRequestResult>[];

    for (final zebPermission in sequentialConfig.permissions) {
      await Future.delayed(sequentialConfig.delayBetweenRequests);
      if (!context.mounted) continue;

      final result = await requestPermission(
        context,
        zebPermission,
        requestConfig: SingleRequestConfig(
          showPurposeDialog: sequentialConfig.showPurposeDialogs,
          package: sequentialConfig.packageOverrides?[zebPermission],
        ),
      );
      results.add(result);
    }

    return results;
  }

  /// Check whether a permission is currently granted.
  Future<bool> isPermissionGranted(ZebPermission permission) async {
    final res = await resolveZebPermission(permission);
    return res.toPermissionHandler.isGranted;
  }

  // ----------------------------------------------------------------------

  Future<bool> _requestPermissionWithPackage(
    BuildContext context,
    ZebPermission permission,
    PermissionPackage package,
  ) async {
    switch (package) {
      case PermissionPackage.location:
        if (_isLocationPermission(permission)) {
          return await _requestLocationPermission();
        }
        break;
      case PermissionPackage.notifications:
        if (permission == ZebPermission.notification) {
          return await _requestNotificationPermission();
        }
        break;
      default:
        break;
    }

    // Default to permission_handler
    final perm = permission.toPermissionHandler;
    final status = await perm.request();
    return status.isGranted || status.isLimited;
  }

  Future<PermissionStatus> _getPermissionStatus(
    ZebPermission permission,
    PermissionPackage package,
  ) async {
    switch (package) {
      case PermissionPackage.location:
        if (_isLocationPermission(permission)) {
          final location = loc.Location();
          final status = await location.hasPermission();
          return _convertLocationStatus(status);
        }
        break;
      case PermissionPackage.notifications:
        if (permission == ZebPermission.notification) {
          final plugin = FlutterLocalNotificationsPlugin();
          if (Platform.isIOS) {
            final res = await plugin
                .resolvePlatformSpecificImplementation<
                    IOSFlutterLocalNotificationsPlugin>()
                ?.checkPermissions();
            return (res?.isEnabled ?? false)
                ? PermissionStatus.granted
                : PermissionStatus.denied;
          }
          return await Permission.notification.status;
        }
        break;
      default:
        break;
    }
    return (await permission.toPermissionHandler.status);
  }

  Future<bool> _requestLocationPermission() async {
    final location = loc.Location();
    final status = await location.requestPermission();
    return status == loc.PermissionStatus.granted ||
        status == loc.PermissionStatus.grantedLimited;
  }

  Future<bool> _requestNotificationPermission() async {
    if (Platform.isIOS) {
      final result = await FlutterLocalNotificationsPlugin()
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    } else {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
  }

  // ----------------------------------------------------------------------

  Future<void> _showPurposeDialog(
      BuildContext context, String title, String explanation) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(explanation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Next"),
          ),
        ],
      ),
    );
  }

  /// Default dialog for permanently denied permissions.
  /// Developers can override this by providing custom UI in future versions.
  Future<void> _showPermanentlyDeniedDialog(
    BuildContext context,
    AppPermissionData data,
  ) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Permission Required"),
        content: Text(data.dialogText.caution),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await openAppSettings();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------------

  PermissionStatus _convertLocationStatus(loc.PermissionStatus status) {
    switch (status) {
      case loc.PermissionStatus.granted:
      case loc.PermissionStatus.grantedLimited:
        return PermissionStatus.granted;
      case loc.PermissionStatus.denied:
        return PermissionStatus.denied;
      case loc.PermissionStatus.deniedForever:
        return PermissionStatus.permanentlyDenied;
    }
  }

  bool _isLocationPermission(ZebPermission permission) {
    return permission == ZebPermission.location ||
        permission == ZebPermission.locationAlways ||
        permission == ZebPermission.locationWhenInUse;
  }

  AppPermissionData _createFallbackData(ZebPermission permission) {
    return AppPermissionData(
      permission: permission,
      dialogText: const DialogText(
        title: "Permission Required",
        explanation: "This app requires permission to function properly.",
        caution: "Please enable this permission in Settings.",
      ),
    );
  }
}
