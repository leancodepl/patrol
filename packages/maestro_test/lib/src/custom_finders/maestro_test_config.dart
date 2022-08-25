import 'package:flutter_test/flutter_test.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'maestro_finder.dart';
import 'maestro_tester.dart';

part 'maestro_test_config.freezed.dart';

/// Common configuration for [MaestroTester] and [MaestroFinder].
@freezed
class MaestroTestConfig with _$MaestroTestConfig {
  /// Creates a new [MaestroTestConfig].
  const factory MaestroTestConfig({
    /// Time after which [MaestroFinder.waitUntilExists] fails if it doesn't
    /// finds a widget.
    @Default(Duration(seconds: 10)) Duration existsTimeout,

    /// Time after which [MaestroFinder.waitUntilVisible] fails if it doesn't
    /// finds a widget.
    ///
    /// [MaestroFinder.waitUntilVisible] is used internally by
    /// [MaestroFinder.tap] and [MaestroFinder.enterText].
    @Default(Duration(seconds: 10)) Duration visibleTimeout,

    /// Time after which [MaestroTester.pumpAndSettle] fails.
    @Default(Duration(seconds: 10)) Duration settleTimeout,

    /// Time to sleep after successful test execution. If set to
    /// [Duration.zero], then the test completes immediately after successful
    /// execution.
    @Default(Duration.zero) Duration sleep,

    /// Whether to call [WidgetTester.pumpAndSettle] after actions such as
    /// [MaestroFinder.tap] and [MaestroFinder]. If false, only
    /// [WidgetTester.pump] is called.
    @Default(true) bool andSettle,

    /// Name of the application under test.
    ///
    /// Used in [MaestroTester.log].
    String? appName,
  }) = _MaestroTestConfig;
}
