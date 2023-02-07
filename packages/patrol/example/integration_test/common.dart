import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

export 'package:example/main.dart';
export 'package:flutter_test/flutter_test.dart';
export 'package:patrol/patrol.dart';

final _patrolTesterConfig = PatrolTesterConfig();
final _nativeAutomatorConfig = NativeAutomatorConfig();

void patrol(
  String description,
  Future<void> Function(PatrolTester) callback,
) {
  patrolTest(
    description,
    config: _patrolTesterConfig,
    nativeAutomatorConfig: _nativeAutomatorConfig,
    nativeAutomation: true,
    callback,
  );
}
