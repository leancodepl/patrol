import 'package:cross_origin_lib/cross_origin_lib.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

void main() {
  runApp(const CanvasApp());
  initPatrolRemoteApp();
}

class CanvasApp extends StatelessWidget {
  const CanvasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Canvas', home: CanvasPage());
  }
}

String? _queryParam(String name) =>
    Uri.tryParse(web.window.location.href)?.queryParameters[name];

class CanvasPage extends StatefulWidget {
  const CanvasPage({super.key});
  @override
  State<CanvasPage> createState() => _CanvasPageState();
}

class _CanvasPageState extends State<CanvasPage> {
  int _count = 0;

  void _saveAndBack() {
    final returnUrl = _queryParam('return') ?? 'http://localhost:8082';
    final separator = returnUrl.contains('?') ? '&' : '?';
    web.window.location.href = '$returnUrl${separator}canvas=$_count';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Canvas')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Count: $_count', key: const Key('count_label')),
            const SizedBox(height: 16),
            ElevatedButton(
              key: const Key('increment'),
              onPressed: () => setState(() => _count++),
              child: const Text('+'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              key: const Key('save_back'),
              onPressed: _saveAndBack,
              child: const Text('Save & back'),
            ),
          ],
        ),
      ),
    );
  }
}
