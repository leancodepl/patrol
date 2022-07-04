import 'dart:async';
import 'dart:io';

import 'package:adb/adb.dart';
import 'package:adb/src/exceptions.dart';
import 'package:adb/src/extensions.dart';
import 'package:adb/src/internals.dart';

/// Provides Dart interface for common `adb` functionality.
///
/// See also:
///  * https://developer.android.com/studio/command-line/adb
class Adb {
  /// Creates [Adb] instance.
  const Adb({AdbInternals adbInternals = const AdbInternals()})
      : _adbInternals = adbInternals;

  final AdbInternals _adbInternals;

  /// Installs the APK file (which has to be on [path]) to the attached device.
  ///
  /// If there is more than 1 device attached, decide which one to use by passing
  /// [device].
  ///
  /// Throws if there are no devices attached.
  Future<ProcessResult> install(
    String path, {
    String? device,
  }) async {
    final result = await Process.run(
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
      if (result.stdErr.contains('INSTALL_FAILED_UPDATE_INCOMPATIBLE')) {
        throw AdbInstallFailedUpdateIncompatible.fromStdErr(result.stdErr);
      }

      throw Exception(result.stdErr);
    }

    return result;
  }

  /// Uninstalls the app identified by [packageName] from the the attached device.
  ///
  /// If there is more than 1 device attached, decide which one to use by passing
  /// [device].
  ///
  /// Thorws if there are no devices attached.
  Future<ProcessResult> uninstall(
    String packageName, {
    String? device,
  }) async {
    final result = await Process.run(
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
      throw Exception(result.stdErr);
    }

    return result;
  }

  /// Sets up port forwarding on the attached device.
  ///
  /// If there is more than 1 device attached, decide which one to use by passing
  /// [device].
  ///
  /// Throws if there are no devices attached.
  ///
  /// See also:
  ///  * https://developer.android.com/studio/command-line/adb#forwardports
  Future<void> forwardPorts({
    required int fromHost,
    required int toDevice,
    String? device,
    String protocol = 'tcp',
  }) async {
    final result = await Process.run(
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
      throw Exception(result.stdErr);
    }
  }

  /// Runs instrumentation test specified by [packageName] and [intentClass] on
  /// the attached device.
  ///
  /// If there is more than 1 device attached, decide which one to use by passing
  /// [device].
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
    final process = await Process.start(
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
      final text = systemEncoding.decode(data);
      onStdout?.call(text);
    });

    final stderrSub = process.stderr.listen((data) {
      final text = systemEncoding.decode(data);
      onStderr?.call(text);
    });

    final code = await process.exitCode;

    await stdoutSub.cancel();
    await stderrSub.cancel();

    if (code != 0) {
      throw Exception('Instrumentation server exited with code $code');
    }
  }

  /// Like [install], but if the install fails because of
  /// INSTALL_FAILED_UPDATE_INCOMPATIBLE, the app is uninstalled and installed
  /// again.
  Future<void> forceInstallApk(String path, {String? device}) async {
    try {
      await install(path, device: device);
    } on AdbInstallFailedUpdateIncompatible catch (err) {
      await uninstall(err.packageName, device: device);
      await install(path, device: device);
    }
  }

  /// Returns the list of currently attached devices.
  ///
  /// See also:
  ///  * https://developer.android.com/studio/command-line/adb#devicestatus
  Future<List<String>> devices() async {
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
}
