import 'dart:async';
import 'dart:convert';

import 'package:dispose_scope/dispose_scope.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/crossplatform/flutter_tool.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:platform/platform.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';

void main() {
  const flutterCommand = FlutterCommand('flutter');

  late FlutterTool flutterTool;
  late MockProcessManager processManager;
  late MockLogger logger;
  late Platform platform;

  setUp(() {
    final disposeScope = DisposeScope();
    final stdin = StreamController<List<int>>();
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
    List<String> stderr = const [],
    Future<int>? exitCode,
  }) {
    final process = MockProcess();
    when(
      () => process.stdout,
    ).thenAnswer((_) => Stream<List<int>>.fromIterable([]));
    when(() => process.stderr).thenAnswer(
      (_) => Stream<List<int>>.fromIterable(
        stderr.map((line) => utf8.encode('$line\n')),
      ),
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
    });

    test('logs does not leave the observation URL pending on exit', () async {
      stubProcess(exitCode: Future.value(1));
      final observationUrl = Completer<String>();

      await flutterTool.logs(
        'testDeviceId',
        flutterCommand: flutterCommand,
        observationUrlCompleter: observationUrl,
      );

      await expectLater(observationUrl.future, throwsStateError);
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
