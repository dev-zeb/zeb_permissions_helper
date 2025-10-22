import 'dart:io';
import 'package:zeb_permissions_helper/zeb_permissions_helper.dart';

/// Default permission messages. Developers can override these through config.
final Map<ZebPermission, AppPermissionData> defaultPermissionData = {
  ZebPermission.notification: const AppPermissionData(
    permission: ZebPermission.notification,
    dialogText: DialogText(
      title: "Notification Access",
      explanation:
      "We use notifications to keep you updated about calls, messages, orders, and delivery progress.",
      caution:
      "Notifications are disabled. To receive updates about calls, messages and deliveries, enable Notifications in Settings.",
    ),
    supportedPackages: [
      PermissionPackage.permissionHandler,
      PermissionPackage.notifications,
    ],
  ),
  ZebPermission.camera: const AppPermissionData(
    permission: ZebPermission.camera,
    dialogText: DialogText(
      title: "Camera Access",
      explanation:
      "We use your camera so you can capture photos for orders and during video calls.",
      caution:
      "Camera access is disabled. To take photos or use video calls, enable Camera in Settings.",
    ),
  ),
  ZebPermission.photos: AppPermissionData(
    permission: ZebPermission.photos,
    dialogText: DialogText(
      title: "Photos Access",
      explanation: Platform.isIOS
          ? "We need access to your photo library so you can choose and upload images."
          : "We need access to your gallery so you can choose and upload images.",
      caution: Platform.isIOS
          ? "Photo library access is disabled. Enable Photo Library in Settings to select or upload photos."
          : "Gallery access is disabled. Enable Storage in Settings to upload images.",
    ),
  ),
  ZebPermission.microphone: const AppPermissionData(
    permission: ZebPermission.microphone,
    dialogText: DialogText(
      title: "Microphone Access",
      explanation:
      "We use your microphone so you can talk during voice and video calls.",
      caution:
      "Microphone access is disabled. Enable Microphone in Settings to use calls.",
    ),
  ),
  ZebPermission.location: const AppPermissionData(
    permission: ZebPermission.location,
    dialogText: DialogText(
      title: "Location Access (While in Use)",
      explanation:
      "We use your location to show maps, allow accurate address selections, and track your orders in real time while using the app.",
      caution:
      "Location access is disabled. Enable Location (While Using the App) in Settings to use maps and delivery tracking.",
    ),
    supportedPackages: [
      PermissionPackage.permissionHandler,
      PermissionPackage.location,
    ],
  ),
  ZebPermission.locationWhenInUse: const AppPermissionData(
    permission: ZebPermission.locationWhenInUse,
    dialogText: DialogText(
      title: "Location Access (While in Use)",
      explanation:
      "We use your location to show maps, allow accurate address selections, and track your orders while using the app.",
      caution:
      "Location (While in Use) access is disabled. Enable it in Settings to use maps and delivery tracking.",
    ),
    supportedPackages: [
      PermissionPackage.permissionHandler,
      PermissionPackage.location,
    ],
  ),
  ZebPermission.locationAlways: const AppPermissionData(
    permission: ZebPermission.locationAlways,
    dialogText: DialogText(
      title: "Location Access (Always)",
      explanation:
      "We use your location to provide background tracking and persistent delivery updates when the app is not in the foreground.",
      caution:
      "Background Location access is disabled. Enable Background Location in Settings to allow persistent tracking.",
    ),
    supportedPackages: [
      PermissionPackage.permissionHandler,
      PermissionPackage.location,
    ],
  ),
  ZebPermission.storage: const AppPermissionData(
    permission: ZebPermission.storage,
    dialogText: DialogText(
      title: "Storage Access",
      explanation:
      "We use storage to save and access files like PDFs and images on your device.",
      caution:
      "Storage access is disabled. Enable Storage in Settings to save or open files.",
    ),
  ),
};
