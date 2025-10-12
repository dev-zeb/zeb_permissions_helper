import 'package:flutter/material.dart';
import 'test_scenarios.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zeb Permissions Helper - Test Suite'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildTestCard(
            context,
            'Single Permission (Default)',
            'Test basic permission request with default settings',
            Icons.perm_camera_mic,
            () => TestScenarios.testSinglePermission(context),
          ),
          _buildTestCard(
            context,
            'Single Permission (Custom Dialog)',
            'Test permission request with custom dialog text',
            Icons.edit_note,
            () => TestScenarios.testSinglePermissionCustomDialog(context),
          ),
          _buildTestCard(
            context,
            'Multiple Permissions',
            'Request multiple permissions simultaneously',
            Icons.playlist_add_check,
            () => TestScenarios.testMultiplePermissions(context),
          ),
          _buildTestCard(
            context,
            'Sequential Permissions',
            'Test onboarding-style sequential permission flow',
            Icons.linear_scale,
            () => TestScenarios.testSequentialPermissions(context),
          ),
          _buildTestCard(
            context,
            'Check Status',
            'Check current permission status without requesting',
            Icons.info_outline,
            () => TestScenarios.testPermissionStatus(context),
          ),
          _buildTestCard(
            context,
            'Edge Cases',
            'Test error handling and edge cases',
            Icons.warning_amber,
            () => TestScenarios.testUnknownPermission(context),
          ),
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildTestCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    VoidCallback onTest,
  ) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Colors.blue),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: ElevatedButton(
          onPressed: onTest,
          child: const Text('Test'),
        ),
        onTap: onTest,
      ),
    );
  }

  Widget _buildInfoCard() {
    return const Card(
      elevation: 2,
      color: Colors.blueAccent,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Testing Instructions:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text('1. Run each test scenario individually'),
            Text('2. Check console for any errors'),
            Text('3. Verify permission dialogs appear correctly'),
            Text('4. Test on both iOS and Android devices'),
            Text('5. Check behavior when permissions are granted/denied'),
          ],
        ),
      ),
    );
  }
}
