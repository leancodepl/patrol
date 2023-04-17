// ignore_for_file: invalid_use_of_internal_member, depend_on_referenced_packages

import 'package:patrol/src/native/contracts/contracts.pbgrpc.dart';
import 'package:test_api/src/backend/group.dart';
import 'package:test_api/src/backend/group_entry.dart';
import 'package:test_api/src/backend/invoker.dart';
import 'package:test_api/src/backend/test.dart';

import 'common.dart';
import 'example_test.dart' as example_test;
import 'permissions/permissions_location_test.dart'
    as permissions_location_test;
import 'permissions/permissions_many_test.dart' as permissions_many_test;
import 'sign_in/sign_in_facebook_test.dart' as sign_in_facebook_test;
import 'sign_in/sign_in_google_test.dart' as sign_in_google_test;

Future<void> main() async {
  // Run a single, special test to expore the hierarchy of groups and tests
  test('patrol_test_explorer', () {
    final topLevelGroup = Invoker.current!.liveTest.groups.first;
    _printGroupEntry(topLevelGroup);

    final dartTestGroup = _createDartTestGroup(topLevelGroup);

    // Create a one-off NativeAutomator to seed the native side with the Dart
    // test suite hierarchy.
    NativeAutomator(config: NativeAutomatorConfig())
        .setDartTests(dartTestGroup);
  });

  group('permissions', () {
    group('permissions_location_test.dart', permissions_location_test.main);

    group('permissions_many_test.dart', permissions_many_test.main);
  });

  group('sign_in', () {
    group('sign_in_facebook_test.dart', sign_in_facebook_test.main);
    group('sign_in_google_test.dart', sign_in_google_test.main);
  });

  group('app_test.dart', example_test.main);
}

/// Prints test entry.
///
/// If [entry] is a group, then it's recursively printed as well.
void _printGroupEntry(GroupEntry entry, {int level = 0}) {
  final padding = '  ' * level;
  if (entry is Group) {
    print('$padding Group: ${entry.name}');
    for (final groupEntry in entry.entries) {
      _printGroupEntry(groupEntry, level: level + 1);
    }
  } else if (entry is Test) {
    if (entry.name == 'patrol_test_explorer') {
      return;
    }

    print('$padding Test: ${entry.name}');
  }
}

/// Creates a DartTestGroup by recursively visiting subgroups of [topLevelGroup]
/// and tests these groups contain.
DartTestGroup _createDartTestGroup(Group topLevelGroup) {
  final group = DartTestGroup();

  for (final groupEntry in topLevelGroup.entries) {
    if (groupEntry is Group) {
      final subgroup = _createDartTestGroup(groupEntry);
      group.groups.add(subgroup);
    } else if (groupEntry is Test) {
      if (groupEntry.name == 'patrol_test_explorer') {
        continue;
      }

      final dartTest = DartTestCase();
      dartTest.name = groupEntry.name;
      group.tests.add(dartTest);
    }
  }

  return group;
}
