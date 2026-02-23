import 'dart:io';

import 'package:example/ui/components/button/elevated_button.dart';
import 'package:example/ui/components/scaffold.dart';
import 'package:example/ui/widgets/utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Route<void> get cameraRoute =>
    MaterialPageRoute(builder: (_) => const _CameraPage());

class _CameraPage extends StatefulWidget {
  const _CameraPage();

  @override
  State<_CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<_CameraPage> {
  String? _imagePath;

  Future<void> _takePicture() async {
    final xFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (xFile != null && mounted) {
      setState(() {
        _imagePath = xFile.path;
      });
    }
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
