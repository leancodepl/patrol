import 'dart:io' as io;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FilePickerScreen extends StatefulWidget {
  const FilePickerScreen({super.key});

  @override
  State<FilePickerScreen> createState() => _FilePickerScreenState();
}

class _FilePickerScreenState extends State<FilePickerScreen> {
  final List<io.File> _files = [];

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    final path = result?.files.single.path;
    if (path != null) {
      setState(() {
        final file = io.File(path);
        _files.add(file);
      });
    } else {
      print('User canceled the picker');
    }
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
            TextButton(onPressed: _pickFile, child: Text('Open file picker')),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: _files.length,
                itemBuilder: (context, index) {
                  return Image.file(
                    _files[index],
                    key: Key('image_$index'),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
