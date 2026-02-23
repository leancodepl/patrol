import 'dart:io';

import 'package:camera/camera.dart';
import 'package:example/ui/components/button/elevated_button.dart';
import 'package:example/ui/components/scaffold.dart';
import 'package:example/ui/widgets/utils.dart';
import 'package:flutter/material.dart';

Route<void> get cameraRoute =>
    MaterialPageRoute(builder: (_) => const _CameraPage());

class _CameraPage extends StatefulWidget {
  const _CameraPage();

  @override
  State<_CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<_CameraPage>
    with WidgetsBindingObserver {
  CameraController? _controller;
  String? _imagePath;
  var _isInitializing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (_isInitializing) {
      return;
    }
    _isInitializing = true;

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty || !mounted) {
        return;
      }

      final controller = CameraController(
        cameras[0],
        ResolutionPreset.medium,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
      });
    } catch (_) {
      // Camera initialization failed
    } finally {
      _isInitializing = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _takePicture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    try {
      final xFile = await controller.takePicture();
      setState(() {
        _imagePath = xFile.path;
      });
    } catch (_) {
      // Taking picture failed
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PTScaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: _imagePath != null
                  ? Image.file(File(_imagePath!))
                  : const Placeholder(),
            ),
          ),
          const SizedBox(height: 24),
          PTElevatedButton(
            caption: 'Take a photo',
            onPressed: _takePicture,
          ),
          const SizedBox(height: 40),
        ],
      ).horizontallyPadded24,
    );
  }
}
