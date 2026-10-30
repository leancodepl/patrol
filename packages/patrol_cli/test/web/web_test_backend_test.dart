import 'dart:async';
import 'dart:io';

import 'package:dispose_scope/dispose_scope.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
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

void main() {
  setUpAll(() => registerFallbackValue(ProcessSignal.sigterm));

  group('WebTestBackend.execute', () {
    late DisposeScope parentDisposeScope;
    late MockProcessManager processManager;
    late MockProcess flutterProcess;
    late Completer<int> flutterExitCode;
    late WebTestBackend webTestBackend;

    setUp(() {
      parentDisposeScope = DisposeScope();
      processManager = MockProcessManager();
      flutterProcess = MockProcess();
      flutterExitCode = Completer<int>();
      final logger = MockLogger();
      when(() => logger.info(any())).thenReturn(null);
      when(() => logger.detail(any())).thenReturn(null);

      when(
        () => processManager.start(any()),
      ).thenAnswer((_) async => flutterProcess);
      when(() => flutterProcess.stdout).thenAnswer((_) => const Stream.empty());
      when(() => flutterProcess.stderr).thenAnswer((_) => const Stream.empty());
      when(
        () => flutterProcess.exitCode,
      ).thenAnswer((_) => flutterExitCode.future);
      when(() => flutterProcess.kill(any())).thenAnswer((invocation) {
        final signal = invocation.positionalArguments.first as ProcessSignal;
        if (!flutterExitCode.isCompleted) {
          flutterExitCode.complete(-signal.signalNumber);
        }
        return true;
      });

      webTestBackend = WebTestBackend(
        processManager: processManager,
        parentDisposeScope: parentDisposeScope,
        logger: logger,
      );
    });

    test(
      'stops the Flutter web server when interrupted while it builds',
      () async {
        final execution = webTestBackend.execute(_options, _webDevice);
        await untilCalled(() => processManager.start(any()));

        await parentDisposeScope.dispose();

        await expectLater(execution, throwsA(isA<ToolInterrupted>()));
        verify(() => flutterProcess.kill(any())).called(greaterThan(0));
        verify(() => processManager.start(any())).called(1);
      },
    );

    test('does not start the Flutter web server when interrupted before '
        'execution', () async {
      await parentDisposeScope.dispose();

      await expectLater(
        webTestBackend.execute(_options, _webDevice),
        throwsA(isA<ToolInterrupted>()),
      );
      verifyNever(() => processManager.start(any()));
    });

    test('fails when Flutter exits with code 0 before serving', () async {
      final execution = webTestBackend.execute(_options, _webDevice);
      await untilCalled(() => processManager.start(any()));

      flutterExitCode.complete(0);

      await expectLater(
        execution,
        throwsA(contains('Flutter process exited unexpectedly with code 0')),
      );
    });
  });
}
