import 'dart:io' show ProcessResult;

import 'package:process/process.dart';

/// Runs `adb [-s <deviceId>] pull <source> <destination>` via [processManager].
///
/// Returns the raw [ProcessResult] so callers keep their own exit-code handling.
Future<ProcessResult> adbPull(
  ProcessManager processManager, {
  required String source,
  required String destination,
  String? deviceId,
}) {
  return processManager.run([
    'adb',
    if (deviceId != null && deviceId.isNotEmpty) ...['-s', deviceId],
    'pull',
    source,
    destination,
  ], runInShell: true);
}

/// Runs `adb [-s <deviceId>] shell rm [-rf] <path>` via [processManager].
///
/// Returns the raw [ProcessResult] so callers keep their own exit-code handling.
Future<ProcessResult> adbRemove(
  ProcessManager processManager, {
  required String path,
  String? deviceId,
  bool recursive = false,
}) {
  return processManager.run([
    'adb',
    if (deviceId != null && deviceId.isNotEmpty) ...['-s', deviceId],
    'shell',
    'rm',
    if (recursive) '-rf',
    path,
  ], runInShell: true);
}
