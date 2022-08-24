import 'dart:async';
import 'dart:io' as io;

import 'package:adb/adb.dart';
import 'package:adb/src/exceptions.dart';
import 'package:adb/src/extensions.dart';
import 'package:adb/src/internals.dart';

/// Provides Dart interface for common Android Debug Bridge features.
///
/// See also:
///  * https://developer.android.com/studio/command-line/adb
class Adb {
  /// Creates a new [Adb] instance.
  Adb({AdbInternals adbInternals = const AdbInternals()})
      : _adbInternals = adbInternals;

  /// Initializes this [Adb] instance.
  ///
  /// If the ADB daemon is not running, it will be started.
  Future<void> init() async => _ensureRunning();

  final AdbInternals _adbInternals;

  /// Installs the APK file (which has to be on [path]) to the attached device.
  ///
  /// If there is more than 1 device attached, decide which one to use by
  /// passing [device].
  ///
  /// Throws if there are no devices attached.
  Future<io.ProcessResult> install(
    String path, {
    String? device,
  }) async {
    await _ensureRunning();

    final result = await io.Process.run(
      'adb',
      [
        if (device != null) ...[
          '-s',
          device,
        ],
        'install',
        path,
      ],
      runInShell: true,
    );

    if (result.stdErr.isNotEmpty) {
      _handleAdbExceptions(result.stdErr);

      throw Exception(result.stdErr);
    }

    return result;
  }

  /// Uninstalls the app identified by [packageName] from the the attached
  /// device.
  ///
  /// If there is more than 1 device attached, decide which one to use by
  /// passing [device].
  ///
  /// Thorws if there are no devices attached.
  Future<io.ProcessResult> uninstall(
    String packageName, {
    String? device,
  }) async {
    await _ensureRunning();

    final result = await io.Process.run(
      'adb',
      [
        if (device != null) ...[
          '-s',
          device,
        ],
        'uninstall',
        packageName,
      ],
      runInShell: true,
    );

    if (result.stdErr.isNotEmpty) {
      _handleAdbExceptions(result.stdErr);

      throw Exception(result.stdErr);
    }

    return result;
  }

  /// Sets up port forwarding on the attached device. Returns a function that
  /// stops the port forwarding when called.
  ///
  /// If there is more than 1 device attached, decide which one to use by
  /// passing [device].
  ///
  /// Throws if there are no devices attached.
  ///
  /// See also:
  ///  * https://developer.android.com/studio/command-line/adb#forwardports
  Future<Future<void> Function()> forwardPorts({
    required int fromHost,
    required int toDevice,
    String? device,
    String protocol = 'tcp',
  }) async {
    await _ensureRunning();

    final result = await io.Process.run(
      'adb',
      [
        if (device != null) ...[
          '-s',
          device,
        ],
        'forward',
        '$protocol:$fromHost',
        '$protocol:$toDevice',
      ],
      runInShell: true,
    );

    if (result.stdErr.isNotEmpty) {
      _handleAdbExceptions(result.stdErr);

      throw Exception(result.stdErr);
    }

    return () async {
      final result = await io.Process.run(
        'adb',
        [
          if (device != null) ...[
            '-s',
            device,
          ],
          'forward',
          '--remove',
          '$protocol:$fromHost',
        ],
        runInShell: true,
      );

      if (result.stdErr.isNotEmpty) {
        _handleAdbExceptions(result.stdErr);

        throw Exception(result.stdErr);
      }
    };
  }

  /// Runs instrumentation test specified by [packageName] and [intentClass] on
  /// the attached device.
  ///
  /// If there is more than 1 device attached, decide which one to use by
  /// passing [device].
  ///
  /// Throws if there are no devices attached.
  ///
  /// See also:
  ///  * https://developer.android.com/studio/test/command-line#run-tests-with-adb
  Future<void> instrument({
    required String packageName,
    required String intentClass,
    String? device,
    void Function(String)? onStdout,
    void Function(String)? onStderr,
    Map<String, String> arguments = const {},
  }) async {
    await _ensureRunning();

    final process = await io.Process.start(
      'adb',
      [
        if (device != null) ...[
          '-s',
          device,
        ],
        'shell',
        'am',
        'instrument',
        '-w',
        for (final arg in arguments.entries) ...[
          '-e',
          arg.key,
          arg.value,
        ],
        '$packageName/$intentClass',
      ],
      runInShell: true,
    );

    final stdoutSub = process.stdout.listen((data) {
      final text = io.systemEncoding.decode(data);
      onStdout?.call(text);
    });

    final stderrSub = process.stderr.listen((data) {
      final text = io.systemEncoding.decode(data);
      onStderr?.call(text);
    });

    final code = await process.exitCode;

    await stdoutSub.cancel();
    await stderrSub.cancel();

    if (code != 0) {
      throw Exception('Instrumentation server exited with code $code');
    }
  }

  /// Returns the list of currently attached devices.
  ///
  /// See also:
  ///  * https://developer.android.com/studio/command-line/adb#devicestatus
  Future<List<String>> devices() async {
    await _ensureRunning();

    final stdOut = await _adbInternals.devices();

    final lines = stdOut.split('\n')
      ..removeAt(0)
      ..removeWhere((element) => element.trim().isEmpty);

    final devices = <String>[];
    for (final line in lines) {
      final parts = line.trim().split('\t');

      if (parts.isEmpty) {
        continue;
      }

      devices.add(parts.first);
    }

    return devices;
  }

  Future<void> _ensureRunning() async {
    while (true) {
      final result = await io.Process.run(
        'adb',
        ['start-server'],
        runInShell: true,
      );
      if (result.stdErr.contains(AdbDaemonNotRunning.trigger)) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      } else {
        break;
      }
    }
  }

  void _handleAdbExceptions(String stdErr) {
    if (stdErr.contains(AdbDaemonNotRunning.trigger)) {
      throw AdbDaemonNotRunning(message: stdErr);
    }

    if (stdErr.contains(AdbInstallFailedUpdateIncompatible.trigger)) {
      throw AdbInstallFailedUpdateIncompatible(message: stdErr);
    }

    if (stdErr.contains(AdbDeleteFailedInternalError.trigger)) {
      throw AdbDeleteFailedInternalError(message: stdErr);
    }
  }
}
