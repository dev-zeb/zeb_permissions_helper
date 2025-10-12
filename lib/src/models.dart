import 'package:permission_handler/permission_handler.dart';

class DialogText {
  final String title;
  final String explanation;
  final String caution;

  const DialogText({
    required this.title,
    required this.explanation,
    required this.caution,
  });

  DialogText copyWith({
    String? title,
    String? explanation,
    String? caution,
  }) {
    return DialogText(
      title: title ?? this.title,
      explanation: explanation ?? this.explanation,
      caution: caution ?? this.caution,
    );
  }
}

/// Per-permission data holder
class AppPermissionData {
  final Permission permission;
  final DialogText dialogText;
  final List<PermissionPackage> supportedPackages;

  const AppPermissionData({
    required this.permission,
    required this.dialogText,
    this.supportedPackages = const [PermissionPackage.permissionHandler],
  });

  AppPermissionData copyWith({
    Permission? permission,
    DialogText? dialogText,
    List<PermissionPackage>? supportedPackages,
  }) {
    return AppPermissionData(
      permission: permission ?? this.permission,
      dialogText: dialogText ?? this.dialogText,
      supportedPackages: supportedPackages ?? this.supportedPackages,
    );
  }
}

/// Global configuration for the helper
class ZebPermissionsConfig {
  /// Custom per-permission overrides. If not provided, defaults are used.
  final Map<Permission, AppPermissionData>? overrides;

  /// Whether to show dialogs by default (developer can choose not to)
  final bool showDialogsByDefault;

  /// Default package to use for permissions that support multiple packages
  final PermissionPackage defaultPackage;

  const ZebPermissionsConfig({
    this.overrides,
    this.showDialogsByDefault = true,
    this.defaultPackage = PermissionPackage.permissionHandler,
  });
}

/// Supported permission packages
enum PermissionPackage {
  permissionHandler,
  location,
  notifications,
}

/// Result of a permission request
class PermissionRequestResult {
  final bool isGranted;
  final Permission permission;
  final PermissionPackage usedPackage;
  final String? error;

  const PermissionRequestResult({
    required this.isGranted,
    required this.permission,
    required this.usedPackage,
    this.error,
  });
}

/// Configuration for sequential permission requests
class SequentialRequestConfig {
  final List<Permission> permissions;
  final Map<Permission, PermissionPackage>? packageOverrides;
  final bool showPurposeDialogs;
  final Duration delayBetweenRequests;

  const SequentialRequestConfig({
    required this.permissions,
    this.packageOverrides,
    this.showPurposeDialogs = true,
    this.delayBetweenRequests = const Duration(milliseconds: 300),
  });
}

/// Configuration for individual permission request
class SingleRequestConfig {
  final PermissionPackage? package;
  final DialogText? dialogText;
  final bool showPurposeDialog;

  const SingleRequestConfig({
    this.package,
    this.dialogText,
    this.showPurposeDialog = true,
  });
}
