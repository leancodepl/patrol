import 'package:example/keys.dart';
import 'package:flutter/material.dart';

class ScrollingScreen extends StatelessWidget {
  const ScrollingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scrolling'),
      ),
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
