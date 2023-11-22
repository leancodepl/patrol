import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
// ignore: implementation_imports
import 'package:test_api/src/backend/invoker.dart';

/// Maximum test case length for ATO, after transformations.
///
/// See https://github.com/leancodepl/patrol/issues/1725
const maxTestLength = 190;

/// Whether Hot Restart is enabled.
@internal
const bool hotRestartEnabled = bool.fromEnvironment('PATROL_HOT_RESTART');

/// This file wraps the [Invoker] API, which is internal to package:test. We
/// want to minimize the usage of internal APIs to a minimum.

/// Returns the full name of the current test (names of all ancestor groups +
/// name of the current test).
String get currentTestFullName {
  final invoker = Invoker.current!;

  final parentGroupName = invoker.liveTest.groups.last.name;
  final testName = invoker.liveTest.individualName;

  var nameCandidate = '$parentGroupName $testName';
  if (nameCandidate.length > 190) {
    nameCandidate = nameCandidate.substring(0, 190);
  }
  return nameCandidate;
}

/// Returns the name of the current group.
///
/// Includes all ancestor groups.
String get currentGroupFullName {
  return Invoker.current!.liveTest.groups.last.name;
}

/// Returns the individual name of the current test.
///
/// Omits all ancestor groups.
String get currentTestIndividualName {
  return Invoker.current!.liveTest.individualName;
}

/// Returns whether the current test is passing.
bool get isCurrentTestPassing {
  return Invoker.current!.liveTest.state.result.isPassing;
}

const _channel = MethodChannel('pl.leancode.patrol/main');

/// Returns whether this is the first run of the app under test during which
/// test discovery happens.
Future<bool> get isInitialRun async {
  return await _channel.invokeMethod('isInitialRun') as bool;
}
