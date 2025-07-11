import 'package:flutter/material.dart';

class OverflowScreen extends StatelessWidget {
  const OverflowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overflow'),
      ),
      body: Column(
        children: const [
          Row(
            children: <Widget>[
              // Uncomment to test `Multiple exceptions were thrown` issue
              SizedBox(
                width: 500,
                child: Text('This container is too wide for the row'),
              ),
              Icon(Icons.star, size: 50),
              Icon(Icons.abc, size: 50),
            ],
          ),
          SizedBox(
            height: 2000,
            child: Text('This container is too high for the row'),
          ),
        ],
      ),
    );
  }
}
