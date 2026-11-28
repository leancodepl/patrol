import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:file/memory.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/commands/test_without_building.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart' show BuildMode;
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
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
        macosTestBackend: MockMacOSTestBackend(),
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

  group('TestWithoutBuildingCommand on macOS', () {
    const macos = Device(
      name: 'macOS',
      id: 'macos',
      targetPlatform: TargetPlatform.macOS,
      real: true,
    );

    late MockMacOSTestBackend mockMacosTestBackend;
    late TestWithoutBuildingCommand command;

    setUpAll(() {
      registerFallbackValue(const FlutterCommand('flutter'));
      registerFallbackValue(macos);
      registerFallbackValue(
        MacOSAppOptions(
          flutter: const FlutterAppOptions(
            command: FlutterCommand('flutter'),
            target: '',
            flavor: null,
            buildMode: BuildMode.debug,
            dartDefines: {},
            dartDefineFromFilePaths: [],
            buildName: null,
            buildNumber: null,
          ),
          scheme: 'Runner',
          configuration: 'Debug',
          appServerPort: 0,
          testServerPort: 0,
        ),
      );
    });

    setUp(() {
      final fs = MemoryFileSystem();
      final deviceFinder = MockDeviceFinder();
      final testBundler = MockTestBundler();
      final pubspecReader = MockPubspecReader();
      mockMacosTestBackend = MockMacOSTestBackend();

      when(
        () => deviceFinder.find(
          any(),
          flutterCommand: any(named: 'flutterCommand'),
        ),
      ).thenAnswer((_) async => [macos]);
      when(
        () => testBundler.getBundledTestFile(any()),
      ).thenReturn(fs.file('patrol_test/test_bundle.dart'));
      when(
        pubspecReader.read,
      ).thenReturn(PatrolPubspecConfig.empty(flutterPackageName: 'example'));
      when(
        () => mockMacosTestBackend.execute(
          any(),
          any(),
          onlyTests: any(named: 'onlyTests'),
        ),
      ).thenAnswer((_) async {});

      command = TestWithoutBuildingCommand(
        deviceFinder: deviceFinder,
        testBundler: testBundler,
        pubspecReader: pubspecReader,
        androidTestBackend: MockAndroidTestBackend(),
        iosTestBackend: MockIOSTestBackend(),
        macosTestBackend: mockMacosTestBackend,
        webTestBackend: MockWebTestBackend(),
        fs: fs,
        analytics: MockAnalytics(),
        logger: MockLogger(),
      );
    });

    test('runs the selected tests through the macOS backend', () async {
      final runner = CommandRunner<int>('test', 'Test runner')
        ..argParser.addOption(
          'flutter-command',
          defaultsTo: 'patrol-test-no-flutter',
        )
        ..addCommand(command);

      final exitCode = await runner.run([
        'test-without-building',
        '-d',
        'macos',
        '--only',
        'example_test taps',
      ]);

      expect(exitCode, 0);
      final options =
          verify(
                () => mockMacosTestBackend.execute(
                  captureAny(),
                  macos,
                  onlyTests: ['example_test taps'],
                ),
              ).captured.single
              as MacOSAppOptions;
      expect(options.emitTestManifest, isTrue);
    });
  });
}
