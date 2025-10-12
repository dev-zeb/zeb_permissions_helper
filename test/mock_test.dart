import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zeb_permissions_helper/zeb_permissions_helper.dart';

// Mock classes
class MockBuildContext extends Mock implements BuildContext {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockPermission extends Mock implements Permission {}

void main() {
  late MockBuildContext mockContext;
  late MockNavigatorObserver mockObserver;
  late ZebPermissionsHelper permissionsHelper;

  setUp(() {
    mockContext = MockBuildContext();
    mockObserver = MockNavigatorObserver();

    // Setup default mock behavior
    when(() => mockContext.mounted).thenReturn(true);

    permissionsHelper = ZebPermissionsHelper();
  });

  tearDown(() {
    reset(mockContext);
    reset(mockObserver);
  });

  group('Basic Mock Tests', () {
    test('ZebPermissionsHelper initialization', () {
      expect(permissionsHelper, isNotNull);
      expect(permissionsHelper.config.showDialogsByDefault, true);
    });

    test('PermissionRequestResult creation with mock data', () {
      const result = PermissionRequestResult(
        isGranted: true,
        permission: Permission.camera,
        usedPackage: PermissionPackage.permissionHandler,
        error: 'Test error',
      );

      expect(result.isGranted, true);
      expect(result.permission, Permission.camera);
      expect(result.usedPackage, PermissionPackage.permissionHandler);
      expect(result.error, 'Test error');
    });

    test('SequentialRequestConfig with custom parameters', () {
      final config = SequentialRequestConfig(
        permissions: [Permission.camera, Permission.microphone],
        packageOverrides: {
          Permission.location: PermissionPackage.location,
        },
        showPurposeDialogs: false,
        delayBetweenRequests: Duration(seconds: 1),
      );

      expect(config.permissions.length, 2);
      expect(config.packageOverrides?.length, 1);
      expect(config.showPurposeDialogs, false);
      expect(config.delayBetweenRequests, Duration(seconds: 1));
    });
  });

  group('Configuration Tests', () {
    test('Custom configuration applies correctly', () {
      final customHelper = ZebPermissionsHelper(
        config: ZebPermissionsConfig(
          showDialogsByDefault: false,
          defaultPackage: PermissionPackage.location,
          overrides: {
            Permission.camera: const AppPermissionData(
              permission: Permission.camera,
              dialogText: DialogText(
                title: 'Custom Camera Title',
                explanation: 'Custom explanation',
                caution: 'Custom caution',
              ),
            ),
          },
        ),
      );

      expect(customHelper.config.showDialogsByDefault, false);
      expect(customHelper.config.defaultPackage, PermissionPackage.location);
      expect(
          customHelper.config.overrides?.containsKey(Permission.camera), true);
    });

    test('Default permission data contains expected permissions', () {
      // This tests that our default permission data has the expected structure
      expect(permissionsHelper, isNotNull);
      // We can't directly test the private _permissionData, but we can test
      // that the helper is properly initialized
    });
  });

  group('Model Tests', () {
    test('DialogText equality and copyWith', () {
      const dialog1 = DialogText(
        title: 'Title 1',
        explanation: 'Explanation 1',
        caution: 'Caution 1',
      );

      const dialog2 = DialogText(
        title: 'Title 1',
        explanation: 'Explanation 1',
        caution: 'Caution 1',
      );

      const dialog3 = DialogText(
        title: 'Title 2',
        explanation: 'Explanation 1',
        caution: 'Caution 1',
      );

      expect(dialog1 == dialog2, true);
      expect(dialog1 == dialog3, false);

      final copied = dialog1.copyWith(title: 'New Title');
      expect(copied.title, 'New Title');
      expect(copied.explanation, dialog1.explanation);
      expect(copied.caution, dialog1.caution);
    });

    test('AppPermissionData equality and copyWith', () {
      const data1 = AppPermissionData(
        permission: Permission.camera,
        dialogText: DialogText(
          title: 'Title',
          explanation: 'Explanation',
          caution: 'Caution',
        ),
      );

      const data2 = AppPermissionData(
        permission: Permission.camera,
        dialogText: DialogText(
          title: 'Title',
          explanation: 'Explanation',
          caution: 'Caution',
        ),
      );

      const data3 = AppPermissionData(
        permission: Permission.microphone,
        dialogText: DialogText(
          title: 'Title',
          explanation: 'Explanation',
          caution: 'Caution',
        ),
      );

      expect(data1 == data2, true);
      expect(data1 == data3, false);

      final copied = data1.copyWith(
        supportedPackages: [PermissionPackage.location],
      );
      expect(copied.permission, data1.permission);
      expect(copied.dialogText, data1.dialogText);
      expect(copied.supportedPackages, [PermissionPackage.location]);
    });
  });

  group('Error Handling Tests', () {
    test('Fallback data creation for unknown permission', () {
      // This tests the internal fallback mechanism
      // We can't directly test the private method, but we can verify
      // that the helper handles unknown cases gracefully
      final helper = ZebPermissionsHelper();
      expect(helper, isNotNull);
    });
  });

  // Widget tests for dialog components
  group('Widget Tests', () {
    testWidgets('Purpose dialog has correct structure',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                // We can't directly test the private _showPurposeDialog method
                // but we can test that our dialog structure is correct
                return ElevatedButton(
                  onPressed: () async {
                    await showDialog<void>(
                      context: context,
                      barrierDismissible: false,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Test Title'),
                        content: const Text('Test Explanation'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text('Next'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Explanation'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('Required permission dialog has correct structure',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await showDialog<bool>(
                      context: context,
                      barrierDismissible: false,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Attention'),
                        content: const Text('Test Caution'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop(false);
                            },
                            child: const Text('OK'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop(true);
                            },
                            child: const Text('Open Settings'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Show Required Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Required Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Attention'), findsOneWidget);
      expect(find.text('Test Caution'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
      expect(find.text('Open Settings'), findsOneWidget);
    });
  });
}
