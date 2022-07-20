import 'package:example/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/maestro_test.dart';

void main() {
  group('LoadingScreen', () {
    maestroTest('shows hello text when loading completes', ($) async {
      await $.pumpWidget(const MaterialApp(home: LoadingScreen()));

      final helloText = $('Hello');
      await helloText.visible;
      await helloText.tap(andSettle: false);
      expect(helloText, findsOneWidget);
    });
  });
}
