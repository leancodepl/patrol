import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:args/args.dart';
import 'package:dispose_scope/dispose_scope.dart' hide ProcessDisposed;
import 'package:patrol_cli/src/base/process.dart';
import 'package:patrol_cli/src/commands/develop_arg_parser.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';
import 'package:patrol_log/patrol_log.dart';
import 'package:patrol_log/patrol_log_reader.dart';
import 'package:platform/platform.dart';
import 'package:process/process.dart';

/// How a suite run stands.
enum SuiteState {
  running,
  passed,
  failed,
  cancelled;

  String get summary => switch (this) {
    running => 'The suite is running.',
    passed => 'Every test in the suite passed ✅',
    failed => 'The suite failed ❌',
    cancelled => 'The suite was stopped before it finished.',
  };
}

/// The `patrol mcp` server's develop flags, rearranged into a `patrol test`
/// command line.
final class SuiteCommandLine {
  SuiteCommandLine._(this.arguments, this.dropped);

  /// Builds the arguments that follow the CLI executable.
  ///
  /// Flags `patrol test` does not take are left out and named in [dropped].
  /// Global flags go before the command, because the runner reads them only
  /// there. A call's [targets] and [tags] replace the server's own.
  ///
  /// Throws a [FormatException] when [serverArgs] do not parse as develop
  /// flags.
  factory SuiteCommandLine.build({
    required List<String> serverArgs,
    required List<String> targets,
    required String? tags,
    required String? excludeTags,
    required String? device,
    required String? flutterCommand,
    required String resultsFile,
  }) {
    final parser = _parser();
    final results = parser.parse(serverArgs);
    final global = <String>[];
    final test = <String>[];
    final dropped = <String>[];
    for (final name in results.options) {
      if (!results.wasParsed(name)) {
        continue;
      }
      if (_developOnly.contains(name)) {
        dropped.add('--$name');
        continue;
      }
      if ((name == 'target' && targets.isNotEmpty) ||
          (name == 'tags' && tags != null)) {
        continue;
      }
      (_global.contains(name) ? global : test).addAll(
        _serialize(parser.options[name]!, results[name]),
      );
    }
    final pinned = results['device'] as List<String>;
    final callerChecks = results.wasParsed('check-compatibility');
    if (flutterCommand != null && !results.wasParsed('flutter-command')) {
      global.add('--flutter-command=$flutterCommand');
    }
    return SuiteCommandLine._([
      ...global,
      'test',
      ...test,
      for (final target in targets) '--target=$target',
      if (tags != null) '--tags=$tags',
      if (excludeTags != null) '--exclude-tags=$excludeTags',
      if (pinned.isEmpty && device != null) '--device=$device',
      // The server compared the versions already, without the
      // `flutter doctor` the check spawns.
      if (!callerChecks) '--no-check-compatibility',
      '--results-file=$resultsFile',
    ], dropped);
  }

  final List<String> arguments;

  /// The `--device` values [serverArgs] pin.
  ///
  /// Throws a [FormatException] when [serverArgs] do not parse as develop
  /// flags.
  static List<String> pinnedDevices(List<String> serverArgs) =>
      _parser().parse(serverArgs)['device'] as List<String>;

  /// Server flags left out because `patrol test` does not take them.
  final List<String> dropped;

  static const _global = {'flutter-command', 'verbose'};

  static const _developOnly = {'use-prebuilt-apks', 'open-devtools'};

  static ArgParser _parser() {
    final command = _SuiteParserCommand();
    configureDevelopArgParser(command);
    addGlobalFlags(command.argParser);
    return command.argParser;
  }

  static List<String> _serialize(Option option, Object? value) =>
      switch (value) {
        final bool on => ['--${on ? '' : 'no-'}${option.name}'],
        final List<String> values => [
          for (final v in values) '--${option.name}=$v',
        ],
        _ => ['--${option.name}=$value'],
      };
}

final class _SuiteParserCommand extends PatrolCommand {
  @override
  String get name => 'suite-parser';

  @override
  String get description => 'Internal parser holder for suite runs';
}

