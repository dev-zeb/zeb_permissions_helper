import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'permission_strings.dart';
import 'utils.dart';

class ZebPermissionsHelper {
  final ZebPermissionsConfig config;
  bool _isSequentialFlowRunning = false;

  ZebPermissionsHelper({this.config = const ZebPermissionsConfig()});

  Map<Permission, AppPermissionData> get _permissionData {
    final merged =
        Map<Permission, AppPermissionData>.from(defaultPermissionData);
    if (config.overrides != null) {
      merged.addAll(config.overrides!);
    }
    return merged;
  }

  // ---------- Public API ----------

  /// Request a single permission with customizable options
  Future<PermissionRequestResult> requestPermission(
    BuildContext context,
    Permission permission, {
    SingleRequestConfig? requestConfig,
  }) async {
    final resolved = await resolvePermission(permission);
    final data = _permissionData[resolved] ?? _createFallbackData(resolved);
    final package = getPackageForPermission(
      resolved,
      preferredPackage: requestConfig?.package,
      defaultPackage: config.defaultPackage,
    );

    // Show purpose dialog if requested and config allows
    final shouldShowDialog =
        requestConfig?.showPurposeDialog ?? config.showDialogsByDefault;

    if (shouldShowDialog && context.mounted) {
      final dialogText = requestConfig?.dialogText ?? data.dialogText;
      await _showPurposeDialog(
        context,
        dialogText.title,
        dialogText.explanation,
      );
    }

    // Request permission using the specified package
    final isGranted = await _requestPermissionWithPackage(
      context,
      resolved,
      package,
      data,
    );

    return PermissionRequestResult(
      isGranted: isGranted,
      permission: resolved,
      usedPackage: package,
    );
  }

  /// Request a list of permissions sequentially with full customization
  Future<List<PermissionRequestResult>> requestPermissionsSequentially(
    BuildContext context, {
    required SequentialRequestConfig sequentialConfig,
  }) async {
    if (_isSequentialFlowRunning) {
      return [];
    }

    _isSequentialFlowRunning = true;
    final results = <PermissionRequestResult>[];

    for (final permission in sequentialConfig.permissions) {
      await Future.delayed(sequentialConfig.delayBetweenRequests);

      if (!context.mounted) continue;

      final resolved = await resolvePermission(permission);
      final status = await resolved.status;

      // Skip if already granted
      if (status.isGranted || status.isLimited) {
        results.add(PermissionRequestResult(
          isGranted: true,
          permission: resolved,
          usedPackage: getPackageForPermission(
            resolved,
            packageOverrides: sequentialConfig.packageOverrides,
            defaultPackage: config.defaultPackage,
          ),
        ));
        continue;
      }

      final data = _permissionData[resolved] ?? _createFallbackData(resolved);
      final flowRequired = await _checkIfFlowRequired(resolved, data);

      if (flowRequired && context.mounted) {
        final package = getPackageForPermission(
          resolved,
          packageOverrides: sequentialConfig.packageOverrides,
          defaultPackage: config.defaultPackage,
        );

        final isGranted = await _requestPermissionFlow(
          context,
          data,
          status,
          package,
          showPurposeDialog: sequentialConfig.showPurposeDialogs,
        );

        results.add(PermissionRequestResult(
          isGranted: isGranted,
          permission: resolved,
          usedPackage: package,
        ));
      }
    }

    _isSequentialFlowRunning = false;
    return results;
  }

  /// Simple sequential flow with default configuration (backward compatibility)
  Future<void> requestPermissionsSequentiallyWithUI(
      BuildContext context) async {
    final permissions =
        _permissionData.values.map((e) => e.permission).toList();
    await requestPermissionsSequentially(
      context,
      sequentialConfig: SequentialRequestConfig(
        permissions: permissions,
        showPurposeDialogs: config.showDialogsByDefault,
      ),
    );
  }

  /// Request multiple permissions at once (non-sequential)
  Future<List<PermissionRequestResult>> requestMultiplePermissions(
    BuildContext context,
    List<Permission> permissions, {
    Map<Permission, SingleRequestConfig>? requestConfigs,
  }) async {
    final results = <PermissionRequestResult>[];

    for (final permission in permissions) {
      final config = requestConfigs?[permission];
      final result =
          await requestPermission(context, permission, requestConfig: config);
      results.add(result);
    }

    return results;
  }

  // ---------- Low-level helpers & checks ----------

  Future<bool> isPermissionGranted(Permission permission) async {
    final res = await resolvePermission(permission);
    return res.isGranted;
  }

  Future<PermissionStatus> getPermissionStatus(Permission permission) async {
    final res = await resolvePermission(permission);
    return res.status;
  }

  // ---------- Package-specific permission handlers ----------

  Future<bool> _requestPermissionWithPackage(
    BuildContext context,
    Permission permission,
    PermissionPackage package,
    AppPermissionData data,
  ) async {
    switch (package) {
      case PermissionPackage.location:
        if (_isLocationPermission(permission)) {
          return await _requestLocationWithPackage(permission);
        }
        break;
      case PermissionPackage.notifications:
        if (permission == Permission.notification) {
          return await _requestNotificationWithPackage();
        }
        break;
      case PermissionPackage.permissionHandler:
        // Fall back to permission_handler
        break;
    }

    // Default to permission_handler
    final status = await permission.request();
    return status.isGranted || status.isLimited;
  }

