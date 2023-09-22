import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/src/extensions.dart';
// ignore: depend_on_referenced_packages
import 'package:test_api/src/backend/invoker.dart';

const String requestedTest = 'groupA testA';

String get currentTest => Invoker.current!.fullCurrentTestName();

// Idea for setUpAll and tearDownAll implementation:
//
// Let these callbacks run always, i.e. in a normal way (just like we do with
// setUp and tearDown). But after the callback runs for a first time, send its
// stable unique identifier to the native side. Then, if the callback tries to
// run again, in a new app process, it'll ask the native side if it should
// execute, and the native side will reply "no",

void main() {
  patrolSetUp(() {
    print('setting up 1 before $currentTest');
  });

  group('groupA', () {
    patrolSetUpAll(() {
      final group = Invoker.current!.liveTest.groups.last.name;
      print('setting up all before $currentTest, ID="$group 1"');
    });

    patrolSetUp(() {
      print('setting up 2 before $currentTest');
    });

    patrolTest('testA', _body);
    patrolTest('testB', _body);
    patrolTest('testC', _body);

    patrolTearDown(() {
      print('tearing down 1 after $currentTest');
    });
  });

  patrolTearDown(() {
    print('tearing down 2 after $currentTest');
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

void patrolSetUp(dynamic Function() body) {
  setUp(() {
    final currentTest = Invoker.current!.fullCurrentTestName();

    // TODO: Determine if requestedTest is inside this setUps scope?
    // Hipothesis: package:test cares about this automatically!
    if (currentTest == requestedTest) {
      body();
    }
  });
}

void patrolTearDown(dynamic Function() body) {
  tearDown(() {
    final currentTest = Invoker.current!.fullCurrentTestName();

    if (currentTest == requestedTest) {
      body();
    }
  });
}
