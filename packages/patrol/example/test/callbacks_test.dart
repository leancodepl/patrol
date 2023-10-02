import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/src/extensions.dart';
// ignore: depend_on_referenced_packages
import 'package:test_api/src/backend/invoker.dart';

const String requestedTest = 'testA';

String get currentTest => Invoker.current!.fullCurrentTestName();

void main() {
  group('alpha', () {
    setUpAll(() {
      final groupName = Invoker.current!.liveTest.groups.last.name;
      final individualName = Invoker.current!.liveTest.individualName;
      print(
        'setUpAll: parentGroupName=$groupName, individualName=$individualName',
      );
    });

    setUp(() {
      final groupName = Invoker.current!.liveTest.groups.last.name;
      final individualName = Invoker.current!.liveTest.individualName;
      print(
        'setUpAll: parentGroupName=$groupName, individualName=$individualName',
      );
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
