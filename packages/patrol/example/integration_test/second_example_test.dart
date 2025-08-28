import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest('example test 2', ($) async {
    // Replace later with your app's main widget
    await $.pumpWidgetAndSettle(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('App Test 2')),
          backgroundColor: Colors.blue,
          body: Builder(
            builder: (context) {
              return Column(
                children: [
                  const Center(child: TextField(key: Key('text_field'))),
                  Center(
                    child: ElevatedButton(
                      key: const Key('button'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Button pressed')),
                        );
                      },
                      child: const Text('Test 1'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    await $(#text_field).enterText('Test 1');

    await Future<void>.delayed(const Duration(seconds: 2));

    await $(#button).tap();

    await Future<void>.delayed(const Duration(seconds: 2));

    expect($('App Test 2'), findsOneWidget);
  });
}
