import 'dart:async';

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
