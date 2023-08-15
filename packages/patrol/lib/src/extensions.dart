import 'package:meta/meta.dart';
// ignore: implementation_imports
import 'package:test_api/src/backend/invoker.dart';

/// Provides convenience methods for [Invoker].
@internal
extension InvokerX on Invoker {
  /// Returns the full name of the current test (names of all ancestor groups +
  /// name of the current test).
  String fullCurrentTestName() {
    final parentGroupName = liveTest.groups.last.name;
    final testName = liveTest.individualName;

    return '$parentGroupName $testName';
  }
}
