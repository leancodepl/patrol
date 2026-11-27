import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dispose_scope/dispose_scope.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/crossplatform/flutter_tool.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:platform/testing.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';

class _MockIOSink extends Mock implements IOSink {}

void main() {
  const flutterCommand = FlutterCommand('flutter');

  setUpAll(() => registerFallbackValue(<int>[]));

  late FlutterTool flutterTool;
  late MockProcessManager processManager;
  late NativePlatform platform;
  late DisposeScope disposeScope;

  setUp(() {
    disposeScope = DisposeScope();
    final stdin = StreamController<List<int>>();
    processManager = MockProcessManager();
    platform = TestNativePlatform();

    flutterTool = FlutterTool(
      logger: MockLogger(),
      parentDisposeScope: disposeScope,
      processManager: processManager,
      platform: platform,
      stdin: stdin.stream,
      onExit: () async {},
    );
  });

  group('FlutterTool', () {
    test('attach runs in the project, not in the process directory', () async {
      final process = MockProcess();
      when(
        () => process.stdout,
      ).thenAnswer((_) => const Stream<List<int>>.empty());
      when(
        () => process.stderr,
      ).thenAnswer((_) => const Stream<List<int>>.empty());
      _stubStart(processManager, process);
      final inProject = FlutterTool(
        logger: MockLogger(),
        parentDisposeScope: DisposeScope(),
        processManager: processManager,
        platform: platform,
        stdin: const Stream<List<int>>.empty(),
        onExit: () async {},
        projectRoot: '/projects/app',
      );

      // attach only returns once the app is attached, which no stub does.
      unawaited(
        inProject.attach(
          flutterCommand: flutterCommand,
          deviceId: 'testDeviceId',
          target: 'target',
          appId: 'appId',
          dartDefines: {},
          openBrowser: false,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      verify(
        () => processManager.start(any(), workingDirectory: '/projects/app'),
      );
    });

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
        when(() => process.exitCode).thenAnswer((_) => Completer<int>().future);
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
        when(() => process.exitCode).thenAnswer((_) => Completer<int>().future);
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

    test('a second q while quitting does not clean up again', () async {
      final keys = StreamController<List<int>>();
      var exits = 0;
      final tool = FlutterTool(
        logger: MockLogger(),
        parentDisposeScope: DisposeScope(),
        processManager: processManager,
        platform: platform,
        stdin: keys.stream,
        onExit: () async => exits++,
      );
      final process = MockProcess();
      final processStdout = StreamController<List<int>>();
      when(() => process.stdout).thenAnswer((_) => processStdout.stream);
      when(
        () => process.stderr,
      ).thenAnswer((_) => Stream<List<int>>.fromIterable([]));
      when(() => process.exitCode).thenAnswer((_) => Completer<int>().future);
      when(() => processManager.start(any())).thenAnswer((_) async => process);

      var quits = 0;
      final quitting = Completer<void>();
      final attach = tool.attach(
        flutterCommand: flutterCommand,
        deviceId: 'testDeviceId',
        target: 'target',
        appId: 'appId',
        dartDefines: {},
        openBrowser: false,
        onQuit: () async {
          quits++;
          await quitting.future;
        },
      );
      processStdout.add(utf8.encode('Flutter run key commands.\n'));
      await attach;

      keys
        ..add('q'.codeUnits)
        ..add('q'.codeUnits);
      await pumpEventQueue();
      quitting.complete();
      await pumpEventQueue();

      expect(quits, 1);
      expect(exits, 1);
      await processStdout.close();
      await keys.close();
    });

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
        when(() => process.exitCode).thenAnswer((_) => Completer<int>().future);
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
    test('attach passes deviceId correctly', () async {
      final process = MockProcess();
      when(
        () => process.stdout,
      ).thenAnswer((_) => Stream<List<int>>.fromIterable([]));
      when(
        () => process.stderr,
      ).thenAnswer((_) => Stream<List<int>>.fromIterable([]));
      _stubStart(processManager, process);

      unawaited(
        flutterTool.attach(
          flutterCommand: flutterCommand,
          deviceId: 'testDeviceId',
          target: 'target',
          appId: 'appId',
          dartDefines: {},
          openBrowser: false,
        ),
      );
      await untilCalled(() => processManager.start(any()));

      verify(() => processManager.start(any(that: contains('testDeviceId'))));
    });

    // `flutter attach` exits with a usage error on an option it does not
    // define. Check `flutter attach --help` before extending this set.
    test('attach passes only options flutter attach defines', () async {
      final process = MockProcess();
      when(
        () => process.stdout,
      ).thenAnswer((_) => Stream<List<int>>.fromIterable([]));
      when(
        () => process.stderr,
      ).thenAnswer((_) => Stream<List<int>>.fromIterable([]));
      _stubStart(processManager, process);

      unawaited(
        flutterTool.attach(
          flutterCommand: flutterCommand,
          deviceId: 'testDeviceId',
          target: 'target',
          appId: 'appId',
          debugUrl: 'http://127.0.0.1:1234/abc=/',
          dartDefines: {'key': 'value'},
          openBrowser: false,
        ),
      );
      await untilCalled(() => processManager.start(any()));

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
        when(() => process.exitCode).thenAnswer((_) => Completer<int>().future);
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

    test(
      'hotRestartReady completes once attach announces its key commands',
      () async {
        _stubAttach(processManager, stdoutLines: ['Flutter run key commands.']);

        await flutterTool.attach(
          flutterCommand: flutterCommand,
          deviceId: 'testDeviceId',
          target: 'target',
          appId: 'appId',
          dartDefines: {},
          openBrowser: false,
        );

        await expectLater(flutterTool.hotRestartReady, completes);
      },
    );

    test(
      'hotRestartReady stays pending while attach is still starting up',
      () async {
        _stubAttach(
          processManager,
          stdoutLines: ['Syncing files to device...'],
        );

        unawaited(
          flutterTool.attach(
            flutterCommand: flutterCommand,
            deviceId: 'testDeviceId',
            target: 'target',
            appId: 'appId',
            dartDefines: {},
            openBrowser: false,
          ),
        );

        // A hot restart requested in this window is only queued, so callers
        // must not read a pending future as readiness.
        await expectLater(
          flutterTool.hotRestartReady.timeout(
            const Duration(milliseconds: 200),
          ),
          throwsA(isA<TimeoutException>()),
        );
      },
    );
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

  group('adb forwards left by attach', () {
    late StreamController<List<int>> attachStdout;

    /// A finished adb run that printed [stdout], or one that never finishes.
    MockProcess adbRun({String stdout = '', bool hangs = false}) {
      final process = MockProcess();
      when(process.kill).thenReturn(true);
      when(
        () => process.stdout,
      ).thenAnswer((_) => Stream.value(utf8.encode(stdout)));
      when(
        () => process.stderr,
      ).thenAnswer((_) => const Stream<List<int>>.empty());
      when(
        () => process.exitCode,
      ).thenAnswer((_) => hangs ? Completer<int>().future : Future.value(0));
      return process;
    }

    /// A `flutter attach` that stays up until the scope is disposed and
    /// connects when the test writes its key commands to [attachStdout].
    void stubAttachProcess() {
      attachStdout = StreamController<List<int>>();
      final process = MockProcess();
      when(() => process.pid).thenReturn(424242);
      when(process.kill).thenReturn(true);
      when(() => process.stdout).thenAnswer((_) => attachStdout.stream);
      when(
        () => process.stderr,
      ).thenAnswer((_) => const Stream<List<int>>.empty());
      when(() => process.exitCode).thenAnswer((_) => Completer<int>().future);
      when(
        () => processManager.start(any(that: contains('attach'))),
      ).thenAnswer((_) async => process);
    }

    void stubForwardRemoval() {
      when(
        () => processManager.start(any(that: contains('--remove'))),
      ).thenAnswer((_) async => adbRun());
    }

    Future<void> attachAndConnect({required bool removeAdbForwards}) async {
      unawaited(
        flutterTool.attach(
          flutterCommand: flutterCommand,
          deviceId: 'emulator-5554',
          target: 'target',
          appId: 'appId',
          dartDefines: {},
          openBrowser: false,
          removeAdbForwards: removeAdbForwards,
        ),
      );
      await untilCalled(
        () => processManager.start(any(that: contains('attach'))),
      );
      attachStdout.add(utf8.encode('Flutter run key commands.\n'));
      await pumpEventQueue();
    }

    test('removes the ones attach added before it connected', () async {
      stubAttachProcess();
      stubForwardRemoval();
      const attachAdded =
          'emulator-5554 tcp:8081 tcp:8081\n'
          'emulator-5554 tcp:62910 tcp:33925\n'
          'emulator-5554 tcp:9000 tcp:9000\n'
          'emulator-5554 tcp:9222 localabstract:chrome_devtools_remote\n'
          'other-device tcp:1 tcp:2\n';
      final listings = ['emulator-5554 tcp:8081 tcp:8081\n', attachAdded];
      when(
        () => processManager.start(['adb', 'forward', '--list']),
      ).thenAnswer((_) async => adbRun(stdout: listings.removeAt(0)));

      await attachAndConnect(removeAdbForwards: true);
      await disposeScope.dispose();

      verify(
        () => processManager.start([
          'adb',
          '-s',
          'emulator-5554',
          'forward',
          '--remove',
          'tcp:62910',
        ]),
      ).called(1);
      verifyNever(() => processManager.start(any(that: contains('tcp:9000'))));
      verifyNever(() => processManager.start(any(that: contains('tcp:9222'))));
      verifyNever(() => processManager.start(any(that: contains('tcp:1'))));
      // Quitting removes the recorded set without listing again.
      expect(listings, isEmpty);
    });

    test('leaves forwards alone when not asked to', () async {
      stubAttachProcess();

      await attachAndConnect(removeAdbForwards: false);
      await disposeScope.dispose();

      verifyNever(() => processManager.start(any(that: contains('adb'))));
    });

    test('is a no-op when adb is not there', () async {
      stubAttachProcess();
      when(
        () => processManager.start(['adb', 'forward', '--list']),
      ).thenThrow(const ProcessException('adb', ['forward', '--list']));

      await attachAndConnect(removeAdbForwards: true);
      await disposeScope.dispose();

      verifyNever(() => processManager.start(any(that: contains('--remove'))));
    });

    test('kills an adb that hangs and attaches anyway', () async {
      final tool = FlutterTool(
        logger: MockLogger(),
        parentDisposeScope: disposeScope,
        processManager: processManager,
        platform: platform,
        stdin: const Stream<List<int>>.empty(),
        onExit: () async {},
        adbTimeout: const Duration(milliseconds: 10),
      );
      stubAttachProcess();
      final hung = adbRun(hangs: true);
      when(
        () => processManager.start(['adb', 'forward', '--list']),
      ).thenAnswer((_) async => hung);

      unawaited(
        tool.attach(
          flutterCommand: flutterCommand,
          deviceId: 'emulator-5554',
          target: 'target',
          appId: 'appId',
          dartDefines: {},
          openBrowser: false,
          removeAdbForwards: true,
        ),
      );
      await untilCalled(
        () => processManager.start(any(that: contains('attach'))),
      );

      verify(hung.kill).called(1);
    });
  });
}

/// Answers `start` whatever working directory it is given.
void _stubStart(MockProcessManager processManager, MockProcess process) {
  when(() => process.exitCode).thenAnswer((_) => Completer<int>().future);
  when(
    () => processManager.start(
      any(),
      workingDirectory: any(named: 'workingDirectory'),
    ),
  ).thenAnswer((_) async => process);
  when(
    () => processManager.start(
      any(),
      runInShell: any(named: 'runInShell'),
      workingDirectory: any(named: 'workingDirectory'),
    ),
  ).thenAnswer((_) async => process);
}

/// Stubs a spawned process whose stdout replays [stdoutLines].
void _stubAttach(
  MockProcessManager processManager, {
  required List<String> stdoutLines,
}) {
  final process = MockProcess();
  when(() => process.stdout).thenAnswer(
    (_) => Stream<List<int>>.fromIterable([
      for (final line in stdoutLines) utf8.encode('$line\n'),
    ]),
  );
  when(() => process.stderr).thenAnswer((_) => const Stream<List<int>>.empty());
  _stubStart(processManager, process);
}
