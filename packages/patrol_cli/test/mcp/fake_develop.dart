import 'dart:async';

import 'package:dispose_scope/dispose_scope.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/commands/develop_options.dart';
import 'package:patrol_cli/src/commands/develop_service.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/mcp/patrol_session.dart';
import 'package:patrol_log/patrol_log.dart';

class MockDevelopService extends Mock implements DevelopService {}

/// Captures what the session hands its develop service, so tests can drive the
/// callbacks the real service would fire and read the stdin it would receive.
class FakeDevelop {
  FakeDevelop({
    Device? device,
    Future<void>? hotRestartReady,
    this.quitEndsRun = true,
    this.runOutlivesExit = false,
    Object? runError,
    String? webDebuggerPort,
  }) {
    when(() => service.device).thenReturn(device);
    when(() => service.webDebuggerPort).thenReturn(webDebuggerPort);
    when(
      () => service.hotRestartReady,
    ).thenAnswer((_) => hotRestartReady ?? Completer<void>().future);
    // run() returns when the session is quit, or fails with [runError].
    when(() => service.run(any())).thenAnswer((invocation) {
      options.add(invocation.positionalArguments.first as DevelopOptions);
      if (runError != null) {
        return Future<void>.error(runError);
      }
      final finished = Completer<void>();
      _runs.add(finished);
      return finished.future;
    });
  }

  final service = MockDevelopService();

  /// Whether a `Q` on stdin ends `run()`. Off, a run ends only through [endRun].
  final bool quitEndsRun;

  /// Whether `run()` keeps going after the backend has exited. A `Q` then
  /// reports the exit, and the run ends only through [endRun].
  final bool runOutlivesExit;

  /// Ends the [index]th run, if it is still going.
  void endRun(int index) {
    if (!_runs[index].isCompleted) {
      _runs[index].complete();
    }
  }

  final _runs = <Completer<void>>[];

  /// What each started session was asked to run.
  final options = <DevelopOptions>[];

  /// `create` and the disposal of each session's scope, in the order they
  /// happened.
  final events = <String>[];

  /// The completion callback each session was created with.
  final completions = <void Function(TestCompletionResult result)?>[];

  final stdinChars = <String>[];
  void Function(Entry entry)? onLogEntry;
  void Function(TestCompletionResult result)? onTestsCompleted;

  DevelopService create({
    required String projectRoot,
    required DisposeScope disposeScope,
    required Stream<List<int>> stdin,
    Future<void> Function()? onExit,
    void Function(TestCompletionResult result)? onTestsCompleted,
    void Function(Entry entry)? onLogEntry,
    bool verbose = false,
  }) {
    events.add('create');
    this.onLogEntry = onLogEntry;
    this.onTestsCompleted = onTestsCompleted;
    completions.add(onTestsCompleted);
    // Teardown takes a moment, so an overlapping start shows in [events].
    final run = _runs.length;
    disposeScope.addDispose(
      () => Future<void>.delayed(const Duration(milliseconds: 30), () {
        events.add('dispose');
        if (!runOutlivesExit && run < _runs.length) {
          endRun(run);
        }
      }),
    );
    stdin.listen((bytes) {
      final chars = String.fromCharCodes(bytes);
      stdinChars.add(chars);
      if (runOutlivesExit && chars.contains(SessionCommand.quit.value)) {
        unawaited(onExit?.call());
      } else if (quitEndsRun && chars.contains(SessionCommand.quit.value)) {
        if (_runs.isNotEmpty) {
          endRun(_runs.length - 1);
        }
      }
    });
    return service;
  }

  /// What `patrol` reports when a test fails: the failure, then one error
  /// entry per line of its details.
  void reportTestFailed(String name, {String? error}) => onLogEntry?.call(
    TestEntry(name: name, status: TestEntryStatus.failure, error: error),
  );

  void reportError(String message) =>
      onLogEntry?.call(ErrorEntry(message: message));

  /// What `patrol` reports when every test in develop mode has run.
  void reportTestsPassed() => onLogEntry?.call(
    ConfigEntry(config: {ConfigEntry.developCompletedKey: true}),
  );
}

/// A device lookup slow enough to act inside, as a cold start's first seconds.
AttachedDevicesReader slowLookup(Completer<void> started) =>
    ({required flutterCommand}) async {
      if (!started.isCompleted) {
        started.complete();
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
      return const [
        Device(
          name: 'test device',
          id: 'test-device',
          targetPlatform: TargetPlatform.android,
          real: false,
        ),
      ];
    };
