import 'dart:io' as io;

import 'package:adb/src/exceptions.dart';
import 'package:adb/src/extensions.dart';

const _interval = Duration(milliseconds: 100);

/// This class makes it easy to swap out the implementation of the some ADB
/// commands.
class AdbInternals {
  /// Creates a new [AdbInternals] instance.
  const AdbInternals();

  /// Calls `adb devices` and returns its stdout.
  Future<String> devices() async {
    final result = await io.Process.run(
      'adb',
      ['devices'],
      runInShell: true,
    );

    if (result.stdErr.isNotEmpty) {
      if (result.stdErr.contains(AdbDaemonNotRunning.trigger)) {
        throw AdbDaemonNotRunning(message: result.stdErr);
      }

      throw Exception(result.stdErr);
    }

    return result.stdOut;
  }

  /// Ensures that the ADB server is running.
  Future<void> ensureServerRunning() async {
    try {
      await io.Process.run('adb', []);
    } on io.ProcessException catch (err) {
      throw AdbExecutableNotFound(message: err.message);
    }
    while (true) {
      final result = await io.Process.run(
        'adb',
        ['start-server'],
        runInShell: true,
      );
      if (result.stdErr.contains(AdbDaemonNotRunning.trigger)) {
        await Future<void>.delayed(_interval);
      } else {
        break;
      }
    }
  }

  /// Ensures that the `activity` service is running on the device.
  Future<void> ensureActivityServiceRunning({required String? device}) async {
    while (true) {
      final result = await io.Process.run(
        'adb',
        [
          if (device != null) ...['-s', device],
          'shell',
          'service',
          'list',
        ],
        runInShell: true,
      );

      const trigger = 'activity: [android.app.IActivityManager]';
      if (result.stdOut.contains(trigger)) {
        break;
      } else {
        await Future<void>.delayed(_interval);
      }
    }
  }

  /// Ensures that the `package` service is running on the device.
  Future<void> ensurePackageServiceRunning({required String? device}) async {
    while (true) {
      final result = await io.Process.run(
        'adb',
        [
          if (device != null) ...['-s', device],
          'shell',
          'service',
          'list',
        ],
        runInShell: true,
      );

      const trigger = 'package: [android.content.pm.IPackageManager]';
      if (result.stdOut.contains(trigger)) {
        break;
      } else {
        await Future<void>.delayed(_interval);
      }
    }
  }
}
