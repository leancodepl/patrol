import 'package:e2e_app/keys.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CursorBlinkScreen extends StatefulWidget {
  const CursorBlinkScreen({super.key});

  @override
  State<CursorBlinkScreen> createState() => _CursorBlinkScreenState();
}

class _CursorBlinkScreenState extends State<CursorBlinkScreen> {
  var _taps = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Cursor blink')),
        body: Column(
          children: [
            const TextField(key: K.materialTextField),
            const CupertinoTextField(key: K.cupertinoTextField),
            ElevatedButton(
              key: K.cursorBlinkCounterButton,
              onPressed: () => setState(() => _taps++),
              child: Text('taps: $_taps'),
            ),
          ],
        ),
      ),
    );
  }
}
