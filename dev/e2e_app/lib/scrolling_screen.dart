import 'package:e2e_app/keys.dart';
import 'package:flutter/material.dart';

class ScrollingScreen extends StatefulWidget {
  const ScrollingScreen({super.key});

  @override
  State<ScrollingScreen> createState() => _ScrollingScreenState();
}

class _ScrollingScreenState extends State<ScrollingScreen> {
  bool _showRefreshText = false;

  Future<void> _onRefresh() async {
    // Simulate some async work
    await Future<void>.delayed(const Duration(milliseconds: 500));

    setState(() {
      _showRefreshText = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(key: K.backButton),
        title: const Text('Scrolling'),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Some text at the top',
                key: K.topText,
                textAlign: TextAlign.center,
              ),
              if (_showRefreshText)
                const Text(
                  key: K.refreshText,
                  'Some text that appeared after refresh',
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
      ),
    );
  }
}
