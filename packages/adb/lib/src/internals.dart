import 'dart:io';

import 'package:adb/src/exceptions.dart';
import 'package:adb/src/extensions.dart';

/// This class makes it easy to swap out the implementation of the some ADB
/// commands.
class AdbInternals {
  /// Creates a new [AdbInternals] instance.
  const AdbInternals();

  /// Calls `adb devices` and returns its stdout.
  Future<String> devices() async {
    final result = await Process.run(
      'adb',
      ['devices'],
      runInShell: true,
    );

    if (result.stdErr.isNotEmpty) {
      if (result.stdErr.contains(AdbDaemonNotRunning.trigger)) {
        throw const AdbDaemonNotRunning();
      }

      throw Exception(result.stdErr);
    }

    return result.stdOut;
  }
}
