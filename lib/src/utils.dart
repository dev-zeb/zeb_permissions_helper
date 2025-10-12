import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:zeb_permissions_helper/zeb_permissions_helper.dart';

Future<Permission> resolvePermission(Permission original) async {
  if (original == Permission.photos && Platform.isAndroid) {
    // For Android pre-33, use storage
    final sdk = await _getAndroidSdkSafe();
    if (sdk != null && sdk < 33) return Permission.storage;
    return Permission.photos;
  }
  return original;
}

// helper that doesn't throw if DeviceInfo plugin not available
Future<int?> _getAndroidSdkSafe() async {
  try {
    final deviceInfo = await importDeviceInfo();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.version.sdkInt;
  } catch (e) {
    return null;
  }
}

// helper to lazily import DeviceInfoPlugin to avoid circular imports
Future<dynamic> importDeviceInfo() async {
  // This would be implemented to return the actual DeviceInfoPlugin
  // For now, we'll keep it as a placeholder
  return await Future.value(null);
}

/// Get the appropriate package for a permission
PermissionPackage getPackageForPermission(
  Permission permission, {
  PermissionPackage? preferredPackage,
  required PermissionPackage defaultPackage,
  Map<Permission, PermissionPackage>? packageOverrides,
}) {
  // Check for overrides first
  if (packageOverrides != null && packageOverrides.containsKey(permission)) {
    return packageOverrides[permission]!;
  }

  // Use preferred package if provided
  if (preferredPackage != null) {
    return preferredPackage;
  }

  // Use default package for the permission type
  return defaultPackage;
}
