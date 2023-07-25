// ignore_for_file: invalid_use_of_internal_member, implementation_imports

import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';
import 'package:patrol_finders/src/custom_finders/patrol_tester.dart';

/// Signature for callback to [patrolWidgetTest].
typedef PatrolTesterCallback = Future<void> Function(PatrolTester $);

/// Like [testWidgets], but with support for Patrol custom finders.
///
/// To customize the Patrol-specific configuration, set [config].
///
/// ### Using the default [WidgetTester]
///
/// If you need to do something using Flutter's [WidgetTester], you can access
/// it like this:
///
/// ```dart
/// patrolWidgetTest(
///    'increase counter text',
///    ($) async {
///      await $.tester.tap(find.byIcon(Icons.add));
///    },
/// );
/// ```

@isTest
void patrolWidgetTest(
  String description,
  PatrolTesterCallback callback, {
  bool? skip,
  Timeout? timeout,
  bool semanticsEnabled = true,
  TestVariant<Object?> variant = const DefaultTestVariant(),
  dynamic tags,
  PatrolTesterConfig config = const PatrolTesterConfig(),
}) {
  testWidgets(
    description,
    skip: skip,
    timeout: timeout,
    semanticsEnabled: semanticsEnabled,
    variant: variant,
    tags: tags,
    (widgetTester) async {
      final patrolTester = PatrolTester(
        tester: widgetTester,
        config: config,
      );
      await callback(patrolTester);

      // ignore: prefer_const_declarations
      final waitSeconds = const int.fromEnvironment('PATROL_WAIT');
      final waitDuration = Duration(seconds: waitSeconds);

      if (waitDuration > Duration.zero) {
        final stopwatch = Stopwatch()..start();
        await Future.doWhile(() async {
          await widgetTester.pump();
          if (stopwatch.elapsed > waitDuration) {
            stopwatch.stop();
            return false;
          }

          return true;
        });
      }
    },
  );
}

/// Returns correct [settlePolicy], regardless which settling argument was set
@internal
SettlePolicy? chooseSettlePolicy({
  bool? andSettle,
  SettlePolicy? settlePolicy,
}) {
  SettlePolicy? settle;
  if (andSettle == null) {
    settle = settlePolicy;
  } else {
    if (andSettle) {
      settle = SettlePolicy.settle;
    } else {
      settle = SettlePolicy.noSettle;
    }
  }
  return settle;
}
