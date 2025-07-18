import 'dart:async';
import 'dart:convert';
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
  Future<void> init() async {
    await _adbInternals.ensureServerRunning();
  }

  final AdbInternals _adbInternals;

  /// Installs the APK file (which has to be on [path]) to the attached device.
  ///
  /// If there is more than 1 device attached, decide which one to use by
  /// passing [device].
  ///
  /// Waits for the package service to start up before proceeding with
  /// installation.
  ///
  /// Throws if there are no devices attached.
  Future<io.ProcessResult> install(String path, {String? device}) async {
    await _adbInternals.ensureServerRunning();
    await _adbInternals.ensurePackageServiceRunning(device: device);
    await _adbInternals.ensureActivityServiceRunning(device: device);

    final result = await io.Process.run('adb', [
      if (device != null) ...['-s', device],
      'install',
      path,
    ], runInShell: true);

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
    await _adbInternals.ensureServerRunning();
    await _adbInternals.ensurePackageServiceRunning(device: device);
    await _adbInternals.ensureActivityServiceRunning(device: device);

    final result = await io.Process.run('adb', [
      if (device != null) ...['-s', device],
      'uninstall',
      packageName,
    ], runInShell: true);

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
    await _adbInternals.ensureServerRunning();

    final result = await io.Process.run('adb', [
      if (device != null) ...['-s', device],
      'forward',
      '$protocol:$fromHost',
      '$protocol:$toDevice',
    ], runInShell: true);

    if (result.stdErr.isNotEmpty) {
      _handleAdbExceptions(result.stdErr);

      throw Exception(result.stdErr);
    }

    return () async {
      final result = await io.Process.run('adb', [
        if (device != null) ...['-s', device],
        'forward',
        '--remove',
        '$protocol:$fromHost',
      ], runInShell: true);

      if (result.stdErr.isNotEmpty) {
        _handleAdbExceptions(result.stdErr);

        throw Exception(result.stdErr);
      }
    };
  }

  /// Returns a parsed result of `adb forward --list` command.
  Future<AdbForwardList> getForwardedPorts() async {
    await _adbInternals.ensureServerRunning();

    final output = await io.Process.run('adb', [
      'forward',
      '--list',
    ], runInShell: true);

    if (output.stdErr.isNotEmpty) {
      _handleAdbExceptions(output.stdErr);

      throw Exception(output.stdErr);
    }

    return AdbForwardList.parse(output.stdout as String);
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
  Future<io.Process> instrument({
    required String packageName,
    required String intentClass,
    String? device,
    Map<String, String> arguments = const {},
  }) async {
    await _adbInternals.ensureServerRunning();
    await _adbInternals.ensurePackageServiceRunning(device: device);
    await _adbInternals.ensureActivityServiceRunning(device: device);

    final process = await io.Process.start('adb', [
      if (device != null) ...['-s', device],
      'shell',
      'am',
      'instrument',
      '-w',
      for (final arg in arguments.entries) ...['-e', arg.key, arg.value],
      '$packageName/$intentClass',
    ], runInShell: true);

    return process;
  }

  /// Returns process that listen for adb logs.
  Future<io.Process> logcat({
    String? device,
    Map<String, String> arguments = const {},
    String? filter,
  }) async {
    await _adbInternals.ensureServerRunning();

    final process = await io.Process.start('adb', [
      if (device != null) ...['-s', device],
      'shell',
      'logcat',
      for (final arg in arguments.entries) ...[arg.key, arg.value],
      ?filter,
    ], runInShell: true);

    return process;
  }

  /// Returns the list of currently attached devices.
  ///
  /// See also:
  ///  * https://developer.android.com/studio/command-line/adb#devicestatus
  Future<List<String>> devices() async {
    await _adbInternals.ensureServerRunning();

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

/// Represents a parsed result of adb forward --list command.
extension type AdbForwardList._(Map<String, Map<int, int>> map) {
  /// Parses the output of `adb forward --list` command into a map.
  AdbForwardList.parse(String adbForwardOutput) : map = {} {
    final nonEmptyLines = const LineSplitter()
        .convert(adbForwardOutput)
        .where((line) => line.isNotEmpty);
    for (final line in nonEmptyLines) {
      final parts = line.split(' ');
      final device = parts[0];
      final hostPort = int.parse(parts[1].split(':')[1]);
      final devicePort = int.parse(parts[2].split(':')[1]);
      if (map[device] case final deviceMap?) {
        deviceMap[hostPort] = devicePort;
      } else {
        map[device] = {hostPort: devicePort};
      }
    }
  }

  /// Returns port mapping for a device with the specified id.
  Map<int, int> getMappedPortsForDevice(String deviceId) {
    return map[deviceId] ?? {};
  }
}
