import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';
import 'package:patrol_test/src/custom_finders/patrol_test_config.dart';
import 'package:patrol_test/src/custom_finders/patrol_tester.dart';

/// Signature for callback to [patrolTest].
typedef PatrolTesterCallback = Future<void> Function(PatrolTester $);

/// Like [testWidgets], but with support for Patrol custom finders.
///
/// To customize the Patrol-specific configuration, set [config].
///
/// ### Using the default [WidgetTester]
/// If you need to do something using Flutter's [WidgetTester], you can access
/// it like this:
///
/// ```dart
/// patrolTest(
///    'increase counter text',
///    ($) async {
///      await $.tester.tap(find.byIcon(Icons.add));
///    },
/// );
/// ```
@isTest
void patrolTest(
  String description,
  PatrolTesterCallback callback, {
  bool? skip,
  Timeout? timeout,
  bool semanticsEnabled = true,
  TestVariant<Object?> variant = const DefaultTestVariant(),
  dynamic tags,
  PatrolTestConfig config = const PatrolTestConfig(),
}) {
  return testWidgets(
    description,
    skip: skip,
    timeout: timeout,
    semanticsEnabled: semanticsEnabled,
    variant: variant,
    tags: tags,
    (widgetTester) async {
      final patrolTester = PatrolTester(tester: widgetTester, config: config);
      await callback(patrolTester);

      // ignore: prefer_const_declarations
      final waitSeconds = const int.fromEnvironment('PATROL_WAIT');
      final waitDuration = Duration(seconds: waitSeconds);
      if (waitDuration > Duration.zero) {
        patrolTester.log(
          'sleeping for $waitSeconds seconds',
          name: 'patrolTest',
        );
        await Future<void>.delayed(waitDuration);
        patrolTester.log('done sleeping', name: 'patrolTest');
      }
    },
  );
}
