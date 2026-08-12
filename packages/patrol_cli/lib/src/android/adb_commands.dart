import 'dart:io' show ProcessResult;

import 'package:process/process.dart';

/// Runs `adb pull` via [processManager], returning the raw result for the caller
/// to handle.
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

/// Runs `adb shell rm [-rf]` via [processManager], returning the raw result for
/// the caller to handle.
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
