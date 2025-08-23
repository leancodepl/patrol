import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest('example test 1', ($) async {
    // Replace later with your app's main widget
    await $.pumpWidgetAndSettle(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('App Test 1')),
          backgroundColor: Colors.blue,
          body: Builder(
            builder: (context) {
              return Column(
                children: [
                  Center(child: TextField(key: Key('text_field'))),
                  Center(
                    child: ElevatedButton(
                      key: Key('button'),
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

    await $(#button).tap();

    expect($('App Test 1'), findsOneWidget);
  });
}
