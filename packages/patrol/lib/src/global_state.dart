// ignore: implementation_imports
import 'package:test_api/src/backend/invoker.dart';

/// This file wraps the [Invoker] API, which is internal to package:test. We
/// want to minimize the usage of internal APIs to a minimum.

/// Returns the full name of the current test (names of all ancestor groups +
/// name of the current test).
String get currentTestFullName {
  final invoker = Invoker.current!;

  final parentGroupName = invoker.liveTest.groups.last.name;
  final testName = invoker.liveTest.individualName;

  return '$parentGroupName $testName';
}

/// Returns the individual name of the current test. Omits all ancestor groups.
String get currentTestIndividualName {
  return Invoker.current!.liveTest.individualName;
}

/// Returns whether the current test is passing.
bool get isCurrentTestPassing {
  return Invoker.current!.liveTest.state.result.isPassing;
}
