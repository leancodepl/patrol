import 'dart:async';

import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();

    unawaited(
      Future<void>.delayed(const Duration(seconds: 3)).then(
        (_) {
          if (!mounted) {
            return;
          }

          setState(() {
            _visible = true;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loading'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: 32),
            if (_visible)
              const Text('Hello')
            else
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
