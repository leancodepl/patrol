import 'package:example/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/maestro_test.dart';

void main() {
  // final binding = TestWidgetsFlutterBinding.ensureInitialized({
  //   'FLUTTER_TEST': 'false',
  // });
  // if (binding is LiveTestWidgetsFlutterBinding) {
  //   binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  // }

  group('group', () {
    /* testWidgets('shows hello text (flutter)', (tester) async {
      print('starting flutter test');
      await tester.pumpWidget(const MaterialApp(home: LoadingScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hello').hitTestable());
      expect(find.text('Hello'), findsOneWidget);
    }); */

    maestroTest('shows hello text (maestro)', ($) async {
      print('starting maestro test');
      await $.pumpWidget(const MaterialApp(home: LoadingScreen()));
      await $.tester.pump();

      final helloFinder = $('Hello');
      print('waiting for text to appear');
      await helloFinder.visible;
      print('waiting for tap');
      await helloFinder.tap(andSettle: false);
      print('after tap');
      expect(helloFinder, findsOneWidget);
    });
  });
}

extension MaestroX on MaestroFinder {
  Future<MaestroFinder> waitFor({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final end = DateTime.now().add(timeout);

    do {
      if (DateTime.now().isAfter(end)) {
        throw Exception('Timed out waiting for $finder');
      }

      print('waiting for');

      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 100));
    } while (evaluate().isEmpty);

    return this;
  }

  Future<MaestroFinder> get visible async {
    while (hitTestable().evaluate().isEmpty) {
      print('no visible found');
      await tester.pump(const Duration(milliseconds: 100));
      // await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    print('VISIBLE FOUND!');

    await tester.pump(const Duration(milliseconds: 100));

    return this;
  }
}
