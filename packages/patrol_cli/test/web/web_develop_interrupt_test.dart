import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dispose_scope/dispose_scope.dart';
import 'package:mason_logger/mason_logger.dart' show Level;
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/crossplatform/flutter_tool.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:patrol_cli/src/web/web_test_backend.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';

const _webDevice = Device(
  name: 'Chrome',
  id: 'chrome',
  targetPlatform: TargetPlatform.web,
  real: false,
);

const _options = WebAppOptions(
  flutter: FlutterAppOptions(
    command: FlutterCommand('flutter'),
    target: 'patrol_test/app_test.dart',
    buildMode: BuildMode.debug,
    flavor: null,
    buildName: null,
    buildNumber: null,
    dartDefines: {},
    dartDefineFromFilePaths: [],
  ),
);

/// Above any PID an OS hands out, so a tree kill of it reaches no real process.
const _unusedPid = 999999999;

void main() {
  setUpAll(() => registerFallbackValue(ProcessSignal.sigterm));

  group('WebTestBackend.develop', () {
    late DisposeScope parentDisposeScope;
    late MockProcessManager processManager;
    late MockFlutterTool flutterTool;
    late MockLogger logger;
    late Completer<int> flutterExitCode;
    late StreamController<List<int>> flutterStdout;
    late MockProcess flutterProcess;
    late WebTestBackend webTestBackend;
    late Directory projectDir;

    Future<Process> startFlutter() =>
        processManager.start(any(that: contains('run')));

    Future<Process> startInstall() => processManager.start(
      any(that: contains('install')),
      workingDirectory: any(named: 'workingDirectory'),
      runInShell: any(named: 'runInShell'),
    );

    Future<Process> startDriver() => processManager.start(
      any(that: contains('ts-node')),
      workingDirectory: any(named: 'workingDirectory'),
      environment: any(named: 'environment'),
      runInShell: any(named: 'runInShell'),
    );

    Future<void> develop() => IOOverrides.runZoned(
      () => webTestBackend.develop(
        flutterTool,
        _options,
        _webDevice,
        stdin: const Stream.empty(),
      ),
      getCurrentDirectory: () => projectDir,
    );

    /// Answers Chrome's DevTools endpoints on the port `flutter run` was
    /// given, and has `flutter run` report its debug service.
    Future<Process> serveChrome(Invocation invocation) async {
      final args = invocation.positionalArguments.first as List<Object>;
      final port = int.parse(
        args
            .whereType<String>()
            .firstWhere((arg) => arg.startsWith('--web-browser-debug-port='))
            .split('=')
            .last,
      );
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
      addTearDown(() => server.close(force: true));
      server.listen((request) {
        request.response
          ..write(request.uri.path == '/json' ? '[]' : '{}')
          ..close();
      });
      flutterStdout.add(
        utf8.encode('Debug service listening on ws://127.0.0.1:1/x=/ws\n'),
      );
      return flutterProcess;
    }

    setUp(() {
      parentDisposeScope = DisposeScope();
      processManager = MockProcessManager();
      flutterTool = MockFlutterTool();
      when(
        () => flutterTool.enableInteractiveMode(),
      ).thenReturn(StdinModes(echoMode: true, lineMode: true));

      logger = MockLogger();
      when(() => logger.level).thenReturn(Level.info);
      projectDir = _createProject();

      flutterExitCode = Completer<int>();
      flutterStdout = StreamController<List<int>>();
      flutterProcess = _fakeProcess(
        flutterExitCode,
        stdout: flutterStdout.stream,
      );

      webTestBackend = WebTestBackend(
        processManager: processManager,
        parentDisposeScope: parentDisposeScope,
        logger: logger,
      );
    });

    test('does not start Flutter when interrupted before develop', () async {
      await parentDisposeScope.dispose();

      await expectLater(develop(), throwsA(isA<ToolInterrupted>()));
      verifyNever(startFlutter);
    });

    test('kills Flutter when interrupted while it starts', () async {
      final flutterStarted = Completer<Process>();
      when(startFlutter).thenAnswer((_) => flutterStarted.future);
      final session = develop();
      await untilCalled(startFlutter);

      await parentDisposeScope.dispose();
      flutterStarted.complete(flutterProcess);

      await expectLater(session, throwsA(isA<ToolInterrupted>()));
      verify(() => flutterProcess.kill(any())).called(greaterThan(0));
      verifyNever(() => flutterProcess.kill(ProcessSignal.sigkill));
    });

    test(
      'kills Flutter when interrupted while waiting for the Chrome debugger',
      () async {
        when(startFlutter).thenAnswer((_) async => flutterProcess);
        final session = develop();
        await untilCalled(
          () => logger.detail(any(that: startsWith('Waiting for debugger'))),
        );
        final interrupted = expectLater(
          session,
          throwsA(isA<ToolInterrupted>()),
        );

        await parentDisposeScope.dispose();

        await interrupted;
        verify(() => flutterProcess.kill(any())).called(greaterThan(0));
        verifyNever(() => flutterProcess.kill(ProcessSignal.sigkill));
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    test(
      'kills the dependency install when interrupted',
      () async {
        when(startFlutter).thenAnswer(serveChrome);
        final installExitCode = Completer<int>();
        final installProcess = _fakeProcess(installExitCode);
        when(startInstall).thenAnswer((_) async => installProcess);
        final session = develop();
        await untilCalled(startInstall);
        final interrupted = expectLater(
          session,
          throwsA(isA<ToolInterrupted>()),
        );

        await parentDisposeScope.dispose();

        await interrupted;
        verify(() => installProcess.kill(any())).called(greaterThan(0));
        verify(() => flutterProcess.kill(any())).called(greaterThan(0));
        verifyNever(() => flutterProcess.kill(ProcessSignal.sigkill));
        verifyNever(startDriver);
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    test(
      'kills the Playwright driver when interrupted while it starts',
      () async {
        when(startFlutter).thenAnswer(serveChrome);
        when(
          startInstall,
        ).thenAnswer((_) async => _fakeProcess(Completer<int>()..complete(0)));
        final driverStarted = Completer<Process>();
        when(startDriver).thenAnswer((_) => driverStarted.future);
        final driverProcess = _fakeProcess(Completer<int>());
        final session = develop();
        await untilCalled(startDriver);

        await parentDisposeScope.dispose();
        driverStarted.complete(driverProcess);

        await expectLater(session, throwsA(isA<ToolInterrupted>()));
        verify(() => driverProcess.kill(any())).called(greaterThan(0));
        verify(() => driverProcess.pid);
        verify(() => flutterProcess.kill(any())).called(greaterThan(0));
        verifyNever(() => flutterProcess.kill(ProcessSignal.sigkill));
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    test('ends the session and kills Flutter and the driver when interrupted '
        'after attach', () async {
      when(startFlutter).thenAnswer(serveChrome);
      when(
        startInstall,
      ).thenAnswer((_) async => _fakeProcess(Completer<int>()..complete(0)));
      final driverProcess = _fakeProcess(Completer<int>());
      when(startDriver).thenAnswer((_) async => driverProcess);
      final session = develop();
      await webTestBackend.hotRestartReady;

      await parentDisposeScope.dispose();

      await expectLater(session, completes);
      verify(() => driverProcess.kill(any())).called(greaterThan(0));
      verify(() => driverProcess.pid);
      verify(() => flutterProcess.kill(any())).called(greaterThan(0));
      verifyNever(() => flutterProcess.kill(ProcessSignal.sigkill));
      verifyNever(() => logger.err(any()));
    }, timeout: const Timeout(Duration(seconds: 30)));
  });
}

/// A project whose package config resolves `patrol` to a web_runner with the
/// files the backend requires.
Directory _createProject() {
  final dir = Directory.systemTemp.createTempSync('patrol_web_develop_');
  addTearDown(() => dir.deleteSync(recursive: true));
  for (final file in [
    'package.json',
    'playwright.config.ts',
    'tests/test.spec.ts',
    'tests/develop.ts',
  ]) {
    File('${dir.path}/patrol/web_runner/$file').createSync(recursive: true);
  }
  File('${dir.path}/.dart_tool/package_config.json')
    ..createSync(recursive: true)
    ..writeAsStringSync(
      jsonEncode({
        'configVersion': 2,
        'packages': [
          {
            'name': 'patrol',
            'rootUri': Directory('${dir.path}/patrol').uri.toString(),
            'packageUri': 'lib/',
          },
        ],
      }),
    );
  return dir;
}

/// A process that exits when killed, with the signal's negated number as its
/// exit code.
MockProcess _fakeProcess(Completer<int> exitCode, {Stream<List<int>>? stdout}) {
  final process = MockProcess();
  when(() => process.pid).thenReturn(_unusedPid);
  when(() => process.stdout).thenAnswer((_) => stdout ?? const Stream.empty());
  when(() => process.stderr).thenAnswer((_) => const Stream.empty());
  // A sink whose stream nobody listens to never completes a flush.
  final stdin = StreamController<List<int>>()..stream.listen((_) {});
  when(() => process.stdin).thenReturn(IOSink(stdin.sink));
  when(() => process.exitCode).thenAnswer((_) => exitCode.future);
  when(() => process.kill(any())).thenAnswer((invocation) {
    final signal = invocation.positionalArguments.first as ProcessSignal;
    if (!exitCode.isCompleted) {
      exitCode.complete(-signal.signalNumber);
    }
    return true;
  });
  return process;
}
