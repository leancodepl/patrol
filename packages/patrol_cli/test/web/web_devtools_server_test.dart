import 'dart:async';
import 'dart:io';

import 'package:dispose_scope/dispose_scope.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:patrol_cli/src/web/web_devtools_server.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';

void main() {
  group('WebDevtoolsServer', () {
    late MockProcessManager processManager;
    late MockLogger logger;
    late DisposeScope disposeScope;

    setUpAll(() {
      registerFallbackValue(<Object>[]);
      registerFallbackValue(ProcessSignal.sigterm);
    });

    setUp(() {
      processManager = MockProcessManager();
      logger = MockLogger();
      disposeScope = DisposeScope();
    });

    /// A process that prints nothing until it is killed.
    MockProcess silentProcess() {
      final process = MockProcess();
      final exitCode = Completer<int>();
      final stdout = StreamController<List<int>>();
      when(() => process.stdout).thenAnswer((_) => stdout.stream);
      when(() => process.stderr).thenAnswer((_) => const Stream.empty());
      when(() => process.exitCode).thenAnswer((_) => exitCode.future);
      // No real process has this PID, so killing its tree reaches nothing else.
      when(() => process.pid).thenReturn(999999999);
      when(() => process.kill(any())).thenAnswer((_) {
        if (!exitCode.isCompleted) {
          exitCode.complete(-15);
          unawaited(stdout.close());
        }
        return true;
      });
      return process;
    }

    Future<String?> serve() =>
        WebDevtoolsServer(
          processManager: processManager,
          logger: logger,
          disposeScope: disposeScope,
        ).serve(
          flutterCommand: const FlutterCommand('flutter'),
          projectRoot: Directory.systemTemp.path,
        );

    test(
      'stops waiting for the tooling daemon once the session ends',
      () async {
        final process = silentProcess();
        when(
          () => processManager.start(any()),
        ).thenAnswer((_) async => process);

        final served = serve();
        await untilCalled(() => processManager.start(any()));
        await disposeScope.dispose();

        expect(await served.timeout(const Duration(seconds: 5)), isNull);
      },
    );

    test('starts nothing once the session has ended', () async {
      await disposeScope.dispose();

      expect(await serve(), isNull);
      verifyNever(() => processManager.start(any()));
    });
  });
}
