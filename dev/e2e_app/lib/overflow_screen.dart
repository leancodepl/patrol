import 'package:flutter/material.dart';
// Uncomment to test `Multiple exceptions were thrown` issue
// import 'package:flutter/services.dart';

class OverflowScreen extends StatelessWidget {
  const OverflowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Uncomment to test `Multiple exceptions were thrown` issue
    // Future<void> throwStackOverflowException() async {
    //   await Future<void>.delayed(const Duration(milliseconds: 100));
    //   throw StackOverflowError();
    // }
    //
    // Future<void> throwPlatformException() async {
    //   await Future<void>.delayed(const Duration(milliseconds: 110));
    //   throw PlatformException(code: 'code');
    // }
    //
    // Future<void> throwFormatException() async {
    //   await Future<void>.delayed(const Duration(milliseconds: 120));
    //   throw FormatException();
    // }
    //
    // throwStackOverflowException();
    // throwPlatformException();
    // throwFormatException();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Overflow'),
      ),
      body: Row(
        children: const <Widget>[
          // Uncomment to test `Multiple exceptions were thrown` issue
          // SizedBox(
          //   width: 500,
          //   child: Text('This container is too wide for the row'),
          // ),
          Icon(Icons.star, size: 50),
          Icon(Icons.abc, size: 50),
        ],
      ),
    );
  }
}