  Future<bool> _requestLocationWithPackage(Permission permission) async {
    final location = loc.Location();
    final status = await location.requestPermission();
    return status == loc.PermissionStatus.granted ||
        status == loc.PermissionStatus.grantedLimited;
  }

  Future<bool> _requestNotificationWithPackage() async {
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

  Future<bool> _checkLocationWithPackage() async {
    final location = loc.Location();
    final res = await location.hasPermission();
    return res == loc.PermissionStatus.granted ||
        res == loc.PermissionStatus.grantedLimited;
  }

  Future<bool> _checkNotificationWithPackage() async {
    if (Platform.isIOS) {
      final res = await FlutterLocalNotificationsPlugin()
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.checkPermissions();
      return res?.isEnabled ?? false;
    } else {
      return await Permission.notification.isGranted;
    }
  }

  // ---------- Helpers & UI ----------

  Future<void> _showPurposeDialog(
      BuildContext context, String title, String explanation) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(explanation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text("Next"),
          ),
        ],
      ),
    );
  }

  Future<bool> _showRequiredPermissionDialog(
    BuildContext context,
    AppPermissionData data,
  ) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: const Text("Attention"),
            content: Text(data.dialogText.caution),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
                child: const Text("OK"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop(true);
                  await openAppSettings();
                },
                child: const Text("Open Settings"),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<int> getAndroidSdkVersion() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.version.sdkInt;
  }

  // ---------- Internal flow pieces ----------

  Future<bool> _checkIfFlowRequired(
      Permission permission, AppPermissionData data) async {
    // Platform specific
    if (Platform.isIOS) {
      if (permission == Permission.systemAlertWindow ||
          permission == Permission.storage) {
        return false;
      }
      if (_isLocationPermission(permission)) {
        return !(await _checkLocationWithPackage());
      }
      if (permission == Permission.notification) {
        return !(await _checkNotificationWithPackage());
      }
    }

    if (Platform.isAndroid && permission == Permission.storage) {
      final sdk = await getAndroidSdkVersion();
      if (sdk >= 29) return false;
    }

    return true;
  }

  Future<bool> _requestPermissionFlow(
    BuildContext context,
    AppPermissionData data,
    PermissionStatus status,
    PermissionPackage package, {
    required bool showPurposeDialog,
  }) async {
    // iOS special-case: location + notification never return permanentlyDenied in some cases
    if (Platform.isIOS &&
        (_isLocationPermission(data.permission) ||
            data.permission == Permission.notification)) {
      final key = "asked_${data.permission.value}";
      final prefs = await SharedPreferences.getInstance();
      final wasAskedBefore = prefs.getBool(key) ?? false;

      if (status.isDenied) {
        if (wasAskedBefore) {
          final open = await _showRequiredPermissionDialog(context, data);
          final newStatus =
              await _getPermissionStatusWithPackage(data.permission, package);
          return open &&
              (newStatus == PermissionStatus.granted ||
                  newStatus == PermissionStatus.limited);
        } else {
          // Show purpose
          if (showPurposeDialog && context.mounted) {
            await _showPurposeDialog(
                context, data.dialogText.title, data.dialogText.explanation);
          }

          bool isGranted = false;
          if (data.permission == Permission.notification) {
            isGranted = await _requestNotificationWithPackage();
          } else if (_isLocationPermission(data.permission)) {
            isGranted = await _requestLocationWithPackage(data.permission);
          } else {
            isGranted = await data.permission.request().isGranted;
          }

          await prefs.setBool(key, true);
          return isGranted;
        }
      }
    }

    // Normal path for Android + other iOS perms
    if (status.isPermanentlyDenied && context.mounted) {
      final open = await _showRequiredPermissionDialog(context, data);
      final newStatus =
          await _getPermissionStatusWithPackage(data.permission, package);
      return open &&
          (newStatus == PermissionStatus.granted ||
              newStatus == PermissionStatus.limited);
    }

    // Show purpose then request
    if (showPurposeDialog && context.mounted) {
      await _showPurposeDialog(
          context, data.dialogText.title, data.dialogText.explanation);
    }

    return await _requestPermissionWithPackage(
      context,
      data.permission,
      package,
      data,
    );
  }

  Future<PermissionStatus> _getPermissionStatusWithPackage(
    Permission permission,
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
        if (permission == Permission.notification) {
          final isGranted = await _checkNotificationWithPackage();
          return isGranted ? PermissionStatus.granted : PermissionStatus.denied;
        }
        break;
      default:
        break;
    }

    return permission.status;
  }

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

  bool _isLocationPermission(Permission permission) {
    return permission == Permission.location ||
        permission == Permission.locationWhenInUse ||
        permission == Permission.locationAlways;
  }

  AppPermissionData _createFallbackData(Permission permission) {
    return AppPermissionData(
      permission: permission,
      dialogText: const DialogText(
        title: "Permission Required",
        explanation: "This app needs this permission to function properly.",
        caution: "Please enable this permission in Settings.",
      ),
    );
  }
}
