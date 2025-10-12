import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zeb_permissions_helper/zeb_permissions_helper.dart';

void main() {
  group('ZebPermissionsHelper', () {
    test('default configuration is created correctly', () {
      final helper = ZebPermissionsHelper();
      expect(helper.config.showDialogsByDefault, true);
      expect(helper.config.defaultPackage, PermissionPackage.permissionHandler);
    });

    test('custom configuration is applied correctly', () {
      final customConfig = ZebPermissionsConfig(
        showDialogsByDefault: false,
        defaultPackage: PermissionPackage.location,
      );
      final helper = ZebPermissionsHelper(config: customConfig);
      expect(helper.config.showDialogsByDefault, false);
      expect(helper.config.defaultPackage, PermissionPackage.location);
    });
  });

  group('Models', () {
    test('DialogText copyWith works correctly', () {
      const original = DialogText(
        title: 'Original Title',
        explanation: 'Original Explanation',
        caution: 'Original Caution',
      );

      final copied = original.copyWith(title: 'New Title');

      expect(copied.title, 'New Title');
      expect(copied.explanation, 'Original Explanation');
      expect(copied.caution, 'Original Caution');
    });

    test('AppPermissionData copyWith works correctly', () {
      const original = AppPermissionData(
        permission: Permission.camera,
        dialogText: DialogText(
          title: 'Title',
          explanation: 'Explanation',
          caution: 'Caution',
        ),
      );

      final copied = original.copyWith(
        supportedPackages: [PermissionPackage.permissionHandler],
      );

      expect(copied.permission, Permission.camera);
      expect(copied.supportedPackages, [PermissionPackage.permissionHandler]);
    });

    test('PermissionRequestResult creation', () {
      const result = PermissionRequestResult(
        isGranted: true,
        permission: Permission.camera,
        usedPackage: PermissionPackage.permissionHandler,
      );

      expect(result.isGranted, true);
      expect(result.permission, Permission.camera);
      expect(result.usedPackage, PermissionPackage.permissionHandler);
    });

    test('SequentialRequestConfig creation', () {
      const config = SequentialRequestConfig(
        permissions: [Permission.camera, Permission.microphone],
        showPurposeDialogs: true,
        delayBetweenRequests: Duration(milliseconds: 500),
      );

      expect(config.permissions, [Permission.camera, Permission.microphone]);
      expect(config.showPurposeDialogs, true);
      expect(config.delayBetweenRequests, Duration(milliseconds: 500));
    });

    test('SingleRequestConfig creation', () {
      const dialogText = DialogText(
        title: 'Test',
        explanation: 'Test',
        caution: 'Test',
      );
      const config = SingleRequestConfig(
        package: PermissionPackage.location,
        dialogText: dialogText,
        showPurposeDialog: true,
      );

      expect(config.package, PermissionPackage.location);
      expect(config.dialogText, dialogText);
      expect(config.showPurposeDialog, true);
    });
  });

  group('Utils', () {
    test('getPackageForPermission with preferred package', () {
      final package = getPackageForPermission(
        Permission.location,
        preferredPackage: PermissionPackage.location,
        defaultPackage: PermissionPackage.permissionHandler,
      );

      expect(package, PermissionPackage.location);
    });

    test('getPackageForPermission with package overrides', () {
      final package = getPackageForPermission(
        Permission.location,
        packageOverrides: {
          Permission.location: PermissionPackage.location,
        },
        defaultPackage: PermissionPackage.permissionHandler,
      );

      expect(package, PermissionPackage.location);
    });

    test('getPackageForPermission with default package', () {
      final package = getPackageForPermission(
        Permission.camera,
        defaultPackage: PermissionPackage.permissionHandler,
      );

      expect(package, PermissionPackage.permissionHandler);
    });
  });

  // Add more test groups as needed
}