/// The command that starts this same CLI: the compiled executable on its own,
/// or the VM with the script or snapshot it runs.
List<String> selfCommand() {
  final executable = io.Platform.resolvedExecutable;
  final script = io.Platform.script.toFilePath();
  return [
    executable,
    if (script != executable) ...[...io.Platform.executableArguments, script],
  ];
}

/// One `patrol test` run of a suite, in a subprocess of this CLI.
///
/// Results come from the entries the run appends to its results file, so the
/// subprocess's output is only log.
final class SuiteRun {
  SuiteRun._({
    required io.Process process,
    required this.resultsFile,
    required this.targets,
    required this.droppedFlags,
    required this.deviceSelectionNote,
    required Platform platform,
    required Duration stopGrace,
    required DateTime Function() now,
  }) : _process = process,
       _platform = platform,
       _stopGrace = stopGrace,
       _now = now,
       _startedAt = now();

  /// Starts [command], a `patrol test` command line, in [projectRoot].
  ///
  /// [onOutput] gets every line the run prints, stdout and stderr alike.
  static Future<SuiteRun> start({
    required ProcessManager processManager,
    required List<String> command,
    required String projectRoot,
    required String resultsFile,
    required List<String> targets,
    required List<String> droppedFlags,
    required void Function(String line) onOutput,
    String? deviceSelectionNote,
    Platform platform = const LocalPlatform(),
    Duration stopGrace = const Duration(seconds: 30),
    DateTime Function()? now,
  }) async {
    final process = await processManager.start(
      command,
      workingDirectory: projectRoot,
    );
    final run = SuiteRun._(
      process: process,
      resultsFile: resultsFile,
      targets: targets,
      droppedFlags: droppedFlags,
      deviceSelectionNote: deviceSelectionNote,
      platform: platform,
      stopGrace: stopGrace,
      now: now ?? DateTime.now,
    );
    unawaited(process.stdin.close().catchError((Object _) {}));
    for (final stream in [process.stdout, process.stderr]) {
      stream
          .transform(const Utf8Decoder(allowMalformed: true))
          .transform(const LineSplitter())
          .listen((line) {
            run._pushOutput(line);
            onOutput(line);
          });
    }
    unawaited(process.exitCode.then(run._finish));
    return run;
  }

  final io.Process _process;
  final Platform _platform;
  final Duration _stopGrace;
  final DateTime Function() _now;
  final DateTime _startedAt;

  /// Where the run appends its test and error entries.
  final String resultsFile;

  /// What the call asked to run; empty for the whole suite.
  final List<String> targets;

  /// Server flags `patrol test` does not take, left out of this run.
  final List<String> droppedFlags;

  final String? deviceSelectionNote;

  static const _maxErrorLines = 60;
  static const _maxFailuresListed = 10;
  static const _maxOutputLines = 40;

  SuiteState _state = SuiteState.running;
  SuiteState get state => _state;

  bool get isRunning => _state == SuiteState.running;

  int? _exitCode;
  DateTime? _finishedAt;
  final _finished = Completer<void>();
  final _output = <String>[];

  var _passed = 0;
  var _skipped = 0;
  final _failures = <_Failure>[];
  _Failure? _openFailure;
  String? _currentTest;
  var _readOffset = 0;
  var _partialLine = '';

  /// Completes once the run has exited and its results are read.
  Future<void> get done => _finished.future;

  /// Waits for the run to end, or for [timeout], whichever comes first.
  Future<void> waitFor(Duration timeout) =>
      _finished.future.timeout(timeout, onTimeout: () {});

  /// Stops the run and waits for it to exit.
  ///
  /// SIGINT lets `patrol test` tear down what it started, as Ctrl+C does. A run
  /// that is still alive after the grace period, or one on Windows, where no
  /// signal reaches another process, is killed with everything it spawned.
  Future<void> stop() async {
    if (!isRunning) {
      return;
    }
    _state = SuiteState.cancelled;
    if (!_platform.isWindows) {
      _process.kill(io.ProcessSignal.sigint);
      await _finished.future.timeout(_stopGrace, onTimeout: () {});
    }
    if (!_finished.isCompleted) {
      final scope = DisposeScope();
      _process.disposedByTree(scope);
      await scope.dispose();
      await _finished.future.timeout(_stopGrace, onTimeout: () {});
    }
  }

