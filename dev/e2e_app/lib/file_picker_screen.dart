import 'package:e2e_app/keys.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

/// Exercises the native file picker, so tests can drive it with Patrol's
/// native automation.
class FilePickerScreen extends StatefulWidget {
  const FilePickerScreen({super.key});

  @override
  State<FilePickerScreen> createState() => _FilePickerScreenState();
}

class _FilePickerScreenState extends State<FilePickerScreen> {
  var _status = 'idle';

  Future<void> _pickFile() async {
    setState(() => _status = 'picking');

    final result = await FilePicker.platform.pickFiles();
    if (!mounted) {
      return;
    }

    setState(() {
      _status = result == null
          ? 'cancelled'
          : 'picked: ${result.files.single.name}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('File picker')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status, key: K.filePickerStatusText),
            const SizedBox(height: 16),
            ElevatedButton(
              key: K.pickFileButton,
              onPressed: _pickFile,
              child: const Text('Pick file'),
            ),
          ],
        ),
      ),
    );
  }
}
