import 'package:flutter/material.dart';

class OverlayScreen extends StatelessWidget {
  const OverlayScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Center(child: Text('hidden boi')),
          Center(
            child: Container(
              width: 150,
              height: 150,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
