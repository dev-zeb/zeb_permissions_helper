import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:zeb_permissions_helper/zeb_permissions_helper.dart';

/// Resolve permission types for platform-specific differences.
///
/// Example: Android pre-API 33 doesn't expose a separate photos permission; map
/// photos -> storage for those older SDKs.
Future<ZebPermission> resolveZebPermission(ZebPermission original) async {
  try {
    if (original == ZebPermission.photos && Platform.isAndroid) {
      final sdk = await _getAndroidSdkSafe();
      if (sdk != null && sdk < 33) {
        return ZebPermission.storage;
      }
      return ZebPermission.photos;
    }
  } catch (_) {
    // Fall through to return original if device info fails.
  }
  return original;
}

/// Safely retrieve Android SDK version. Returns null when unavailable.
Future<int?> _getAndroidSdkSafe() async {
  try {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.version.sdkInt;
  } catch (_) {
    return null;
  }
}

/// Decide which package to use for a permission:
/// 1. packageOverrides (per-sequence/per-request)
/// 2. preferred package for this request
/// 3. defaultPackage from the helper config
PermissionPackage getPackageForPermission(
  ZebPermission permission, {
  PermissionPackage? preferredPackage,
  required PermissionPackage defaultPackage,
  Map<ZebPermission, PermissionPackage>? packageOverrides,
}) {
  if (packageOverrides != null && packageOverrides.containsKey(permission)) {
    return packageOverrides[permission]!;
  }

  if (preferredPackage != null) return preferredPackage;

  return defaultPackage;
}
