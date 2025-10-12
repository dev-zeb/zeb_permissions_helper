import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'models.dart';

final Map<Permission, AppPermissionData> defaultPermissionData = {
  Permission.notification: AppPermissionData(
    permission: Permission.notification,
    dialogText: DialogText(
      title: "Notification Access",
      explanation:
          "We use notifications to keep you updated about calls, messages, orders, and delivery progress.",
      caution:
          "Notifications are disabled. Please enable them in Settings to receive updates about calls, messages, and deliveries.",
    ),
    supportedPackages: [
      PermissionPackage.permissionHandler,
      PermissionPackage.notifications,
    ],
  ),
  Permission.camera: AppPermissionData(
    permission: Permission.camera,
    dialogText: DialogText(
      title: "Camera Access",
      explanation:
          "We use your camera so you can capture photos for orders and during video calls.",
      caution:
          "Camera access is disabled. Please enable it in Settings to take photos or use video calls.",
    ),
  ),
  Permission.photos: AppPermissionData(
    permission: Permission.photos,
    dialogText: DialogText(
      title: "Photos Access",
      explanation: Platform.isIOS
          ? "We use your photo library so you can choose and upload images for orders."
          : "We use your gallery so you can select and upload images for deliveries.",
      caution: Platform.isIOS
          ? "Photo library access is disabled. Please enable it in Settings to select or upload photos."
          : "Gallery access is disabled. Please enable it in Settings to upload images.",
    ),
  ),
  Permission.microphone: AppPermissionData(
    permission: Permission.microphone,
    dialogText: DialogText(
      title: "Microphone Access",
      explanation:
          "We use your microphone so you can talk during voice and video calls.",
      caution:
          "Microphone access is disabled. Please enable it in Settings to use calls.",
    ),
  ),
  Permission.location: AppPermissionData(
    permission: Permission.location,
    dialogText: DialogText(
      title: "Location Access (While in Use)",
      explanation:
          "We use your location to show maps, allow accurate address selections, and track your orders in real time while using the app.",
      caution:
          "Location access is disabled. Please enable it in Settings to use maps, address selection, and delivery tracking.",
    ),
    supportedPackages: [
      PermissionPackage.permissionHandler,
      PermissionPackage.location,
    ],
  ),
  Permission.locationWhenInUse: AppPermissionData(
    permission: Permission.locationWhenInUse,
    dialogText: DialogText(
      title: "Location Access (While in Use)",
      explanation:
          "We use your location to show maps, allow accurate address selections, and track your orders in real time while using the app.",
      caution:
          "Location access is disabled. Please enable it in Settings to use maps, address selection, and delivery tracking.",
    ),
    supportedPackages: [
      PermissionPackage.permissionHandler,
      PermissionPackage.location,
    ],
  ),
  Permission.locationAlways: AppPermissionData(
    permission: Permission.locationAlways,
    dialogText: DialogText(
      title: "Location Access (Always)",
      explanation:
          "We use your location to track deliveries and provide real-time updates even when the app is in the background.",
      caution:
          "Location access is disabled. Please enable it in Settings to use background location tracking.",
    ),
    supportedPackages: [
      PermissionPackage.permissionHandler,
      PermissionPackage.location,
    ],
  ),
  Permission.storage: AppPermissionData(
    permission: Permission.storage,
    dialogText: DialogText(
      title: "Storage Access",
      explanation:
          "We use storage to save and access files like PDFs and images on your device.",
      caution:
          "Storage access is disabled. Please enable it in Settings to save or open files.",
    ),
  ),
};
