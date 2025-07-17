// This file wraps the Invoker API, which is internal to package:test.
// ignore: implementation_imports

// Ignoring this because causes conflicts between linter and analyzer
// ignore: dangling_library_doc_comments
/// We need [Group] to check test hierarchy.
// ignore: implementation_imports
import 'package:test_api/src/backend/group.dart';

/// We need [Invoker] to get the current test.
// ignore: implementation_imports
import 'package:test_api/src/backend/invoker.dart';

/// We need [LiveTest] to check test hierarchy.
// ignore: implementation_imports
import 'package:test_api/src/backend/live_test.dart';

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

  // If no groups, check if this test is the last entry at root level
  if (currentTest.groups.isEmpty) {
    return _isLastTestAtRootLevel(currentTest);
  }

  // Check if current test is last in the entire hierarchy
  return _isLastInHierarchy(currentTest);
}

/// Checks if a root-level test is the last entry in the entire test file
bool _isLastTestAtRootLevel(LiveTest currentTest) {
  try {
    // A root-level test should generally not stop the execution
    // unless there's evidence it's truly the last test
    // This is a conservative approach
    return false;
  } catch (err) {
    return false;
  }
}

/// Recursively checks if the current test is the last entry in the hierarchy
bool _isLastInHierarchy(LiveTest currentTest) {
  // Start from the most immediate group (last in the groups list)
  for (var groupIndex = currentTest.groups.length - 1;
      groupIndex >= 0;
      groupIndex--) {
    final currentGroup = currentTest.groups[groupIndex];

    if (groupIndex == currentTest.groups.length - 1) {
      // This is the immediate parent group - check if current test is last test
      if (!_isLastTestInGroup(currentTest, currentGroup)) {
        return false;
      }
    } else {
      // This is a higher-level group - check if the child group is last entry
      final childGroup = currentTest.groups[groupIndex + 1];
      if (!_isLastEntryInGroup(childGroup, currentGroup)) {
        return false;
      }
    }
  }

  // If we get here, the test is last at every level of the hierarchy

  return true;
}

/// Checks if the current test is the last test in the given group
bool _isLastTestInGroup(LiveTest currentTest, Group group) {
  final allEntriesInGroup = <String>[];

  // Get ALL entries (both tests and groups) in the group
  for (final entry in group.entries) {
    if (entry.name != 'patrol_test_explorer') {
      // Extract individual entry name by removing the group prefix
      final fullName = entry.name;
      final groupPrefix = '${group.name} ';
      final individualEntryName = fullName.startsWith(groupPrefix)
          ? fullName.substring(groupPrefix.length)
          : fullName;
      allEntriesInGroup.add(individualEntryName);
    }
  }

  if (allEntriesInGroup.isEmpty) {
    return false;
  }

  final currentTestName = currentTest.individualName;
  final lastEntryName = allEntriesInGroup.last;

  // The current test is last only if it's the very last entry (not just last test)
  final isLast = currentTestName == lastEntryName;

  return isLast;
}

/// Checks if the given entry (group or test) is the last entry in the parent group
bool _isLastEntryInGroup(Group entry, Group parentGroup) {
  final entriesInGroup = <String>[];

  // Get all entries (both tests and groups) in the parent group
  for (final parentEntry in parentGroup.entries) {
    if (parentEntry.name != 'patrol_test_explorer') {
      // For entries, we need to extract the name relative to the parent group
      final fullName = parentEntry.name;
      final parentPrefix = '${parentGroup.name} ';
      final relativeName = fullName.startsWith(parentPrefix)
          ? fullName.substring(parentPrefix.length)
          : fullName;
      entriesInGroup.add(relativeName);
    }
  }

  if (entriesInGroup.isEmpty) {
    return false;
  }

  // Get the relative name of our entry
  final entryFullName = entry.name;
  final parentPrefix = '${parentGroup.name} ';
  final entryRelativeName = entryFullName.startsWith(parentPrefix)
      ? entryFullName.substring(parentPrefix.length)
      : entryFullName;

  final lastEntryName = entriesInGroup.last;

  return entryRelativeName == lastEntryName;
}
