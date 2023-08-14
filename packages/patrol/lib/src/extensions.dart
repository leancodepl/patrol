// ignore: implementation_imports
import 'package:test_api/src/backend/invoker.dart';

extension InvokerX on Invoker {
  String fullCurrentTestName() {
    final parentGroupName = liveTest.groups.last.name;
    final testName = liveTest.individualName;

    return '$parentGroupName $testName';
  }
}
