import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:file/memory.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/commands/test_without_building.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';

void main() {
  group('TestWithoutBuildingCommand with --input', () {
    late MockLogger mockLogger;
    late MockWebTestBackend mockWebTestBackend;
    late TestWithoutBuildingCommand command;

    setUp(() {
      final fs = MemoryFileSystem();
      fs.file('build/patrol-web/app/index.html').createSync(recursive: true);
      fs
          .file('build/patrol-web/runner/package.json')
          .createSync(recursive: true);

      mockLogger = MockLogger();
      mockWebTestBackend = MockWebTestBackend();
      when(() => mockLogger.err(any())).thenReturn(null);
      when(() => mockLogger.detail(any())).thenReturn(null);

      command = TestWithoutBuildingCommand(
        deviceFinder: MockDeviceFinder(),
        testBundler: MockTestBundler(),
        pubspecReader: MockPubspecReader(),
        androidTestBackend: MockAndroidTestBackend(),
        iosTestBackend: MockIOSTestBackend(),
        webTestBackend: mockWebTestBackend,
        fs: fs,
        analytics: MockAnalytics(),
        logger: mockLogger,
      );
    });

    Future<int> runCommand(List<String> args) async {
      final runner = CommandRunner<int>('test', 'Test runner')
        // A missing binary keeps the analytics version probe from running flutter.
        ..argParser.addOption(
          'flutter-command',
          defaultsTo: 'patrol-test-no-flutter',
        )
        ..addCommand(command);

      return await runner.run([
            'test-without-building',
            '--input',
            'build/patrol-web',
            ...args,
          ]) ??
          0;
    }

    test('rejects --only instead of running the whole artifact', () async {
      final exitCode = await runCommand(['--only', 'app_test logs in']);

      expect(exitCode, 1);
      verify(
        () => mockLogger.err(any(that: startsWith('--only is not supported'))),
      ).called(1);
      verifyZeroInteractions(mockWebTestBackend);
    });

    test('reports a busy --web-port instead of crashing', () async {
      final busy = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(busy.close);

      final exitCode = await runCommand(['--web-port', '${busy.port}']);

      expect(exitCode, 1);
      verify(() => mockLogger.err(any(that: contains('SocketException'))));
      verifyZeroInteractions(mockWebTestBackend);
    });

    test('rejects --device, which a web artifact has no use for', () async {
      final exitCode = await runCommand(['--device', 'chrome']);

      expect(exitCode, 1);
      verify(
        () => mockLogger.err(any(that: startsWith('--device does not apply'))),
      ).called(1);
      verifyZeroInteractions(mockWebTestBackend);
    });
  });
}
