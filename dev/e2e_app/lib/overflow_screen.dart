import 'package:flutter/material.dart';

class OverflowScreen extends StatelessWidget {
  const OverflowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overflow'),
      ),
      body: Row(
        children: const <Widget>[
          SizedBox(
            width: 500,
            child: Text('This container is too wide for the row'),
          ),
          Icon(Icons.star, size: 50),
        ],
      ),
    );
  }
}
