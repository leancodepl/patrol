import 'dart:async';
import 'dart:io' show Process, ProcessSignal;

import 'package:patrol_cli/src/base/logger.dart';

/// Stops a `flutter run` [process] that Patrol started itself (web and Linux
/// develop).
///
/// Sends `q`, so `flutter run` stops what it started: the app, and on web
/// also Chrome, which a hard kill orphans on macOS. If [process] doesn't exit
/// within [timeout], it gets SIGKILL.
Future<void> stopFlutterRun(
  Process process, {
  required Logger logger,
  Duration timeout = const Duration(seconds: 10),
}) async {
  try {
    process.stdin.add('q'.codeUnits);
    await process.stdin.flush();
  } on Object catch (err) {
    logger.detail('Failed to send quit to Flutter: $err');
  }

  try {
    await process.exitCode.timeout(timeout);
  } on TimeoutException {
    logger.detail(
      'Graceful shutdown timed out, force killing Flutter process...',
    );
    process.kill(ProcessSignal.sigkill);
    await process.exitCode;
  }
}
