import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zeb_permissions_helper/zeb_permissions_helper.dart';

class SequentialPermissionExample extends StatefulWidget {
  const SequentialPermissionExample({super.key});

  @override
  State<SequentialPermissionExample> createState() =>
      _SequentialPermissionExampleState();
}

class _SequentialPermissionExampleState
    extends State<SequentialPermissionExample> {
  final ZebPermissionsHelper _permissionsHelper = ZebPermissionsHelper();
  List<String> _results = [];
  bool _isRunning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sequential Permissions Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _isRunning ? null : _runSequentialFlow,
              icon: const Icon(Icons.linear_scale),
              label: _isRunning
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Processing...'),
                      ],
                    )
                  : const Text('Run Sequential Flow'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isRunning ? null : _runCustomSequentialFlow,
              icon: const Icon(Icons.settings),
              label: const Text('Custom Sequential Flow'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            if (_results.isNotEmpty) ...[
              const Text(
                'Progress:',
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
                        color: _results[index].contains('GRANTED')
                            ? Colors.green[50]
                            : _results[index].contains('DENIED')
                                ? Colors.red[50]
                                : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _results[index].contains('GRANTED')
                              ? Colors.green
                              : _results[index].contains('DENIED')
                                  ? Colors.red
                                  : Colors.grey,
                        ),
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

  Future<void> _runSequentialFlow() async {
    setState(() {
      _isRunning = true;
      _results = ['Starting sequential flow...'];
    });

    try {
      final results = await _permissionsHelper
          .requestPermissionsSequentiallyWithUI(context);

      setState(() {
        _results.add('Sequential flow completed!');
        _isRunning = false;
      });
    } catch (e) {
      setState(() {
        _results.add('Error: $e');
        _isRunning = false;
      });
    }
  }

  Future<void> _runCustomSequentialFlow() async {
    setState(() {
      _isRunning = true;
      _results = ['Starting custom sequential flow...'];
    });

    try {
      final results = await _permissionsHelper.requestPermissionsSequentially(
        context,
        sequentialConfig: SequentialRequestConfig(
          permissions: [
            Permission.camera,
            Permission.location,
            Permission.notification,
            Permission.photos,
          ],
          packageOverrides: {
            Permission.location: PermissionPackage.location,
            Permission.notification: PermissionPackage.notifications,
          },
          showPurposeDialogs: true,
          delayBetweenRequests: const Duration(milliseconds: 500),
        ),
      );

      setState(() {
        _results.addAll(results
            .map((result) =>
                '${result.permission}: ${result.isGranted ? "GRANTED" : "DENIED"} (${result.usedPackage})')
            .toList());
        _results.add('Custom sequential flow completed!');
        _isRunning = false;
      });
    } catch (e) {
      setState(() {
        _results.add('Error: $e');
        _isRunning = false;
      });
    }
  }
}
