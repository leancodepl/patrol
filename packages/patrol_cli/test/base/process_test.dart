import 'dart:convert';
import 'dart:io';

import 'package:dispose_scope/dispose_scope.dart' hide ProcessDisposed;
import 'package:patrol_cli/src/base/process.dart';
import 'package:test/test.dart';

/// Starts a process that stays alive until killed and keeps a child of its own -
/// the shape of every wrapped process patrol starts (`cmd.exe /c`, `fvm`).
Future<Process> _startSleeper() {
  if (Platform.isWindows) {
    return Process.start('cmd.exe', ['/c', 'ping -n 120 127.0.0.1']);
  }
  return Process.start('sh', ['-c', 'sleep 120 & wait']);
}

Future<List<int>> _pidsFrom(String executable, List<String> arguments) async {
  final result = await Process.run(executable, arguments);

  return LineSplitter.split(
    result.stdout as String,
  ).map((line) => int.tryParse(line.trim())).nonNulls.toList();
}

/// PIDs of the processes [pid] spawned, as reported by the OS.
Future<List<int>> _childrenOf(int pid) {
  if (!Platform.isWindows) {
    return _pidsFrom('pgrep', ['-P', '$pid']);
  }
  final command =
      'Get-CimInstance Win32_Process -Filter "ParentProcessId = $pid"'
      ' | Select-Object -ExpandProperty ProcessId';

  return _pidsFrom('powershell.exe', ['-NoProfile', '-Command', command]);
}

Future<bool> _isAlive(int pid) async {
  if (!Platform.isWindows) {
    final result = await Process.run('kill', ['-0', '$pid']);
    return result.exitCode == 0;
  }
  final command =
      'Get-Process -Id $pid -ErrorAction SilentlyContinue'
      ' | Select-Object -ExpandProperty Id';
  final alive = await _pidsFrom('powershell.exe', [
    '-NoProfile',
    '-Command',
    command,
  ]);

  return alive.contains(pid);
}

void main() {
  group('disposedByTree', () {
    test('kills the process when the scope is disposed', () async {
      final scope = DisposeScope();
      final process = await _startSleeper();
      addTearDown(process.kill);

      process.disposedByTree(scope);
      await scope.dispose();

      await expectLater(process.exitCode, completes);
    });

    test('does nothing when the process has already exited', () async {
      final scope = DisposeScope();
      final process = Platform.isWindows
          ? await Process.start('cmd.exe', ['/c', 'exit 0'])
          : await Process.start('sh', ['-c', 'true']);

      final exitCode = process.exitCode;
      process.disposedByTree(scope);

      await expectLater(exitCode, completes);
      await expectLater(scope.dispose(), completes);
    });

    test('kills the processes that the process spawned', () async {
      final scope = DisposeScope();
      final process = await _startSleeper();
      addTearDown(process.kill);
      process.disposedByTree(scope);

      // The shell needs a moment before its child shows up in the process list.
      var children = <int>[];
      for (var i = 0; i < 50 && children.isEmpty; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        children = await _childrenOf(process.pid);
      }
      expect(
        children,
        isNotEmpty,
        reason: 'no child was spawned, so this proves nothing',
      );

      await scope.dispose();

      for (final child in children) {
        expect(
          await _isAlive(child),
          isFalse,
          reason: 'child $child is still running',
        );
      }
    });
  });
}
