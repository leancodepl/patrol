import 'package:e2e_app/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';
import 'package:patrol/patrol.dart';

export 'package:flutter_test/flutter_test.dart';
export 'package:patrol/patrol.dart';

final _patrolTesterConfig = PatrolTesterConfig(printLogs: true);

Future<void> createApp(PatrolIntegrationTester $) async {
  await setUpTimezone();
  await $.pumpWidgetAndSettle(const ExampleApp());
}

@isTest
void patrol(
  String description,
  Future<void> Function(PatrolIntegrationTester) callback, {
  bool? skip,
  List<String> tags = const [],
}) {
  patrolTest(
    description,
    config: _patrolTesterConfig,
    skip: skip,
    callback,
    tags: tags,
  );
}
