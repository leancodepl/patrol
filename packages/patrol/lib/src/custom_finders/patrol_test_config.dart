import 'package:flutter_test/flutter_test.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'patrol_finder.dart';
import 'patrol_tester.dart';

part 'patrol_test_config.freezed.dart';

/// Common configuration for [PatrolTester] and [PatrolFinder].
@freezed
class PatrolTestConfig with _$PatrolTestConfig {
  /// Creates a new [PatrolTestConfig].
  const factory PatrolTestConfig({
    /// Time after which [PatrolFinder.waitUntilExists] fails if it doesn't
    /// finds a widget.
    @Default(Duration(seconds: 10)) Duration existsTimeout,

    /// Time after which [PatrolFinder.waitUntilVisible] fails if it doesn't
    /// finds a widget.
    ///
    /// [PatrolFinder.waitUntilVisible] is used internally by [PatrolFinder.tap]
    /// and [PatrolFinder.enterText].
    @Default(Duration(seconds: 10)) Duration visibleTimeout,

    /// Time after which [PatrolTester.pumpAndSettle] fails.
    @Default(Duration(seconds: 10)) Duration settleTimeout,

    /// Whether to call [WidgetTester.pumpAndSettle] after actions such as
    /// [PatrolFinder.tap] and [PatrolFinder]. If false, only
    /// [WidgetTester.pump] is called.
    @Default(true) bool andSettle,

    /// Name of the application under test.
    ///
    /// Used in [PatrolTester.log].
    String? appName,

    /// Package name of the application under test.
    ///
    /// Android only.
    String? packageName,

    /// Bundle identifier name of the application under test.
    ///
    /// iOS only.
    String? bundleId,
  }) = _PatrolTestConfig;
}
