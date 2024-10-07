import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OverflowScreen extends StatelessWidget {
  const OverflowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> throwStackOverflowException() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      throw StackOverflowError();
    }

    Future<void> throwPlatformException() async {
      await Future<void>.delayed(const Duration(milliseconds: 150));
      throw PlatformException(code: 'code');
    }

    throwStackOverflowException();
    throwPlatformException();

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
