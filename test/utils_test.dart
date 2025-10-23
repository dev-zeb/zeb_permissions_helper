import 'package:flutter_test/flutter_test.dart';
import 'package:zeb_permissions_helper/zeb_permissions_helper.dart';

void main() {
  group('ZebPermission Resolution', () {
    test('resolvePermission returns same permission for non-photos permission',
        () async {
      final permission = await resolveZebPermission(ZebPermission.camera);
      expect(permission, ZebPermission.camera);
    });

    test('resolvePermission returns same permission for microphone', () async {
      final permission = await resolveZebPermission(ZebPermission.microphone);
      expect(permission, ZebPermission.microphone);
    });

    test('resolvePermission returns same permission for location', () async {
      final permission = await resolveZebPermission(ZebPermission.location);
      expect(permission, ZebPermission.location);
    });

    test('resolvePermission returns same permission for notification',
        () async {
      final permission = await resolveZebPermission(ZebPermission.notification);
      expect(permission, ZebPermission.notification);
    });
  });

  group('Package Selection', () {
    test('getPackageForPermission returns preferred package when provided', () {
      final package = getPackageForPermission(
        ZebPermission.location,
        preferredPackage: PermissionPackage.location,
        defaultPackage: PermissionPackage.permissionHandler,
      );
      expect(package, PermissionPackage.location);
    });

    test('getPackageForPermission returns override package when provided', () {
      final package = getPackageForPermission(
        ZebPermission.location,
        packageOverrides: {
          ZebPermission.location: PermissionPackage.location,
        },
        defaultPackage: PermissionPackage.permissionHandler,
      );
      expect(package, PermissionPackage.location);
    });

    test('getPackageForPermission returns default package when no preferences',
        () {
      final package = getPackageForPermission(
        ZebPermission.camera,
        defaultPackage: PermissionPackage.permissionHandler,
      );
      expect(package, PermissionPackage.permissionHandler);
    });

    test('getPackageForPermission prioritizes override over preferred package',
        () {
      final package = getPackageForPermission(
        ZebPermission.location,
        preferredPackage: PermissionPackage.notifications, // Wrong package
        packageOverrides: {
          ZebPermission.location: PermissionPackage.location,
        },
        defaultPackage: PermissionPackage.permissionHandler,
      );
      expect(package, PermissionPackage.location);
    });

    test('getPackageForPermission handles null overrides gracefully', () {
      final package = getPackageForPermission(
        ZebPermission.location,
        preferredPackage: PermissionPackage.location,
        packageOverrides: null,
        defaultPackage: PermissionPackage.permissionHandler,
      );
      expect(package, PermissionPackage.location);
    });

    test('getPackageForPermission handles empty overrides gracefully', () {
      final package = getPackageForPermission(
        ZebPermission.location,
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
        ZebPermission.location,
        defaultPackage: PermissionPackage.permissionHandler,
      );

      final notificationPackage = getPackageForPermission(
        ZebPermission.notification,
        defaultPackage: PermissionPackage.permissionHandler,
      );

      final cameraPackage = getPackageForPermission(
        ZebPermission.camera,
        defaultPackage: PermissionPackage.permissionHandler,
      );

      expect(locationPackage, PermissionPackage.permissionHandler);
      expect(notificationPackage, PermissionPackage.permissionHandler);
      expect(cameraPackage, PermissionPackage.permissionHandler);
    });

    test('getPackageForPermission with different default packages', () {
      final package1 = getPackageForPermission(
        ZebPermission.location,
        defaultPackage: PermissionPackage.location,
      );

      final package2 = getPackageForPermission(
        ZebPermission.location,
        defaultPackage: PermissionPackage.notifications,
      );

      expect(package1, PermissionPackage.location);
      expect(package2, PermissionPackage.notifications);
    });
  });
}
