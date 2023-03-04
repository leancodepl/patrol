import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

export 'package:example/main.dart';
export 'package:flutter_test/flutter_test.dart';
export 'package:patrol/patrol.dart';

final globalPatrolTesterConfig = PatrolTesterConfig();
final globalNativeAutomatorConfig = NativeAutomatorConfig(
  findTimeout: Duration(seconds: 30), // Simulator on GitHub Actions is so slow
);

Future<void> createApp(PatrolTester $) async {
  await setUpTimezone();
  await $.pumpWidget(ExampleApp());
}

void patrol(
  String description,
  Future<void> Function(PatrolTester) callback, {
  PatrolTesterConfig? patrolTesterConfig,
  NativeAutomatorConfig? nativeAutomatorConfig,
  bool? skip,
}) {
  patrolTest(
    description,
    config: patrolTesterConfig ?? globalPatrolTesterConfig,
    nativeAutomatorConfig: nativeAutomatorConfig ?? globalNativeAutomatorConfig,
    nativeAutomation: true,
    skip: skip,
    callback,
  );
}
