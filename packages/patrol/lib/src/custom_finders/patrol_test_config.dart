import 'package:flutter_test/flutter_test.dart';

import 'patrol_finder.dart';
import 'patrol_tester.dart';

/// Common configuration for [PatrolTester] and [PatrolFinder].
class PatrolTestConfig {
  /// Creates a new [PatrolTestConfig].
  const PatrolTestConfig({
    this.existsTimeout = const Duration(seconds: 10),
    this.visibleTimeout = const Duration(seconds: 10),
    this.settleTimeout = const Duration(seconds: 10),
    this.andSettle = true,
    this.appName,
    this.packageName,
    this.bundleId,
  });

  /// Time after which [PatrolFinder.waitUntilExists] fails if it doesn't finds
  /// a widget.
  final Duration existsTimeout;

  /// Time after which [PatrolFinder.waitUntilVisible] fails if it doesn't finds
  /// a widget.
  ///
  /// [PatrolFinder.waitUntilVisible] is used internally by [PatrolFinder.tap]
  /// and [PatrolFinder.enterText].
  ///
  final Duration visibleTimeout;

  /// Time after which [PatrolTester.pumpAndSettle] fails.
  final Duration settleTimeout;

  /// Whether to call [WidgetTester.pumpAndSettle] after actions such as
  /// [PatrolFinder.tap] and [PatrolFinder]. If false, only [WidgetTester.pump]
  /// is called.
  final bool andSettle;

  /// Name of the application under test.
  ///
  /// Used in [PatrolTester.log].
  final String? appName;

  /// Package name of the application under test.
  ///
  /// Android only.
  final String? packageName;

  /// Bundle identifier name of the application under test.
  ///
  /// iOS only.
  final String? bundleId;

  /// Creates a copy of this config but with the given fields replaced with
  /// the new values.
  PatrolTestConfig copyWith({
    Duration? existsTimeout,
    Duration? visibleTimeout,
    Duration? settleTimeout,
    bool? andSettle,
    String? appName,
    String? packageName,
    String? bundleId,
  }) {
    return PatrolTestConfig(
      existsTimeout: existsTimeout ?? this.existsTimeout,
      visibleTimeout: visibleTimeout ?? this.visibleTimeout,
      settleTimeout: settleTimeout ?? this.settleTimeout,
      andSettle: andSettle ?? this.andSettle,
      appName: appName ?? this.appName,
      packageName: packageName ?? this.packageName,
      bundleId: bundleId ?? this.bundleId,
    );
  }
}
