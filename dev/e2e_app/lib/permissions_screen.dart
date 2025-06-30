import 'dart:async';

import 'package:e2e_app/keys.dart';
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
  bool _locationPermissionGranted = false;
  bool _galleryPermissionGranted = false;

  Future<void> _requestCameraPermission() async {
    await Future<void>.delayed(Duration(seconds: 1));

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

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    setState(() {
      _locationPermissionGranted = status == PermissionStatus.granted;
    });
  }

  Future<void> _requestGalleryPermission() async {
    final status = await Permission.storage.request();
    setState(() {
      _galleryPermissionGranted = status == PermissionStatus.granted;
    });
  }

  @override
  void initState() {
    super.initState();

    unawaited(
      Permission.camera.status.then(
        (value) {
          setState(() {
            _cameraPermissionGranted = value == PermissionStatus.granted;
          });
        },
      ),
    );

    unawaited(
      Permission.microphone.status.then(
        (value) {
          setState(() {
            _microphonePermissionGranted = value == PermissionStatus.granted;
          });
        },
      ),
    );
    unawaited(
      Permission.location.status.then(
        (value) {
          setState(() {
            _locationPermissionGranted = value == PermissionStatus.granted;
          });
        },
      ),
    );
    unawaited(
      Permission.storage.status.then(
        (value) {
          setState(() {
            _galleryPermissionGranted = value == PermissionStatus.granted;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: K.permissionsScreen,
      appBar: AppBar(
        title: const Text('Permissions'),
      ),
      body: Center(
        child: Column(
          children: [
            _PermissionTile(
              name: 'Camera',
              icon: Icons.camera,
              granted: _cameraPermissionGranted,
              onTap: _requestCameraPermission,
              key: K.cameraPermissionTile,
            ),
            _PermissionTile(
              name: 'Microphone',
              icon: Icons.mic,
              granted: _microphonePermissionGranted,
              onTap: _requestMicrophonePermission,
              key: K.microphonePermissionTile,
            ),
            _PermissionTile(
              name: 'Location',
              icon: Icons.pin_drop,
              granted: _locationPermissionGranted,
              onTap: _requestLocationPermission,
              key: K.locationPermissionTile,
            ),
            _PermissionTile(
              name: 'Gallery',
              icon: Icons.photo_library,
              granted: _galleryPermissionGranted,
              onTap: _requestGalleryPermission,
              key: K.galleryPermissionTile,
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    super.key,
    required this.name,
    required this.icon,
    required this.granted,
    required this.onTap,
  });

  final String name;
  final IconData icon;
  final bool granted;
  final VoidCallback onTap;

  Key _getRequestButtonKey(String permissionName) {
    switch (permissionName.toLowerCase()) {
      case 'camera':
        return K.requestCameraPermissionButton;
      case 'microphone':
        return K.requestMicrophonePermissionButton;
      case 'location':
        return K.requestLocationPermissionButton;
      case 'gallery':
        return K.requestGalleryPermissionButton;
      default:
        return Key('request${permissionName}PermissionButton');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: key,
      padding: const EdgeInsets.all(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: granted
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.error,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Text(
                  name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            Text(
              key: K.statusText,
              granted ? 'Granted' : 'Not granted',
            ),
            TextButton(
              key: _getRequestButtonKey(name),
              onPressed: onTap,
              child: Text(
                'Request ${name.toLowerCase()} permission',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
