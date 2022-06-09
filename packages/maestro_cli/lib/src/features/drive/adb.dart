import 'dart:async';

import 'package:adb/adb.dart' as adb;
import 'package:maestro_cli/src/common/common.dart';
import 'package:path/path.dart' as path;

Future<void> installApps({String? device}) async {
  final serverInstallProgress = log.progress('Installing server');
  try {
    final p = path.join(artifactPath, serverArtifactFile);
    await adb.forceInstallApk(p, device: device);
  } catch (err) {
    serverInstallProgress.fail('Failed to install server');
    rethrow;
  }
  serverInstallProgress.complete('Installed server');

  final instrumentInstallProgress = log.progress('Installing instrumentation');
  try {
    final p = path.join(artifactPath, instrumentationArtifactFile);
    await adb.forceInstallApk(p, device: device);
  } catch (err) {
    instrumentInstallProgress.fail('Failed to install instrumentation');
    rethrow;
  }

  instrumentInstallProgress.complete('Installed instrumentation');
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
    unawaited(
      adb.instrument(
        packageName: 'pl.leancode.automatorserver.test',
        intentClass: 'androidx.test.runner.AndroidJUnitRunner',
        onStdout: log.info,
        onStderr: log.severe,
      ),
    );
  } catch (err) {
    progress.fail('Failed to start instrumentation server');
    rethrow;
  }

  progress.complete('Started instrumentation server');
}
