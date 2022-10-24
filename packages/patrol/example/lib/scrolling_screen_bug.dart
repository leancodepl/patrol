import 'package:flutter/material.dart';

class ScrollingScreenBug extends StatelessWidget {
  const ScrollingScreenBug({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scrolling bug'),
      ),
      body: Column(
        children: [
          Container(
            height: 10,
            color: Colors.orangeAccent,
            child: ListView(
              key: Key('listView1'),
              shrinkWrap: true,
              children: const [
                Text('random 1'),
                Text('random 2'),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              key: Key('listView2'),
              itemCount: 101,
              itemBuilder: (context, index) {
                return Text('index: $index');
              },
            ),
          ),
        ],
      ),
    );
  }
}
