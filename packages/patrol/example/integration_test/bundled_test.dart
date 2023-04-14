import 'package:flutter_test/flutter_test.dart';
import 'package:test_api/src/backend/group.dart';
import 'package:test_api/src/backend/group_entry.dart';
import 'package:test_api/src/backend/invoker.dart';
import 'package:test_api/src/backend/test.dart';

import 'common.dart';
import 'example_test.dart' as example_test;
import 'notifications_test.dart' as notifications_test;
import 'permissions_many_test.dart' as permissions_many_test;

// class PatrolTestGroup {
//   final List<PatrolTestGroup> groups;
// }

// class PatrolTestCase {
//   final String name;

//   const PatrolTestCase(this.name);
// }

Future<void> main() async {
  // Run a single, special test to expore the hierarchy of groups and tests
  test('patrol_test_explorer', () {
    final topLevelGroup = Invoker.current!.liveTest.groups.first;
    _printTestEntry(topLevelGroup);

    // Create a one-off NativeAutomator to seed the native side with the Dart
    // test suite hierarchy.

    final automator = NativeAutomator(config: NativeAutomatorConfig());
    automator.setDartTests();
  });

  group('app_test.dart', example_test.main);

  group('permissions_many_test.dart', permissions_many_test.main);

  group('notifications_test.dart', notifications_test.main);
}

/// Prints test entry.
///
/// If [entry] is a group, then it's recursively printed as well.
void _printTestEntry(GroupEntry entry, {int level = 0}) {
  final padding = '  ' * level;
  if (entry is Group) {
    print('$padding Group: ${entry.name}');
    for (final groupEntry in entry.entries) {
      _printTestEntry(groupEntry, level: level + 1);
    }
  } else if (entry is Test) {
    if (entry.name == 'patrol_test_explorer') {
      return;
    }

    print('$padding Test: ${entry.name}');
  }
}
