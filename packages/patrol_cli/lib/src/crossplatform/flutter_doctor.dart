import 'dart:async';
import 'dart:convert';
import 'dart:io' show Process;

import 'package:file/file.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:process/process.dart';

/// Runs `flutter doctor --verbose` at most once per Flutter command and lets
/// several callers read its output.
///
/// The Java version check and the Java path lookup for Gradle both read the
/// Android toolchain section, which the doctor prints after about a second.
/// The full run takes several seconds longer, mostly to discover devices, so
/// each lookup completes as soon as its line appears.
class FlutterDoctor {
  FlutterDoctor({
    required ProcessManager processManager,
    required Directory projectRoot,
  }) : _processManager = processManager,
       _projectRoot = projectRoot;

  final ProcessManager _processManager;
  final Directory _projectRoot;
  final _runs = <String, _DoctorRun>{};

  /// The first line of `flutter doctor --verbose` that satisfies [test], or
  /// null if the doctor finishes without printing one.
  Future<String?> firstLineWhere(
    FlutterCommand flutterCommand,
    bool Function(String line) test,
  ) {
    final command = [
      flutterCommand.executable,
      ...flutterCommand.arguments,
      'doctor',
      '--verbose',
    ];
    final run = _runs[command.join('\u0000')] ??= _DoctorRun(
      _processManager.start(
        command,
        workingDirectory: _projectRoot.path,
        runInShell: true,
      ),
    );
    return run.firstLineWhere(test);
  }
}

class _DoctorRun {
  _DoctorRun(Future<Process> process) {
    _started = process.then((process) {
      process.stdout
          .transform(const Utf8Decoder(allowMalformed: true))
          .transform(const LineSplitter())
          .listen(
            (line) {
              _lines.add(line);
              _changes.add(null);
            },
            onDone: _finish,
            onError: (Object _) => _finish(),
          );
      process.stderr.drain<void>().ignore();
    }, onError: (Object _) => _finish());
  }

  late final Future<void> _started;
  final _lines = <String>[];
  final _changes = StreamController<void>.broadcast(sync: true);
  var _done = false;

  void _finish() {
    _done = true;
    _changes.add(null);
  }

  Future<String?> firstLineWhere(bool Function(String line) test) async {
    await _started;
    var checked = 0;
    while (true) {
      for (; checked < _lines.length; checked++) {
        if (test(_lines[checked])) {
          return _lines[checked];
        }
      }
      if (_done) {
        return null;
      }
      await _changes.stream.first;
    }
  }
}
