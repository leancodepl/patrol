import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _capturedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _onAddPhotoTap(ImageSource source) async {
    try {
      final xFile = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (xFile != null) {
        setState(() {
          _capturedImage = File(xFile.path);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Photo captured: ${xFile.path}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearCapturedImage() {
    setState(() {
      _capturedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('cameraScaffold'),
      appBar: AppBar(
        title: const Text('Camera'),
      ),
      backgroundColor: Colors.white,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_capturedImage != null) {
      return _buildImagePreview();
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            key: const Key('takePhotoButton'),
            onPressed: () => _onAddPhotoTap(ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take a photo'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            key: const Key('chooseFromGalleryButton'),
            onPressed: () => _onAddPhotoTap(ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('Choose from Gallery'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            color: Colors.white,
            child: Image.file(
              _capturedImage!,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                key: const Key('takeAnotherPhotoButton'),
                onPressed: _clearCapturedImage,
                icon: const Icon(Icons.refresh),
                label: const Text('Take Another'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[600],
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                key: const Key('usePhotoButton'),
                onPressed: () {
                  Navigator.of(context).pop(_capturedImage!.path);
                },
                icon: const Icon(Icons.check),
                label: const Text('Use Photo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
