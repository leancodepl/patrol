import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dispose_scope/dispose_scope.dart';
import 'package:mocktail/mocktail.dart';
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
  late Platform platform;

  setUp(() {
    final disposeScope = DisposeScope();
    final stdin = StreamController<List<int>>();
    processManager = MockProcessManager();
    platform = FakePlatform();

    flutterTool = FlutterTool(
      logger: MockLogger(),
      parentDisposeScope: disposeScope,
      processManager: processManager,
      platform: platform,
      stdin: stdin.stream,
    );
  });

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
    test('attach passes deviceId correctly', () {
      final process = MockProcess();
      when(
        () => process.stdout,
      ).thenAnswer((_) => Stream<List<int>>.fromIterable([]));
      when(
        () => process.stderr,
      ).thenAnswer((_) => Stream<List<int>>.fromIterable([]));
      when(() => processManager.start(any())).thenAnswer((_) async => process);

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
      final process = MockProcess();
      when(
        () => process.stdout,
      ).thenAnswer((_) => Stream<List<int>>.fromIterable([]));
      when(
        () => process.stderr,
      ).thenAnswer((_) => Stream<List<int>>.fromIterable([]));
      when(() => processManager.start(any())).thenAnswer((_) async => process);

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
