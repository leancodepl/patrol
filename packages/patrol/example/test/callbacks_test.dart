import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/src/extensions.dart';
// ignore: depend_on_referenced_packages
import 'package:test_api/src/backend/invoker.dart';

// Input:
const String requestedTest = 'testA';

// Global state:

String get currentTest => Invoker.current!.fullCurrentTestName();

/// A list holding IDs of all setUpAll callbacks.
///
/// This is basically the list of groupNames + an index appended.
List<String> setUpAlls = [];

/// Adds a setUpAll callback to the list of all setUpAll callbacks.
///
/// Returns the name under which this setUpAll callback was added.
String addSetUpAll(String group) {
  // Not optimal, but good enough for now.

  // Go over all groups, checking if the group is already in the list.
  var groupIndex = 0;
  for (final setUpAll in setUpAlls) {
    final parts = setUpAll.split(' ');
    final groupName = parts.sublist(0, parts.length - 1).join(' ');

    print('Checking if $groupName is in the list');

    if (groupName == group) {
      groupIndex++;
    }
  }

  final name = '$group $groupIndex';

  setUpAlls.add(name);
  return name;
}

void printSetUpAlls() {
  print('setUpAlls:');
  for (final setUpAll in setUpAlls) {
    print('  $setUpAll');
  }
}

void main() {
  group('A', () {
    customSetUpAll(() async {});

    customSetUpAll(() async {});

    group('B', () {
      customSetUpAll(() async {});
      customSetUpAll(() async {});
      customSetUpAll(() async {});
      customSetUpAll(() async {});

      group('C', () {
        customSetUpAll(() async {});
        customSetUpAll(() async {});
      });
    });

    patrolTest('testA', _body);
    patrolTest('testB', _body);
    patrolTest('testC', _body);
  });

  tearDownAll(() {
    print('Reporting status!');
    printSetUpAlls();
  });
}

Future<void> _body() async => print(Invoker.current!.fullCurrentTestName());

void patrolTest(String name, Future<void> Function() body) {
  test(name, () async {
    final currentTest = Invoker.current!.fullCurrentTestName();

    if (currentTest == requestedTest) {
      print('Requested test $currentTest, will execute it');
      await body();
    }
  });
}

/// A modification of [setUpAll] that works with Patrol's native automation.
///
/// Its main purpose is to keep track of calls made to setUpAll.
///
/// groupA
///  - setUpAll
///  - setUpAll
///  - groupB
///   - setUpAll
void customSetUpAll(Future<void> Function() body) {
  setUpAll(() async {
    final parentGroupsName = Invoker.current!.liveTest.groups.last.name;

    final name = addSetUpAll(parentGroupsName);

    // if (!isInTestDiscoveryPhase) {
    //   return;
    // }

    // if (patrolAppService.wasSetUpAllExecuted()) {}

    // final requestedToExecute = await PatrolBinding.instance.patrolAppService
    //     .waitForExecutionRequest(currentSetUpAllIndex);

    // if (requestedToExecute) {
    //   await body();
    // }
  });
}
