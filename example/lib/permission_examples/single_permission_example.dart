import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zeb_permissions_helper/zeb_permissions_helper.dart';

class SinglePermissionExample extends StatefulWidget {
  const SinglePermissionExample({super.key});

  @override
  State<SinglePermissionExample> createState() =>
      _SinglePermissionExampleState();
}

class _SinglePermissionExampleState extends State<SinglePermissionExample> {
  final ZebPermissionsHelper _permissionsHelper = ZebPermissionsHelper();
  String _result = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Single Permission Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPermissionButton(
              'Camera Permission',
              Icons.camera_alt,
              Permission.camera,
            ),
            const SizedBox(height: 12),
            _buildPermissionButton(
              'Location (Permission Handler)',
              Icons.location_on,
              Permission.location,
              package: PermissionPackage.permissionHandler,
            ),
            const SizedBox(height: 12),
            _buildPermissionButton(
              'Location (Location Package)',
              Icons.location_on,
              Permission.location,
              package: PermissionPackage.location,
            ),
            const SizedBox(height: 12),
            _buildPermissionButton(
              'Notifications',
              Icons.notifications,
              Permission.notification,
            ),
            const SizedBox(height: 12),
            _buildPermissionButton(
              'Photos',
              Icons.photo_library,
              Permission.photos,
            ),
            const SizedBox(height: 24),
            if (_result.isNotEmpty) ...[
              const Text(
                'Result:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_result),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionButton(
    String title,
    IconData icon,
    Permission permission, {
    PermissionPackage? package,
  }) {
    return ElevatedButton.icon(
      onPressed: () => _requestPermission(permission, package: package),
      icon: Icon(icon),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Future<void> _requestPermission(Permission permission,
      {PermissionPackage? package}) async {
    setState(() {
      _result = 'Requesting permission...';
    });

    try {
      final result = await _permissionsHelper.requestPermission(
        context,
        permission,
        requestConfig: SingleRequestConfig(
          package: package,
          dialogText: DialogText(
            title: 'Custom ${permission.toString().split('.').last} Title',
            explanation:
                'This is a custom explanation for ${permission.toString().split('.').last} permission.',
            caution: 'Please enable this permission in settings if denied.',
          ),
        ),
      );

      setState(() {
        _result = 'Permission: ${result.permission}\n'
            'Granted: ${result.isGranted}\n'
            'Package Used: ${result.usedPackage}\n'
            'Error: ${result.error ?? "None"}';
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    }
  }
}
