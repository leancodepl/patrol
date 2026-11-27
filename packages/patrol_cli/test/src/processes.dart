import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

/// The PIDs [executable] prints, one per line.
Future<List<int>> pidsFrom(String executable, List<String> arguments) async {
  final result = await Process.run(executable, arguments);

  return LineSplitter.split(
    result.stdout as String,
  ).map((line) => int.tryParse(line.trim())).nonNulls.toList();
}

Future<bool> isAlive(int pid) async {
  if (!Platform.isWindows) {
    final result = await Process.run('kill', ['-0', '$pid']);
    return result.exitCode == 0;
  }
  final command =
      'Get-Process -Id $pid -ErrorAction SilentlyContinue'
      ' | Select-Object -ExpandProperty Id';
  final alive = await pidsFrom('powershell.exe', [
    '-NoProfile',
    '-Command',
    command,
  ]);

  return alive.contains(pid);
}

/// Waits for every one of [pids] to be gone. A killed child stays visible until
/// it is reaped, so a single check can still see it.
Future<void> expectGone(List<int> pids) async {
  for (final pid in pids) {
    var alive = true;
    for (var i = 0; i < 50 && alive; i++) {
      alive = await isAlive(pid);
      if (alive) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    }
    expect(alive, isFalse, reason: 'child $pid is still running');
  }
}

/// Polls [condition] until it holds, failing after 10 s with [what] as the
/// thing that never happened.
Future<void> waitUntil(bool Function() condition, String what) async {
  final deadline = DateTime.now().add(const Duration(seconds: 10));
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Gave up waiting: $what.');
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
}
