import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:windows_poc/main.dart';

void main() {
  testWidgets('WindowsPoC app renders demo home', (tester) async {
    await tester.pumpWidget(const WindowsPocApp());

    expect(find.byKey(const Key('appTitle')), findsOneWidget);
    expect(find.byKey(const Key('actionCount')), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
  });
}
