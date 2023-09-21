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

    patrolTearDown(() {
      print('tearing down after $currentTest');
    });

    patrolTest('testA', _body);
    patrolTest('testB', _body);
    patrolTest('testC', _body);
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
