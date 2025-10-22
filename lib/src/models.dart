import 'package:flutter/cupertino.dart';
import 'package:zeb_permissions_helper/zeb_permissions_helper.dart';

/// Dialog text used in purpose and permanently-denied dialogs.
class DialogText {
  /// Dialog title.
  final String title;

  /// Explanation shown when requesting permission.
  final String explanation;

  /// Caution text shown for permanently denied or required notice.
  final String caution;

  const DialogText({
    required this.title,
    required this.explanation,
    required this.caution,
  });

  /// Create a modified copy of this [DialogText].
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

/// Per-permission metadata and overrides.
class AppPermissionData {
  /// Permission identifier (ZebPermission).
  final ZebPermission permission;

  /// Dialog texts for purpose & caution.
  final DialogText dialogText;

  /// Supported underlying permission packages for this permission.
  final List<PermissionPackage> supportedPackages;

  const AppPermissionData({
    required this.permission,
    required this.dialogText,
    this.supportedPackages = const [PermissionPackage.permissionHandler],
  });

  /// Copy helper.
  AppPermissionData copyWith({
    ZebPermission? permission,
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

/// Global configuration for the permissions helper.
class ZebPermissionsConfig {
  /// Per-permission overrides (merged with defaults).
  final Map<ZebPermission, AppPermissionData>? overrides;

  /// Whether to show the default purpose dialog before requesting permission.
  final bool showDialogsByDefault;

  /// Default package to use when a permission supports multiple packages.
  final PermissionPackage defaultPackage;

  /// Whether the helper should show a dialog when permission is permanently denied.
  ///
  /// The dialog contains a button that opens app settings. Developers can override
  /// the dialog UI via [permanentlyDeniedDialogBuilder].
  final bool showDialogOnPermanentlyDenied;

  /// Optional builder for permanently-denied dialog so devs can provide custom UI.
  ///
  /// If null, a sensible default dialog (title/caution/Open Settings) is used.
  final PermanentlyDeniedDialogBuilder? permanentlyDeniedDialogBuilder;

  const ZebPermissionsConfig({
    this.overrides,
    this.showDialogsByDefault = true,
    this.defaultPackage = PermissionPackage.permissionHandler,
    this.showDialogOnPermanentlyDenied = true,
    this.permanentlyDeniedDialogBuilder,
  });
}

/// Choice of underlying permission package/implementation.
enum PermissionPackage {
  permissionHandler,
  location,
  notifications,
}

/// Result returned by a single permission request attempt.
class PermissionRequestResult {
  /// Whether permission is granted or limited.
  final bool isGranted;

  /// Which ZebPermission this result belongs to.
  final ZebPermission permission;

  /// Which underlying package was used.
  final PermissionPackage usedPackage;

  /// Optional error message if something went wrong.
  final String? error;

  /// Whether the final status is permanently denied (so app can guide user).
  final bool isPermanentlyDenied;

  const PermissionRequestResult({
    required this.isGranted,
    required this.permission,
    required this.usedPackage,
    this.error,
    this.isPermanentlyDenied = false,
  });
}

/// Configuration for sequential permission requests.
class SequentialRequestConfig {
  /// Permissions to request in order.
  final List<ZebPermission> permissions;

  /// Per-permission package overrides (optional).
  final Map<ZebPermission, PermissionPackage>? packageOverrides;

  /// Whether to show purpose dialogs for each permission in the flow.
  final bool showPurposeDialogs;

  /// Delay between successive permission requests to avoid stacked system dialogs.
  final Duration delayBetweenRequests;

  const SequentialRequestConfig({
    required this.permissions,
    this.packageOverrides,
    this.showPurposeDialogs = true,
    this.delayBetweenRequests = const Duration(milliseconds: 300),
  });
}

/// Config for a single permission request.
class SingleRequestConfig {
  /// If specified, use this package instead of default.
  final PermissionPackage? package;

  /// Optional override dialog text for this single request.
  final DialogText? dialogText;

  /// Whether to show the purpose/dialog before requesting.
  final bool showPurposeDialog;

  const SingleRequestConfig({
    this.package,
    this.dialogText,
    this.showPurposeDialog = true,
  });
}

/// Signature for a customizable permanently-denied dialog builder.
///
/// - [context] is the BuildContext to build the dialog in.
/// - [data] contains dialog strings & permission info.
/// - [onOpenSettings] is a callback the dialog should call to open app settings.
typedef PermanentlyDeniedDialogBuilder = Widget Function(
  BuildContext context,
  AppPermissionData data,
  VoidCallback onOpenSettings,
);
