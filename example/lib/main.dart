import 'package:flutter/material.dart';
import 'package:zeb_permissions_helper/zeb_permissions_helper.dart';

void main() {
  runApp(const ZebPermissionsExampleApp());
}

class ZebPermissionsExampleApp extends StatelessWidget {
  const ZebPermissionsExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zeb Permissions Helper Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const PermissionDemoScreen(),
    );
  }
}

class PermissionDemoScreen extends StatefulWidget {
  const PermissionDemoScreen({super.key});

  @override
  State<PermissionDemoScreen> createState() => _PermissionDemoScreenState();
}

class _PermissionDemoScreenState extends State<PermissionDemoScreen> {
  late ZebPermissionsHelper _helper;
  final Map<ZebPermission, bool> _status = {};

  @override
  void initState() {
    super.initState();
    _helper = ZebPermissionsHelper();
    _checkAllPermissions();
  }

  Future<void> _checkAllPermissions() async {
    for (final perm in ZebPermission.values) {
      if (perm == ZebPermission.unknown) continue;
      final granted = await _helper.isPermissionGranted(perm);
      setState(() => _status[perm] = granted);
    }
  }

  Future<void> _requestSinglePermission(ZebPermission permission) async {
    final result = await _helper.requestPermission(context, permission);
    setState(() => _status[permission] = result.isGranted);
    _showSnack(
        "${permission.name} → ${result.isGranted ? 'Granted' : 'Denied'}");
  }

  Future<void> _requestSequentialPermissions() async {
    final results = await _helper.requestPermissionsSequentially(
      context,
      sequentialConfig: const SequentialRequestConfig(
        permissions: [
          ZebPermission.camera,
          ZebPermission.microphone,
          ZebPermission.locationWhenInUse,
        ],
        delayBetweenRequests: Duration(milliseconds: 500),
      ),
    );

    for (final res in results) {
      setState(() => _status[res.permission] = res.isGranted);
    }
    _showSnack("Sequential request completed.");
  }

  Future<void> _requestWithCustomDialog() async {
    final helper = ZebPermissionsHelper(
      config: ZebPermissionsConfig(
        overrides: {
          ZebPermission.notification: const AppPermissionData(
            permission: ZebPermission.notification,
            dialogText: DialogText(
              title: "Custom Notification Access",
              explanation:
                  "Allow us to send you important order and chat updates.",
              caution: "Notifications are disabled. Please enable them.",
            ),
          ),
        },
        permanentlyDeniedDialogBuilder: (context, data, onOpenSettings) {
          return AlertDialog(
            title: Text("Custom ${data.permission.name} Dialog"),
            content: Text(data.dialogText.caution),
            actions: [
              TextButton(
                onPressed: onOpenSettings,
                child: const Text("Open Settings"),
              ),
            ],
          );
        },
      ),
    );

    final result = await helper.requestPermission(
      context,
      ZebPermission.notification,
      requestConfig: const SingleRequestConfig(
        showPurposeDialog: true,
      ),
    );

    setState(() => _status[ZebPermission.notification] = result.isGranted);
    _showSnack("Custom flow: ${result.isGranted ? 'Granted' : 'Denied'}");
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final permissions =
        ZebPermission.values.where((p) => p != ZebPermission.unknown).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zeb Permissions Helper Example'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "🎯 Single Permission Request",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: permissions
                .map((perm) => ElevatedButton.icon(
                      icon: Icon(
                        _status[perm] == true
                            ? Icons.check_circle
                            : Icons.lock_outline,
                      ),
                      label: Text(perm.name),
                      onPressed: () => _requestSinglePermission(perm),
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const Text(
            "🔁 Sequential Permissions",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.play_circle_fill),
            label: const Text("Request Camera, Mic & Location"),
            onPressed: _requestSequentialPermissions,
          ),
          const SizedBox(height: 24),
          const Divider(),
          const Text(
            "✨ Custom Configuration Flow",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.notifications_active_outlined),
            label: const Text("Request Notification (Custom Dialog)"),
            onPressed: _requestWithCustomDialog,
          ),
          const SizedBox(height: 24),
          const Divider(),
          const Text(
            "📋 Current Status Overview",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          ...permissions.map((perm) {
            final granted = _status[perm] ?? false;
            return ListTile(
              leading: Icon(
                granted ? Icons.check_circle : Icons.cancel_outlined,
                color: granted ? Colors.green : Colors.redAccent,
              ),
              title: Text(perm.name),
              subtitle: Text(granted ? "Granted" : "Denied"),
            );
          }),
        ],
      ),
    );
  }
}
