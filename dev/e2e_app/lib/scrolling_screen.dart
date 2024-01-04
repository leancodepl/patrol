import 'package:dio/dio.dart';
import 'package:e2e_app/keys.dart';
import 'package:flutter/material.dart';

class ScrollingScreen extends StatelessWidget {
  const ScrollingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(key: K.backButton),
        title: const Text('Scrolling'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Some text at the top',
              key: K.topText,
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
              onPressed: throwDioException,
              child: Text('Throw dio exception'),
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
    );
  }

  void throwDioException() {
    final dio = Dio();
    try {
      final response = dio.get<dynamic>('https://assadadasdasdadsgoogle.com');
    } on DioException catch (error) {
      print('DioException!!!!');
      print(error);
    }
  }
}
