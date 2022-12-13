import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

export 'package:example/main.dart';
export 'package:flutter_test/flutter_test.dart';
export 'package:patrol/patrol.dart';

void patrol(
  String description,
  Future<void> Function(PatrolTester) callback,
) {
  patrolTest(
    description,
    nativeAutomatorConfig: nativeAutomatorConfig,
    nativeAutomation: true,
    ($) async {
      addTearDown(() async {
        debugPrint("Taking screenshot for test '$description'");
        // await $.host.takeScreenshot(name: 'TEARDOWN_$description');
      });
      await callback($);
    },
  );
}

final patrolTesterConfig = PatrolTesterConfig();

final nativeAutomatorConfig = NativeAutomatorConfig(
  packageName: 'pl.leancode.patrol.example',
  bundleId: 'pl.leancode.patrol.Example',
);

const hostAutomatorConfig = HostAutomatorConfig();
