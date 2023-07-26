import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

export 'package:example/main.dart';
export 'package:flutter_test/flutter_test.dart';
export 'package:patrol/patrol.dart';

final _patrolTesterConfig = PatrolTesterConfig();
final _nativeAutomatorConfig = NativeAutomatorConfig(
  findTimeout: Duration(seconds: 20), // 10 seconds is too short for some CIs
);

Future<void> createApp(PatrolTester $) async {
  await setUpTimezone();
  await $.pumpWidget(ExampleApp());
}

void patrol(
  String description,
  NativePatrolTesterCallback callback, {
  bool? skip,
  NativeAutomatorConfig? nativeAutomatorConfig,
}) {
  patrolIntegrationTest(
    description,
    config: _patrolTesterConfig,
    nativeAutomatorConfig: nativeAutomatorConfig ?? _nativeAutomatorConfig,
    skip: skip,
    callback,
  );
}
