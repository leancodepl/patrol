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
    // A develop session outlives a test run: run() returns when the session is
    // quit, as the real one does when `flutter attach` exits. With [runError]
    // it fails instead, the way a build or a compatibility check does.
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

  /// Whether a `Q` on stdin ends `run()`, as `flutter attach` exiting does. Off,
  /// a run ends only through [endRun], the way a backend that exits late does.
  final bool quitEndsRun;

  /// Whether `run()` keeps going after the backend has exited, the way the real
  /// one uninstalls the app and deletes its entrypoint on the way out. A `Q`
  /// then reports the exit, and the run ends only through [endRun].
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
    // Teardown takes a moment, as it does in a real session where processes
    // have to be reaped, so an overlapping start is visible in the order.
    // Disposing kills `flutter attach`, which is what ends run().
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

  /// What `patrol` reports when every test in develop mode has run.
  void reportTestsPassed() => onLogEntry?.call(
    ConfigEntry(config: {ConfigEntry.developCompletedKey: true}),
  );
}
