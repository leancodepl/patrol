import 'package:flutter/material.dart';

class ScrollingScreenBug extends StatelessWidget {
  const ScrollingScreenBug({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: ListView(key: Key('listView1'))),
          Expanded(
            child: ListView.builder(
              key: Key('listView2'),
              itemCount: 101,
              itemBuilder: (context, index) => Text('index: $index'),
            ),
          ),
        ],
      ),
    );
  }
}
