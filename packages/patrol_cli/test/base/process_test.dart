import 'dart:convert';
import 'dart:io';

import 'package:dispose_scope/dispose_scope.dart' hide ProcessDisposed;
import 'package:patrol_cli/src/base/process.dart';
import 'package:test/test.dart';

/// Starts a process that stays alive until killed. On Windows that is
/// `cmd.exe` with `ping` as a child - the shape of every `runInShell: true`
/// process patrol starts.
Future<Process> _startSleeper() {
  if (Platform.isWindows) {
    return Process.start('cmd.exe', ['/c', 'ping -n 120 127.0.0.1']);
  }
  return Process.start('sh', ['-c', 'sleep 120']);
}

Future<List<int>> _pidsFrom(String powershellCommand) async {
  final result = await Process.run('powershell.exe', [
    '-NoProfile',
    '-Command',
    powershellCommand,
  ]);

  return LineSplitter.split(
    result.stdout as String,
  ).map((line) => int.tryParse(line.trim())).nonNulls.toList();
}

/// PIDs of the processes [pid] spawned, as reported by the OS.
Future<List<int>> _childrenOf(int pid) {
  const select = '| Select-Object -ExpandProperty ProcessId';
  return _pidsFrom(
    'Get-CimInstance Win32_Process -Filter "ParentProcessId = $pid" $select',
  );
}

Future<bool> _isAlive(int pid) async {
  const select = '| Select-Object -ExpandProperty Id';
  final alive = await _pidsFrom(
    'Get-Process -Id $pid -ErrorAction SilentlyContinue $select',
  );

  return alive.contains(pid);
}

void main() {
  group('disposedBy', () {
    test('kills the process when the scope is disposed', () async {
      final scope = DisposeScope();
      final process = await _startSleeper();
      addTearDown(process.kill);

      process.disposedBy(scope);
      await scope.dispose();

      await expectLater(process.exitCode, completes);
    });

    test(
      'kills the processes that the process spawned',
      () async {
        final scope = DisposeScope();
        final process = await _startSleeper();
        addTearDown(process.kill);
        process.disposedBy(scope);

        // cmd.exe needs a moment before its child shows up in the process list.
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
            reason: 'child $child is still running (#3209)',
          );
        }
      },
      skip: Platform.isWindows
          ? null
          : 'elsewhere `sh -c` execs, so there is no child to leak',
    );
  });
}
