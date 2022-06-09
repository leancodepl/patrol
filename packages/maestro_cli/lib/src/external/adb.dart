import 'dart:async';

import 'package:adb/adb.dart' as adb;
import 'package:maestro_cli/src/common/common.dart';

Future<void> installApps({String? device}) async {
  final progress1 = log.progress('Installing server');
  try {
    await adb.forceInstallApk(serverArtifactFile, device: device);
  } catch (err) {
    progress1.fail('Failed to install server');
    rethrow;
  }
  progress1.complete('Installed server');

  final progress2 = log.progress('Installing instrumentation');
  try {
    await adb.forceInstallApk(instrumentationArtifactFile, device: device);
  } catch (err) {
    progress2.fail('Failed to install instrumentation');
    rethrow;
  }

  progress2.complete('Installed instrumentation');
}

Future<void> forwardPorts(int port, {String? device}) async {
  final progress = log.progress('Forwarding ports');

  try {
    await adb.forwardPorts(
      fromHost: port,
      toDevice: port,
      device: device,
    );
  } catch (err) {
    progress.fail('Failed to forward ports');
    rethrow;
  }

  progress.complete('Forwarded ports');
}

Future<void> runServer({String? device}) async {
  final progress = log.progress('Starting instrumentation server');

  try {
    await adb.instrument(
      packageName: 'pl.leancode.automatorserver.test',
      intentClass: 'androidx.test.runner.AndroidJUnitRunner',
      onStdout: log.info,
      onStderr: log.severe,
    );
  } catch (err) {
    progress.fail('Failed to start instrumentation server');
    rethrow;
  }

  progress.complete('Started instrumentation server');
}
