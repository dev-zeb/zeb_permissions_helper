import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zeb_permissions_helper/src/utils.dart';
import 'package:zeb_permissions_helper/zeb_permissions_helper.dart';

void main() {
  group('Permission Resolution', () {
    test('resolvePermission returns same permission for non-photos permission',
        () async {
      final permission = await resolvePermission(Permission.camera);
      expect(permission, Permission.camera);
    });

    test('resolvePermission returns same permission for microphone', () async {
      final permission = await resolvePermission(Permission.microphone);
      expect(permission, Permission.microphone);
    });

    test('resolvePermission returns same permission for location', () async {
      final permission = await resolvePermission(Permission.location);
      expect(permission, Permission.location);
    });

    test('resolvePermission returns same permission for notification',
        () async {
      final permission = await resolvePermission(Permission.notification);
      expect(permission, Permission.notification);
    });
  });

  group('Package Selection', () {
    test('getPackageForPermission returns preferred package when provided', () {
      final package = getPackageForPermission(
        Permission.location,
        preferredPackage: PermissionPackage.location,
        defaultPackage: PermissionPackage.permissionHandler,
      );
      expect(package, PermissionPackage.location);
    });

    test('getPackageForPermission returns override package when provided', () {
      final package = getPackageForPermission(
        Permission.location,
        packageOverrides: {
          Permission.location: PermissionPackage.location,
        },
        defaultPackage: PermissionPackage.permissionHandler,
      );
      expect(package, PermissionPackage.location);
    });

    test('getPackageForPermission returns default package when no preferences',
        () {
      final package = getPackageForPermission(
        Permission.camera,
        defaultPackage: PermissionPackage.permissionHandler,
      );
      expect(package, PermissionPackage.permissionHandler);
    });

    test('getPackageForPermission prioritizes override over preferred package',
        () {
      final package = getPackageForPermission(
        Permission.location,
        preferredPackage: PermissionPackage.notifications, // Wrong package
        packageOverrides: {
          Permission.location: PermissionPackage.location,
        },
        defaultPackage: PermissionPackage.permissionHandler,
      );
      expect(package, PermissionPackage.location);
    });

    test('getPackageForPermission handles null overrides gracefully', () {
      final package = getPackageForPermission(
        Permission.location,
        preferredPackage: PermissionPackage.location,
        packageOverrides: null,
        defaultPackage: PermissionPackage.permissionHandler,
      );
      expect(package, PermissionPackage.location);
    });

    test('getPackageForPermission handles empty overrides gracefully', () {
      final package = getPackageForPermission(
        Permission.location,
        preferredPackage: null,
        packageOverrides: {},
        defaultPackage: PermissionPackage.permissionHandler,
      );
      expect(package, PermissionPackage.permissionHandler);
    });
  });

  group('Edge Cases', () {
    test('getPackageForPermission with multiple permission types', () {
      final locationPackage = getPackageForPermission(
        Permission.location,
        defaultPackage: PermissionPackage.permissionHandler,
      );

      final notificationPackage = getPackageForPermission(
        Permission.notification,
        defaultPackage: PermissionPackage.permissionHandler,
      );

      final cameraPackage = getPackageForPermission(
        Permission.camera,
        defaultPackage: PermissionPackage.permissionHandler,
      );

      expect(locationPackage, PermissionPackage.permissionHandler);
      expect(notificationPackage, PermissionPackage.permissionHandler);
      expect(cameraPackage, PermissionPackage.permissionHandler);
    });

    test('getPackageForPermission with different default packages', () {
      final package1 = getPackageForPermission(
        Permission.location,
        defaultPackage: PermissionPackage.location,
      );

      final package2 = getPackageForPermission(
        Permission.location,
        defaultPackage: PermissionPackage.notifications,
      );

      expect(package1, PermissionPackage.location);
      expect(package2, PermissionPackage.notifications);
    });
  });
}
