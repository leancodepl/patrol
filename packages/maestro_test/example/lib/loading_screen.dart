import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();

    Future<void>.delayed(const Duration(seconds: 1)).then(
      (_) => setState(() {
        _visible = true;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LoadingScreen'),
      ),
      body: Center(
        child:
            _visible ? const Text('Hello') : const CircularProgressIndicator(),
      ),
    );
  }
}
