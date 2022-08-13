import 'package:flutter_test/flutter_test.dart';

import 'maestro_finder.dart';
import 'maestro_tester.dart';

/// Common configuration for [MaestroTester] and [MaestroFinder].
class MaestroTestConfig {
  /// Creates a new [MaestroTestConfig].
  const MaestroTestConfig({
    this.existsTimeout = const Duration(seconds: 10),
    this.visibleTimeout = const Duration(seconds: 10),
    this.settleTimeout = const Duration(seconds: 10),
    this.sleep = Duration.zero,
    this.andSettle = true,
    this.appName,
  });

  /// Time after which [MaestroFinder.waitUntilExists] fails if it doesn't finds
  /// a widget.
  final Duration existsTimeout;

  /// Time after which [MaestroFinder.waitUntilVisible] fails if it doesn't
  /// finds a widget.
  ///
  /// [MaestroFinder.waitUntilVisible] is used internally by [MaestroFinder.tap]
  /// and [MaestroFinder.enterText].
  final Duration visibleTimeout;

  /// Time after which [MaestroTester.pumpAndSettle] fails.
  final Duration settleTimeout;

  /// Time to sleep after successful test execution. If set to [Duration.zero],
  /// then the test completes immediately after successful execution.
  final Duration sleep;

  /// Whether to call [WidgetTester.pumpAndSettle] after actions such as
  /// [MaestroFinder.tap] and [MaestroFinder]. If false, only
  /// [WidgetTester.pump] is called.
  final bool andSettle;

  /// Name of the application under test.
  ///
  /// Used in [MaestroTester.log].
  final String? appName;
}
