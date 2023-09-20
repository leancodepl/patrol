import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/src/extensions.dart';
// ignore: depend_on_referenced_packages
import 'package:test_api/src/backend/invoker.dart';

const String requestedTest = 'groupA testA';

String get currentTest => Invoker.current!.fullCurrentTestName();

void main() {
  patrolSetUp(() {
    print('setting up before $currentTest');
  });

  patrolTearDown(() {
    print('tearing down after $currentTest');
  });

  group('groupA', () {
    patrolSetUp(() {
      print('setting up before $currentTest');
    });

    tearDown(() {
      print('tearing down after $currentTest');
    });

    test('testA', _body);
    test('testB', _body);
    test('testC', _body);
  });
}

void _body() => print(Invoker.current!.fullCurrentTestName());

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
