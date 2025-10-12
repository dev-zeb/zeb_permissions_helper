import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zeb_permissions_helper/zeb_permissions_helper.dart';

class MultiplePermissionExample extends StatefulWidget {
  const MultiplePermissionExample({super.key});

  @override
  State<MultiplePermissionExample> createState() =>
      _MultiplePermissionExampleState();
}

class _MultiplePermissionExampleState extends State<MultiplePermissionExample> {
  final ZebPermissionsHelper _permissionsHelper = ZebPermissionsHelper();
  List<String> _results = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multiple Permissions Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _requestMultiplePermissions,
              icon: const Icon(Icons.all_inclusive),
              label: const Text('Request Camera & Microphone'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _requestWithPackageOverrides,
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Request with Package Overrides'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            if (_results.isNotEmpty) ...[
              const Text(
                'Results:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_results[index]),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _requestMultiplePermissions() async {
    setState(() {
      _results = ['Requesting permissions...'];
    });

    try {
      final results = await _permissionsHelper.requestMultiplePermissions(
        context,
        [Permission.camera, Permission.microphone, Permission.photos],
        requestConfigs: {
          Permission.camera:
              const SingleRequestConfig(showPurposeDialog: false),
        },
      );

      setState(() {
        _results = results
            .map((result) =>
                '${result.permission}: ${result.isGranted ? "GRANTED" : "DENIED"} (${result.usedPackage})')
            .toList();
      });
    } catch (e) {
      setState(() {
        _results = ['Error: $e'];
      });
    }
  }

  Future<void> _requestWithPackageOverrides() async {
    setState(() {
      _results = ['Requesting with package overrides...'];
    });

    try {
      final results = await _permissionsHelper.requestMultiplePermissions(
        context,
        [Permission.location, Permission.notification],
        requestConfigs: {
          Permission.location: SingleRequestConfig(
            package: PermissionPackage.location,
          ),
          Permission.notification: SingleRequestConfig(
            package: PermissionPackage.notifications,
          ),
        },
      );

      setState(() {
        _results = results
            .map((result) =>
                '${result.permission}: ${result.isGranted ? "GRANTED" : "DENIED"} (${result.usedPackage})')
            .toList();
      });
    } catch (e) {
      setState(() {
        _results = ['Error: $e'];
      });
    }
  }
}
