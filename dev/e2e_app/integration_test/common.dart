import 'package:e2e_app/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

export 'package:flutter_test/flutter_test.dart';
export 'package:patrol/patrol.dart';

final _patrolTesterConfig = PatrolTesterConfig(printLogs: true);
final _nativeAutomatorConfig = NativeAutomatorConfig(
  findTimeout: Duration(seconds: 20), // 10 seconds is too short for some CIs
);

Future<void> createApp(PatrolIntegrationTester $) async {
  await setUpTimezone();
  await $.pumpWidgetAndSettle(const ExampleApp());
}

void patrol(
  String description,
  Future<void> Function(PatrolIntegrationTester) callback, {
  bool? skip,
  List<String> tags = const [],
  NativeAutomatorConfig? nativeAutomatorConfig,
  LiveTestWidgetsFlutterBindingFramePolicy framePolicy =
      LiveTestWidgetsFlutterBindingFramePolicy.fadePointers,
}) {
  patrolTest(
    description,
    config: _patrolTesterConfig,
    nativeAutomatorConfig: nativeAutomatorConfig ?? _nativeAutomatorConfig,
    framePolicy: framePolicy,
    skip: skip,
    callback,
    tags: tags,
  );
}
