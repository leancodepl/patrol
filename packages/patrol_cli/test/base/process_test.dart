import 'dart:convert';
import 'dart:io';

import 'package:dispose_scope/dispose_scope.dart' hide ProcessDisposed;
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:platform/testing.dart' show TestNativePlatform;
import 'package:test/test.dart';

import '../src/mocks.dart';

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

      final children = await _waitForChildren(process.pid);

      await scope.dispose();

      await _expectGone(children);
    });

    test('tells the caller when it kills a running process', () async {
      final scope = DisposeScope();
      final process = await _startSleeper();
      addTearDown(process.kill);
      var killed = false;
      process.disposedByTree(scope, onKill: () => killed = true);

      await scope.dispose();

      expect(killed, isTrue);
    });

    test('does not report a kill for a process that exited', () async {
      final scope = DisposeScope();
      final process = Platform.isWindows
          ? await Process.start('cmd.exe', ['/c', 'exit 0'])
          : await Process.start('sh', ['-c', 'true']);
      var killed = false;
      process.disposedByTree(scope, onKill: () => killed = true);

      await process.exitCode;
      await scope.dispose();

      expect(killed, isFalse);
    });
  });

  group('disposedByTree with a grace period', () {
    test('lets a process that ends on its own finish', () async {
      final scope = DisposeScope();
      final process = Platform.isWindows
          ? await Process.start('cmd.exe', ['/c', 'ping -n 2 127.0.0.1'])
          : await Process.start('sh', ['-c', 'sleep 1']);
      addTearDown(process.kill);
      var killed = false;
      process.disposedByTree(
        scope,
        grace: const Duration(seconds: 20),
        onKill: () => killed = true,
      );

      await scope.dispose();

      expect(killed, isFalse);
      expect(await process.exitCode, 0);
    });

    test('kills a process that outlives it', () async {
      final scope = DisposeScope();
      final process = await _startSleeper();
      addTearDown(process.kill);
      var killed = false;
      process.disposedByTree(
        scope,
        grace: const Duration(milliseconds: 200),
        onKill: () => killed = true,
      );

      await scope.dispose();

      expect(killed, isTrue);
      await expectLater(process.exitCode, completes);
    });
  });

  group('killTree', () {
    test('leaves a process that has ended alone', () async {
      final process = MockProcess();
      when(() => process.exitCode).thenAnswer((_) async => 0);
      // No such process: a regression must not signal real ones.
      when(() => process.pid).thenReturn(999999999);
      when(process.kill).thenReturn(true);

      await process.killTree();

      verifyNever(process.kill);
      verifyNever(() => process.pid);
    });

    test('kills the processes that the process spawned', () async {
      final process = await _startSleeper();
      addTearDown(process.kill);
      final children = await _waitForChildren(process.pid);

      await process.killTree();

      await expectLater(process.exitCode, completes);
      await _expectGone(children);
    });
  });

  group('watchStopSignals', () {
    // SIGTERM cannot be watched on Windows: it throws an async SignalException
    // that no try/catch sees, so a server watching it there would crash.
    test('watches SIGINT and SIGTERM elsewhere', testOn: '!windows', () {
      final subscriptions = watchStopSignals(
        (_) {},
        platform: TestNativePlatform(operatingSystem: 'linux'),
      );
      addTearDown(() {
        for (final subscription in subscriptions) {
          subscription.cancel();
        }
      });

      expect(subscriptions, hasLength(2));
    });

    test('watches only SIGINT on Windows', () {
      final subscriptions = watchStopSignals(
        (_) {},
        platform: TestNativePlatform(operatingSystem: 'windows'),
      );
      addTearDown(() {
        for (final subscription in subscriptions) {
          subscription.cancel();
        }
      });

      expect(subscriptions, hasLength(1));
    });
  });
}

/// Waits for [pid]'s children to show up; a shell needs a moment to spawn them.
Future<List<int>> _waitForChildren(int pid) async {
  var children = <int>[];
  for (var i = 0; i < 50 && children.isEmpty; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    children = await _childrenOf(pid);
  }
  expect(
    children,
    isNotEmpty,
    reason: 'no child was spawned, so this proves nothing',
  );
  return children;
}

/// Waits for every one of [pids] to be gone. A killed child stays visible until
/// it is reaped, so a single check can still see it.
Future<void> _expectGone(List<int> pids) async {
  for (final pid in pids) {
    var alive = true;
    for (var i = 0; i < 50 && alive; i++) {
      alive = await _isAlive(pid);
      if (alive) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    }
    expect(alive, isFalse, reason: 'child $pid is still running');
  }
}
