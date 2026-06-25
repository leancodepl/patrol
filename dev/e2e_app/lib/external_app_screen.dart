import 'package:e2e_app/keys.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ExternalAppScreen extends StatefulWidget {
  const ExternalAppScreen({super.key});

  @override
  State<ExternalAppScreen> createState() => _ExternalAppScreenState();
}

class _ExternalAppScreenState extends State<ExternalAppScreen> {
  var _status = 'Ready';

  Future<void> _openSettings() async {
    final opened = await openAppSettings();
    if (!mounted) {
      return;
    }

    setState(() {
      _status = opened ? 'Settings opened' : 'Failed to open Settings';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('External app screen')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: $_status', key: K.externalAppStatusText),
            const SizedBox(height: 16),
            ElevatedButton(
              key: K.openIosSettingsButton,
              onPressed: _openSettings,
              child: const Text('Open app settings'),
            ),
          ],
        ),
      ),
    );
  }
}
