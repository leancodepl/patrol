import 'package:flutter/material.dart';

/// Controller app is normally launched via `flutter run --target=test_bundle.dart`
/// so this main() is rarely executed. It exists to make the project a valid
/// Flutter app for tooling purposes.
void main() {
  runApp(const ControllerApp());
}

class ControllerApp extends StatelessWidget {
  const ControllerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Patrol controller — run via test_bundle.dart',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
