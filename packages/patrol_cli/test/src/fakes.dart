import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:mocktail/mocktail.dart';
import 'package:platform/platform.dart';

void setUpFakes() {
  registerFallbackValue(Uri());
}

FakePlatform fakePlatform(String home) {
  return FakePlatform(
    environment: {'HOME': home},
    operatingSystem: 'macos',
    operatingSystemVersion: 'Version 13.3.1 (a) (Build 22E772610a)',
    localeName: 'en-US',
  );
}

/// A [io.Process] whose output and exit are controlled by the test.
///
/// [kill] records the signal. With [exitOnSigterm] (the default), SIGTERM ends
/// the process with exit code -15. SIGKILL always ends it with -9.
class FakeProcess implements io.Process {
  FakeProcess({this.exitOnSigterm = true});

  final bool exitOnSigterm;

  @override
  int get pid => 1234;

  final _stdout = StreamController<List<int>>();
  final _stderr = StreamController<List<int>>();
  final _exitCode = Completer<int>();
  final _stdin = _RecordingIOSink();

  /// The signals passed to [kill], in order.
  final List<io.ProcessSignal> signals = [];

  /// Bytes written to [stdin], decoded as UTF-8.
  String get stdinText => utf8.decode(_stdin.bytes);

  void writeStdout(String line) => _stdout.add(utf8.encode('$line\n'));

  void writeStderr(String line) => _stderr.add(utf8.encode('$line\n'));

  /// Ends the process with [code] and closes its output.
  void exit(int code) {
    if (_exitCode.isCompleted) {
      return;
    }
    _stdout.close();
    _stderr.close();
    _exitCode.complete(code);
  }

  @override
  Stream<List<int>> get stdout => _stdout.stream;

  @override
  Stream<List<int>> get stderr => _stderr.stream;

  @override
  io.IOSink get stdin => _stdin;

  @override
  Future<int> get exitCode => _exitCode.future;

  @override
  bool kill([io.ProcessSignal signal = io.ProcessSignal.sigterm]) {
    signals.add(signal);
    if (signal == io.ProcessSignal.sigkill) {
      exit(-9);
    } else if (signal == io.ProcessSignal.sigterm && exitOnSigterm) {
      exit(-15);
    }
    return true;
  }
}

class _RecordingIOSink implements io.IOSink {
  final bytes = <int>[];

  @override
  void add(List<int> data) => bytes.addAll(data);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
