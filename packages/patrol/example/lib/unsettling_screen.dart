import 'package:flutter/material.dart';

class UnsettlingScreen extends StatelessWidget {
  const UnsettlingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scrolling'),
      ),
      body: IndexedStack(
        children: [
          Center(
            child: Text('first child'),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('second child'),
                CircularProgressIndicator(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