  void _finish(int exitCode) {
    _exitCode = exitCode;
    _finishedAt = _now();
    _readResults();
    _currentTest = null;
    if (_state == SuiteState.running) {
      _state = exitCode == 0 ? SuiteState.passed : SuiteState.failed;
    }
    _finished.complete();
  }

  void _pushOutput(String line) {
    _output.add(line.replaceAll(_ansiEscape, ''));
    if (_output.length > _maxOutputLines) {
      _output.removeRange(0, _output.length - _maxOutputLines);
    }
  }

  /// Reads the entries appended since the last read. A line still being
  /// written is kept until its newline arrives.
  void _readResults() {
    final file = io.File(resultsFile);
    if (!file.existsSync()) {
      return;
    }
    final String chunk;
    final raf = file.openSync();
    try {
      final length = raf.lengthSync();
      if (length <= _readOffset) {
        return;
      }
      raf.setPositionSync(_readOffset);
      chunk = utf8.decode(
        raf.readSync(length - _readOffset),
        allowMalformed: true,
      );
      _readOffset = length;
    } finally {
      raf.closeSync();
    }
    final lines = '$_partialLine$chunk'.split('\n');
    _partialLine = lines.removeLast();
    for (final line in lines) {
      if (line.trim().isEmpty) {
        continue;
      }
      try {
        _handleEntry(PatrolLogReader.parseEntry(line));
      } on Object {
        // A line this version cannot read is skipped, not fatal.
      }
    }
  }

  void _handleEntry(Entry entry) {
    switch (entry) {
      case TestEntry(status: TestEntryStatus.start):
        _currentTest = entry.name;
        _openFailure = null;
      case TestEntry(status: TestEntryStatus.success):
        _passed++;
        _currentTest = null;
      case TestEntry(status: TestEntryStatus.skip):
        _skipped++;
      case TestEntry(status: TestEntryStatus.failure):
        final failure = _openFailure = _Failure(entry.name);
        if (entry.error case final error?) {
          failure.add(error);
        }
        _failures.add(failure);
        _currentTest = null;
      case ErrorEntry():
        _openFailure?.add(entry.message);
      default:
    }
  }

  Map<String, Object> toMap() {
    _readResults();
    final end = _finishedAt ?? _now();
    final failedWithoutTest = _state == SuiteState.failed && _failures.isEmpty;
    return {
      'suiteState': _state.name,
      'summary': _state.summary,
      if (targets.isNotEmpty) 'targets': targets,
      'passed': _passed,
      'failed': _failures.length,
      'skipped': _skipped,
      'currentTest': ?_currentTest,
      'elapsedSeconds': end.difference(_startedAt).inSeconds,
      if (_failures.isNotEmpty)
        'failures': [
          for (final failure in _failures.take(_maxFailuresListed))
            failure.toMap(),
        ],
      if (_failures.length > _maxFailuresListed)
        'failuresNotListed': _failures.length - _maxFailuresListed,
      if (failedWithoutTest)
        'warning':
            'patrol test exited with code $_exitCode and no test reported a '
            'failure, so the run broke outside the tests: a build, an install '
            'or a toolchain that never connected. The output ends where it '
            'stopped.',
      if (failedWithoutTest) 'output': _output.join('\n'),
      if (droppedFlags.isNotEmpty)
        'droppedFlags':
            'Left out of this run because patrol test does not take them: '
            '${droppedFlags.join(', ')}.',
      'deviceSelectionNote': ?deviceSelectionNote,
    };
  }
}

final class _Failure {
  _Failure(this.name);

  final String name;
  final _lines = <String>[];

  void add(String text) {
    for (final line in const LineSplitter().convert(text)) {
      if (_lines.length < SuiteRun._maxErrorLines) {
        _lines.add(line);
      }
    }
  }

  Map<String, Object> toMap() => {
    'name': name,
    if (_lines.isNotEmpty) 'error': _lines.join('\n'),
  };
}

final _ansiEscape = RegExp(r'\x1B\[[0-9;?]*[ -/]*[@-~]');
