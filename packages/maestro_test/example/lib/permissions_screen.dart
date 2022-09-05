import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool _cameraPermissionGranted = false;
  bool _microphonePermissionGranted = false;

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _cameraPermissionGranted = status == PermissionStatus.granted;
    });
  }

  Future<void> _requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    setState(() {
      _microphonePermissionGranted = status == PermissionStatus.granted;
    });
  }

  @override
  void initState() {
    super.initState();

    Permission.camera.status.then(
      (value) {
        setState(() {
          _cameraPermissionGranted = value == PermissionStatus.granted;
        });
      },
    );

    Permission.microphone.status.then(
      (value) {
        setState(() {
          _microphonePermissionGranted = value == PermissionStatus.granted;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permissions'),
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              children: [
                const Text('Camera'),
                TextButton(
                  onPressed: _requestCameraPermission,
                  child: const Text('Request'),
                ),
                Text('Granted: $_cameraPermissionGranted'),
              ],
            ),
            Row(
              children: [
                const Text('Microphone'),
                TextButton(
                  onPressed: _requestMicrophonePermission,
                  child: const Text('Request'),
                ),
                Text('Granted: $_microphonePermissionGranted'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
