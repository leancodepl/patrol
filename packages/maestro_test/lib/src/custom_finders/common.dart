import 'dart:io' as io;

import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/src/custom_finders/maestro_test_config.dart';
import 'package:maestro_test/src/custom_finders/maestro_tester.dart';
import 'package:meta/meta.dart';

/// Signature for callback to [maestroTest].
typedef MaestroTesterCallback = Future<void> Function(MaestroTester $);

/// Like [testWidgets], but with support for Maestro custom finders.
///
/// To customize the Maestro-specific configuration, set [config].
///
/// ### Using the default [WidgetTester]
/// If you need to do something using Flutter's [WidgetTester], you can access
/// it like this:
///
/// ```dart
/// maestroTest(
///    'increase counter text',
///    ($) async {
///      await $.tester.tap(find.byIcon(Icons.add));
///    },
/// );
/// ```
@isTest
void maestroTest(
  String description,
  MaestroTesterCallback callback, {
  bool? skip,
  Timeout? timeout,
  bool semanticsEnabled = true,
  TestVariant<Object?> variant = const DefaultTestVariant(),
  dynamic tags,
  MaestroTestConfig config = const MaestroTestConfig(),
}) {
  return testWidgets(
    description,
    skip: skip,
    timeout: timeout,
    semanticsEnabled: semanticsEnabled,
    variant: variant,
    tags: tags,
    (widgetTester) async {
      final maestroTester = MaestroTester(tester: widgetTester, config: config);
      await callback(maestroTester);
      if (config.sleep != Duration.zero) {
        maestroTester.log(
          'sleeping for ${config.sleep.inSeconds} seconds',
          name: 'maestroTest',
        );
        io.sleep(config.sleep);
        maestroTester.log('done sleeping', name: 'maestroTest');
      }
    },
  );
}
