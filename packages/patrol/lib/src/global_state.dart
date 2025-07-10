// This file wraps the Invoker API, which is internal to package:test.
// ignore: implementation_imports
import 'package:test_api/src/backend/invoker.dart';

/// We need [Test] to check test hierarchy.
// ignore: implementation_imports
import 'package:test_api/src/backend/test.dart';

/// Maximum test case length for ATO, after transformations.
///
/// See https://github.com/leancodepl/patrol/issues/1725
const maxTestLength = 190;

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

/// Returns the individual name of the current test. Omits all ancestor groups.
String get currentTestIndividualName {
  return Invoker.current!.liveTest.individualName;
}

/// Returns whether the current test is passing.
bool get isCurrentTestPassing {
  return Invoker.current!.liveTest.state.result.isPassing;
}

/// Returns whether the current test is the last test in its immediate group.
bool get isCurrentTestLastInGroup {
  final invoker = Invoker.current!;
  final currentTest = invoker.liveTest;

  print('=== DEBUG isCurrentTestLastInGroup ===');
  print('Current test name: ${currentTest.individualName}');
  print('Groups count: ${currentTest.groups.length}');

  for (int i = 0; i < currentTest.groups.length; i++) {
    print('Group $i: ${currentTest.groups[i].name}');
  }

  // Get the immediate parent group
  final parentGroup =
      currentTest.groups.isNotEmpty ? currentTest.groups.last : null;

  if (parentGroup == null) {
    print('No parent group found - returning true');
    return true;
  }

  print('Parent group name: ${parentGroup.name}');
  print('Parent group entries count: ${parentGroup.entries.length}');

  // Get all tests in the parent group (excluding nested groups)
  final testsInGroup = <String>[];
  for (final entry in parentGroup.entries) {
    print('Entry: ${entry.name}, type: ${entry.runtimeType}');
    if (entry is Test && entry.name != 'patrol_test_explorer') {
      // Extract individual test name by removing the group prefix
      final fullName = entry.name;
      final groupPrefix = '${parentGroup.name} ';
      final individualTestName = fullName.startsWith(groupPrefix)
          ? fullName.substring(groupPrefix.length)
          : fullName;
      testsInGroup.add(individualTestName);
      print('Added test: $fullName -> individual: $individualTestName');
    }
  }

  print('Tests in group: $testsInGroup');

  // Check if current test is the last one in the list
  if (testsInGroup.isEmpty) {
    print('No tests in group - returning true');
    return true;
  }

  final currentTestName = currentTest.individualName;
  final lastTestName = testsInGroup.last;

  print('Current test: $currentTestName');
  print('Last test in group: $lastTestName');
  print('Is last: ${currentTestName == lastTestName}');
  print('=== END DEBUG ===');

  return currentTestName == lastTestName;
}
