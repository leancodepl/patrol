import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dispose_scope/dispose_scope.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/crossplatform/flutter_tool.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:platform/platform.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';

class _MockIOSink extends Mock implements IOSink {}

void main() {
  const flutterCommand = FlutterCommand('flutter');

  setUpAll(() => registerFallbackValue(<int>[]));

  late FlutterTool flutterTool;
  late MockProcessManager processManager;
  late MockLogger logger;
  late Platform platform;
  late StreamController<List<int>> stdin;

  setUp(() {
    final disposeScope = DisposeScope();
    stdin = StreamController<List<int>>();
    processManager = MockProcessManager();
    logger = MockLogger();
    platform = FakePlatform();

    flutterTool = FlutterTool(
      logger: logger,
      parentDisposeScope: disposeScope,
      processManager: processManager,
      platform: platform,
      stdin: stdin.stream,
    );
  });

  /// Defaults to a process that neither prints anything nor exits.
  MockProcess stubProcess({
    List<String> stdout = const [],
    List<String> stderr = const [],
    Future<int>? exitCode,
  }) {
    final process = MockProcess();
    when(() => process.stdout).thenAnswer(
      (_) =>
          Stream<List<int>>.fromIterable(
            stdout.map((line) => utf8.encode('$line\n')),
          ).asyncMap((chunk) async {
            await Future<void>.delayed(const Duration(milliseconds: 40));
            return chunk;
          }),
    );
    // A process that has already exited still has its last lines in flight.
    when(() => process.stderr).thenAnswer(
      (_) =>
          Stream<List<int>>.fromIterable(
            stderr.map((line) => utf8.encode('$line\n')),
          ).asyncMap((chunk) async {
            await Future<void>.delayed(const Duration(milliseconds: 20));
            return chunk;
          }),
    );
    when(
      () => process.exitCode,
    ).thenAnswer((_) => exitCode ?? Completer<int>().future);
    when(() => processManager.start(any())).thenAnswer((_) async => process);
    // `logs` starts its process with `runInShell`, which is a separate
    // invocation as far as mocktail is concerned.
    when(
      () => processManager.start(any(), runInShell: any(named: 'runInShell')),
    ).thenAnswer((_) async => process);
    return process;
  }

  group('FlutterTool', () {
    test(
      'hotRestart requested before attach completes is queued, then sent',
      () async {
        final process = MockProcess();
        final processStdin = _MockIOSink();
        final processStdout = StreamController<List<int>>();
        when(() => process.stdout).thenAnswer((_) => processStdout.stream);
        when(
          () => process.stderr,
        ).thenAnswer((_) => Stream<List<int>>.fromIterable([]));
        when(() => process.stdin).thenReturn(processStdin);
        when(() => processStdin.add(any())).thenReturn(null);
        when(
          () => processManager.start(any()),
        ).thenAnswer((_) async => process);

        final attach = flutterTool.attach(
          flutterCommand: flutterCommand,
          deviceId: 'testDeviceId',
          target: 'target',
          appId: 'appId',
          dartDefines: {},
          openBrowser: false,
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));

        // Not attached yet: previously this was silently dropped.
        flutterTool.hotRestart();
        verifyNever(() => processStdin.add(any()));

        processStdout.add(utf8.encode('Flutter run key commands.\n'));
        await attach;

        verify(() => processStdin.add('R'.codeUnits)).called(1);
        await processStdout.close();
      },
    );

    test(
      'hotRestart onCompleted fires when the restart completes, not sooner',
      () async {
        final process = MockProcess();
        final processStdin = _MockIOSink();
        final processStdout = StreamController<List<int>>();
        when(() => process.stdout).thenAnswer((_) => processStdout.stream);
        when(
          () => process.stderr,
        ).thenAnswer((_) => Stream<List<int>>.fromIterable([]));
        when(() => process.stdin).thenReturn(processStdin);
        when(() => processStdin.add(any())).thenReturn(null);
        when(
          () => processManager.start(any()),
        ).thenAnswer((_) async => process);

        final attach = flutterTool.attach(
          flutterCommand: flutterCommand,
          deviceId: 'testDeviceId',
          target: 'target',
          appId: 'appId',
          dartDefines: {},
          openBrowser: false,
        );
        processStdout.add(utf8.encode('Flutter run key commands.\n'));
        await attach;

        var completed = false;
        flutterTool.hotRestart(onCompleted: () => completed = true);
        verify(() => processStdin.add('R'.codeUnits)).called(1);
        expect(completed, isFalse);

        processStdout.add(utf8.encode('Restarted application in 1,234ms.\n'));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(completed, isTrue);
        await processStdout.close();
      },
    );
    test(
      'hotRestart onFailed fires when Flutter rejects the restart',
      () async {
        final process = MockProcess();
        final processStdin = _MockIOSink();
        final processStdout = StreamController<List<int>>();
        when(() => process.stdout).thenAnswer((_) => processStdout.stream);
        when(
          () => process.stderr,
        ).thenAnswer((_) => Stream<List<int>>.fromIterable([]));
        when(() => process.stdin).thenReturn(processStdin);
        when(() => processStdin.add(any())).thenReturn(null);
        when(
          () => processManager.start(any()),
        ).thenAnswer((_) async => process);

        final attach = flutterTool.attach(
          flutterCommand: flutterCommand,
          deviceId: 'testDeviceId',
          target: 'target',
          appId: 'appId',
          dartDefines: {},
          openBrowser: false,
        );
        processStdout.add(utf8.encode('Flutter run key commands.\n'));
        await attach;

        var completed = false;
        var failed = false;
        flutterTool.hotRestart(
          onCompleted: () => completed = true,
          onFailed: () => failed = true,
        );

        processStdout.add(
          utf8.encode('Try again after fixing the above error(s).\n'),
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(failed, isTrue);
        expect(completed, isFalse);

        // A later successful restart must not fire the stale callback again.
        processStdout.add(utf8.encode('Restarted application in 1,234ms.\n'));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(completed, isFalse);
        await processStdout.close();
      },
    );
    test('attach passes deviceId correctly', () {
      stubProcess();

      flutterTool.attach(
        flutterCommand: flutterCommand,
        deviceId: 'testDeviceId',
        target: 'target',
        appId: 'appId',
        dartDefines: {},
        openBrowser: false,
      );

      verify(() => processManager.start(any(that: contains('testDeviceId'))));
    });

    // `flutter attach` exits with a usage error on an option it does not
    // define. Check `flutter attach --help` before extending this set.
    test('attach passes only options flutter attach defines', () {
      stubProcess();

      flutterTool.attach(
        flutterCommand: flutterCommand,
        deviceId: 'testDeviceId',
        target: 'target',
        appId: 'appId',
        debugUrl: 'http://127.0.0.1:1234/abc=/',
        dartDefines: {'key': 'value'},
        openBrowser: false,
      );

      final args =
          (verify(() => processManager.start(captureAny())).captured.single
                  as List<Object>)
              .map((arg) => arg.toString());

      expect(args.where((arg) => arg.startsWith('--')).toSet(), {
        '--no-version-check',
        '--suppress-analytics',
        '--debug',
        '--device-id',
        '--debug-url',
        '--app-id',
        '--target',
        '--dart-define',
      });
    });

    // A flavored iOS project cannot run `flutter logs`, so the caller hands
    // attach the Dart VM service URL taken from Patrol's own log stream.
    test(
      'attachForHotRestart uses a provided debug URL instead of flutter logs',
      () async {
        const url = 'http://127.0.0.1:54296/4crAtS2Ux7w=/';
        final process = MockProcess();
        when(() => process.stdout).thenAnswer(
          (_) => Stream<List<int>>.fromIterable([
            utf8.encode('Flutter run key commands.\n'),
          ]),
        );
        when(
          () => process.stderr,
        ).thenAnswer((_) => Stream<List<int>>.fromIterable([]));
        // Awaiting attach to completion disposes its scope, which kills the
        // process.
        when(process.kill).thenReturn(true);
        when(
          () => processManager.start(any()),
        ).thenAnswer((_) async => process);

        // Keep the test independent of the host: attachForHotRestart consults
        // the real stdin for a terminal to switch into raw mode.
        final stdin = MockStdin();
        when(() => stdin.hasTerminal).thenReturn(false);

        await IOOverrides.runZoned(
          () => flutterTool.attachForHotRestart(
            flutterCommand: flutterCommand,
            deviceId: 'testDeviceId',
            target: 'target',
            appId: 'appId',
            dartDefines: {},
            openDevtools: false,
            attachUsingUrl: true,
            debugUrl: Future.value(url),
            forwardFlutterLogs: false,
          ),
          stdin: () => stdin,
        );

        final commands = verify(
          () => processManager.start(captureAny()),
        ).captured.cast<List<Object>>();

        expect(commands, hasLength(1));

        final args = commands.single.map((arg) => arg.toString()).toList();
        expect(args, containsAllInOrder(['attach', '--debug-url', url]));
        expect(args, isNot(contains('logs')));
      },
    );

    test('attach returns and reports why when the process exits', () async {
      stubProcess(
        stderr: ['Could not find an option named "--flavor".'],
        exitCode: Future.value(64),
      );

      await flutterTool.attach(
        flutterCommand: flutterCommand,
        deviceId: 'testDeviceId',
        target: 'target',
        appId: 'appId',
        dartDefines: {},
        openBrowser: false,
      );

      final reported = verify(
        () => logger.err(captureAny()),
      ).captured.map((message) => message.toString()).join('\n');
      expect(reported, contains('Hot Restart is not available'));
      expect(reported, contains('exited with code 64'));
      expect(reported, contains('Could not find an option named "--flavor".'));
    });

    test('logs returns and reports why when the process exits', () async {
      stubProcess(
        stderr: ['You must specify a --flavor option to select one.'],
        exitCode: Future.value(1),
      );

      await flutterTool.logs('testDeviceId', flutterCommand: flutterCommand);

      final reported = verify(
        () => logger.err(captureAny()),
      ).captured.map((message) => message.toString()).join('\n');
      expect(reported, contains('Logs are not available'));
      expect(reported, contains('exited with code 1'));
      expect(reported, contains('You must specify a --flavor option'));
    });

    test('r reports why the attach died', () async {
      stubProcess(
        stderr: ['Could not find an option named "--flavor".'],
        exitCode: Future.value(64),
      );

      await flutterTool.attach(
        flutterCommand: flutterCommand,
        deviceId: 'testDeviceId',
        target: 'target',
        appId: 'appId',
        dartDefines: {},
        openBrowser: false,
      );
      stdin.add('r'.codeUnits);
      await Future<void>.delayed(Duration.zero);

      final warned = verify(
        () => logger.warn(captureAny()),
      ).captured.map((message) => message.toString()).join('\n');
      expect(warned, contains('Hot Restart is not available'));
      expect(warned, isNot(contains('not attached to the app yet')));
    });

    test('logs survives stdout arriving after the process exits', () async {
      stubProcess(stdout: ['Showing logs:'], exitCode: Future.value(1));

      await flutterTool.logs('testDeviceId', flutterCommand: flutterCommand);
      await Future<void>.delayed(const Duration(milliseconds: 80));
    });

    test('logs does not leave the observation URL pending on exit', () async {
      stubProcess(exitCode: Future.value(1));
      final observationUrl = Completer<String>();

      await flutterTool.logs(
        'testDeviceId',
        flutterCommand: flutterCommand,
        observationUrlCompleter: observationUrl,
      );

      await expectLater(observationUrl.future, throwsA(isA<ToolExit>()));
    });
  });

  group('getObservationUrl', () {
    test('extracts URL from line with preceding text', () {
      const line =
          'The Dart VM service is listening on http://127.0.0.1:52263/F2-CH29gR1k=/';
      expect(getObservationUrl(line), 'http://127.0.0.1:52263/F2-CH29gR1k=/');
    });

    test('returns line unchanged when it starts with URL', () {
      const line = 'http://127.0.0.1:9104?uri=http://127.0.0.1:52263/';
      expect(getObservationUrl(line), line);
    });

    test('throws FormatException when line contains no URL', () {
      const line = 'no url here';
      expect(() => getObservationUrl(line), throwsFormatException);
    });
  });

  group('getDevtoolsUrl', () {
    test('old Flutter format - no path before query', () {
      const line =
          'The Flutter DevTools debugger and profiler is available at: '
          'http://127.0.0.1:9104?uri=http://127.0.0.1:52263/F2-CH29gR1k=/';
      expect(
        getDevtoolsUrl(line),
        'http://127.0.0.1:9104/patrol_ext?uri=http://127.0.0.1:52263/F2-CH29gR1k=/',
      );
    });

    test('old Flutter format - slash before query', () {
      const line =
          'The Flutter DevTools debugger and profiler is available at: '
          'http://127.0.0.1:9104/?uri=http://127.0.0.1:52263/F2-CH29gR1k=/';
      expect(
        getDevtoolsUrl(line),
        'http://127.0.0.1:9104/patrol_ext?uri=http://127.0.0.1:52263/F2-CH29gR1k=/',
      );
    });

    test('new Flutter format - DevTools embedded in DDS with ws:// uri', () {
      const line =
          'The Flutter DevTools debugger and profiler is available at: '
          'http://127.0.0.1:57458/q2xYo4wYWtA=/devtools/?uri=ws://127.0.0.1:57458/q2xYo4wYWtA=/ws';
      expect(
        getDevtoolsUrl(line),
        'http://127.0.0.1:57458/q2xYo4wYWtA=/devtools/patrol_ext?uri=ws://127.0.0.1:57458/q2xYo4wYWtA=/ws',
      );
    });

    test(
      'new Flutter format - DevTools embedded in DDS without trailing slash',
      () {
        const line =
            'The Flutter DevTools debugger and profiler is available at: '
            'http://127.0.0.1:57458/q2xYo4wYWtA=/devtools?uri=ws://127.0.0.1:57458/q2xYo4wYWtA=/ws';
        expect(
          getDevtoolsUrl(line),
          'http://127.0.0.1:57458/q2xYo4wYWtA=/devtools/patrol_ext?uri=ws://127.0.0.1:57458/q2xYo4wYWtA=/ws',
        );
      },
    );

    test('produces no double slashes', () {
      const line =
          'http://127.0.0.1:57458/q2xYo4wYWtA=/devtools/?uri=ws://127.0.0.1:57458/q2xYo4wYWtA=/ws';
      final result = getDevtoolsUrl(line);
      final pathPart = Uri.parse(result).path;
      expect(pathPart, isNot(contains('//')));
    });
  });
}
