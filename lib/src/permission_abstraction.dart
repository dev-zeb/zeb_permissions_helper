import 'package:permission_handler/permission_handler.dart';

/// App-level permission enum to avoid leaking permission_handler types.
enum ZebPermission {
  notification,
  camera,
  photos,
  microphone,
  location,
  locationWhenInUse,
  locationAlways,
  storage,
  systemAlertWindow,
  unknown,
}

/// Convert ZebPermission to permission_handler.Permission.
///
/// Centralizes mapping logic so the rest of the codebase doesn't import
/// permission_handler directly.
extension ZebPermissionExtension on ZebPermission {
  /// Convert to a [Permission] value from `permission_handler`.
  Permission get toPermissionHandler {
    switch (this) {
      case ZebPermission.notification:
        return Permission.notification;
      case ZebPermission.camera:
        return Permission.camera;
      case ZebPermission.photos:
        return Permission.photos;
      case ZebPermission.microphone:
        return Permission.microphone;
      case ZebPermission.location:
        return Permission.location;
      case ZebPermission.locationWhenInUse:
        return Permission.locationWhenInUse;
      case ZebPermission.locationAlways:
        return Permission.locationAlways;
      case ZebPermission.storage:
        return Permission.storage;
      case ZebPermission.systemAlertWindow:
        return Permission.systemAlertWindow;
      case ZebPermission.unknown:
        return Permission.unknown;
    }
  }
}
