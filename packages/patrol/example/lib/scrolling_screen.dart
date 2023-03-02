import 'package:example/keys.dart';
import 'package:flutter/material.dart';

class ScrollingScreen extends StatefulWidget {
  const ScrollingScreen({super.key});

  @override
  State<ScrollingScreen> createState() => _ScrollingScreenState();
}

class _ScrollingScreenState extends State<ScrollingScreen> {
  bool showAppBar = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: const Text('Scrolling'),
            )
          : null,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Some text at the top',
              key: K.topText,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => setState(() => showAppBar = !showAppBar),
              child: Text('toggle app bar'),
            ),
            SizedBox(height: MediaQuery.of(context).size.height),
            const Text('Some text in the middle'),
            SizedBox(height: MediaQuery.of(context).size.height),
            const Text(
              'Some text at the bottom',
              key: K.bottomText,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
