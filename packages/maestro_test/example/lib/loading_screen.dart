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

    Future<void>.delayed(const Duration(seconds: 3)).then(
      (_) {
        setState(() {
          _visible = true;
        });
      },
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
