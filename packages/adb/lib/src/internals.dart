import 'dart:io' as io;

import 'exceptions.dart';
import 'extensions.dart';

const _interval = Duration(milliseconds: 100);

/// Calls [isReady], pausing [interval] between calls, until it returns true.
/// Throws [AdbTimeout] naming [what] once [timeout] has passed, including while
/// a call is still pending; a check that succeeds after that does not count.
Future<void> waitUntilReady(
  String what,
  Future<bool> Function() isReady, {
  required Duration timeout,
  Duration interval = _interval,
}) async {
  final stopwatch = Stopwatch()..start();
  while (true) {
    final remaining = timeout - stopwatch.elapsed;
    final ready =
        remaining > Duration.zero &&
        await isReady().timeout(remaining, onTimeout: () => false);
    if (ready && stopwatch.elapsed <= timeout) {
      return;
    }
    if (stopwatch.elapsed >= timeout) {
      throw AdbTimeout(
        message: '$what was not ready after ${timeout.inMilliseconds} ms',
      );
    }
    await Future<void>.delayed(interval);
  }
}

/// This class makes it easy to swap out the implementation of the some ADB
/// commands.
class AdbInternals {
  /// Creates a new [AdbInternals] instance.
  const AdbInternals({this.readyTimeout = const Duration(minutes: 2)});

  /// How long to wait for the ADB server or a device service before throwing
  /// [AdbTimeout].
  final Duration readyTimeout;

  /// Calls `adb devices` and returns its stdout.
  Future<String> devices() async {
    final result = await io.Process.run('adb', ['devices'], runInShell: true);

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
    await waitUntilReady('The ADB server', () async {
      final result = await io.Process.run('adb', [
        'start-server',
      ], runInShell: true);
      return !result.stdErr.contains(AdbDaemonNotRunning.trigger);
    }, timeout: readyTimeout);
  }

  /// Ensures that the `activity` service is running on the device.
  Future<void> ensureActivityServiceRunning({required String? device}) =>
      _waitForService(
        'activity: [android.app.IActivityManager]',
        name: 'activity',
        device: device,
      );

  /// Ensures that the `package` service is running on the device.
  Future<void> ensurePackageServiceRunning({required String? device}) =>
      _waitForService(
        'package: [android.content.pm.IPackageManager]',
        name: 'package',
        device: device,
      );

  Future<void> _waitForService(
    String trigger, {
    required String name,
    required String? device,
  }) => waitUntilReady(
    'The $name service on ${device ?? 'the device'}',
    () async {
      final result = await io.Process.run('adb', [
        if (device != null) ...['-s', device],
        'shell',
        'service',
        'list',
      ], runInShell: true);
      return result.stdOut.contains(trigger);
    },
    timeout: readyTimeout,
  );
}
