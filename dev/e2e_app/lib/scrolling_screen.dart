import 'package:e2e_app/keys.dart';
import 'package:flutter/material.dart';

class ScrollingScreen extends StatefulWidget {
  const ScrollingScreen({super.key});

  @override
  State<ScrollingScreen> createState() => _ScrollingScreenState();
}

class _ScrollingScreenState extends State<ScrollingScreen> {
  int _refreshCount = 0;

  Future<void> _onRefresh() async {
    // Simulate some async work
    await Future<void>.delayed(const Duration(milliseconds: 500));

    setState(() {
      _refreshCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(key: K.backButton),
        title: const Text('Pull to refresh'),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ListTile(
                key: K.tile1,
                title: const Text('Item 1'),
                tileColor: Colors.blue[100],
              ),
              const Divider(height: 1),
              ListTile(
                key: K.tile2,
                title: const Text('Item 2'),
                tileColor: Colors.blue[100],
              ),
              if (_refreshCount >= 2) ...[
                const Divider(height: 1),
                ListTile(
                  key: const Key('tile3'),
                  title: const Text('Awaited item 3'),
                  tileColor: Colors.green[100],
                ),
              ],
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
      ),
    );
  }
}
