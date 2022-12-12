import 'package:flutter_test/flutter_test.dart';
import 'package:patrol_next/patrol.dart';

export 'package:example/main.dart';
export 'package:flutter_test/flutter_test.dart';
export 'package:patrol_next/patrol.dart';

void patrol(
  String description,
  Future<void> Function(PatrolTester) callback,
) {
  patrolTest(
    description,
    config: patrolTesterConfig,
    nativeAutomatorConfig: nativeAutomatorConfig,
    nativeAutomation: true,
    ($) async {
      //  TODO: Not implemented in Patrol Next
      // addTearDown(() async {
      //   await $.host.takeScreenshot(name: 'TEARDOWN_$description');
      // });
      await callback($);
    },
  );
}

const patrolTesterConfig = PatrolTesterConfig(appName: 'Example App');

final nativeAutomatorConfig = NativeAutomatorConfig(
  packageName: 'pl.leancode.patrol_next.example',
  bundleId: 'pl.leancode.patrol_next.Example',
);

const hostAutomatorConfig = HostAutomatorConfig();
