import 'package:patrol/patrol.dart';

const patrolConfig = PatrolTesterConfig(appName: 'Example App');

final nativeAutomatorConfig = NativeAutomatorConfig(
  packageName: 'pl.leancode.patrol.example',
  bundleId: 'pl.leancode.patrol.Example',
);

const hostAutomatorConfig = HostAutomatorConfig();
