import 'package:e2e_app/keys.dart';
import 'package:flutter/material.dart';

import 'common.dart';

// Fades in over 1 s, so settling it takes more than one 100 ms pump.
class _FadeIn extends StatelessWidget {
  const _FadeIn();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(seconds: 1),
          builder: (context, opacity, child) =>
              Opacity(opacity: opacity, child: child),
          child: const Text('faded in'),
        ),
      ),
    );
  }
}

void main() {
  // A settle always pumps at least once, so each test pairs an idle settle
  // (exactly 1) with an animated one (more than 1).
  patrol(
    'pumpAndSettle() returns the number of pumped frames',
    ($) async {
      await createApp($);
      // noSettle leaves the route transition for pumpAndSettle to count.
      await $(
        K.atFinderScreenButton,
      ).scrollTo().tap(settlePolicy: SettlePolicy.noSettle);
      final transitionFrames = await $.pumpAndSettle();
      expect($('at() finder'), findsOneWidget);

      final idleFrames = await $.pumpAndSettle();

      expect(idleFrames, 1);
      expect(transitionFrames, greaterThan(1));
    },
    tags: ['android', 'emulator', 'ios', 'simulator'],
  );

  patrol(
    'pumpWidgetAndSettle() returns the number of pumped frames',
    ($) async {
      final idleFrames = await $.pumpWidgetAndSettle(
        const MaterialApp(home: Text('static')),
      );
      final fadeInFrames = await $.pumpWidgetAndSettle(const _FadeIn());

      expect(idleFrames, 1);
      expect(fadeInFrames, greaterThan(1));
      expect($('faded in'), findsOneWidget);
    },
    tags: ['android', 'emulator', 'ios', 'simulator'],
  );
}
