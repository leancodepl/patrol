import 'package:args/command_runner.dart';
import 'package:file/memory.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/analytics/analytics.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/commands/test_without_building.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart' show BuildMode;
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';

void main() {
  group('TestWithoutBuildingCommand', () {
    late MockDeviceFinder deviceFinder;
    late MockTestBundler testBundler;
    late MockPubspecReader pubspecReader;
    late MockIOSTestBackend iosTestBackend;
    late MockLogger logger;

    const iosSimulator = Device(
      name: 'iPhone 16',
      id: 'simulator-id',
      targetPlatform: TargetPlatform.iOS,
      real: false,
    );

    setUpAll(() {
      registerFallbackValue(
        IOSAppOptions(
          flutter: const FlutterAppOptions(
            command: FlutterCommand('flutter'),
            target: 'patrol_test/test_bundle.dart',
            flavor: null,
            buildMode: BuildMode.debug,
            dartDefines: {},
            dartDefineFromFilePaths: [],
            buildName: null,
            buildNumber: null,
          ),
          bundleId: 'com.example.app',
          scheme: 'Runner',
          configuration: 'Debug',
          simulator: true,
          osVersion: 'latest',
          appServerPort: 8082,
          testServerPort: 8081,
        ),
      );
      registerFallbackValue(iosSimulator);
      registerFallbackValue(const FlutterCommand('flutter'));
    });

    setUp(() {
      deviceFinder = MockDeviceFinder();
      testBundler = MockTestBundler();
      pubspecReader = MockPubspecReader();
      iosTestBackend = MockIOSTestBackend();
      logger = MockLogger();

      when(() => logger.detail(any())).thenReturn(null);
      when(() => logger.info(any())).thenReturn(null);
      when(() => logger.err(any())).thenReturn(null);
      when(
        pubspecReader.read,
      ).thenReturn(PatrolPubspecConfig.empty(flutterPackageName: 'test_app'));
      when(
        () => testBundler.getBundledTestFile(any()),
      ).thenReturn(MemoryFileSystem().file('patrol_test/test_bundle.dart'));
      when(
        () => deviceFinder.find(
          any(),
          flutterCommand: any(named: 'flutterCommand'),
        ),
      ).thenAnswer((_) async => [iosSimulator]);
    });

    Future<int?> run(List<String> args) {
      final runner = CommandRunner<int>('patrol', 'Test runner');
      addGlobalFlags(runner.argParser);
      runner.addCommand(
        TestWithoutBuildingCommand(
          deviceFinder: deviceFinder,
          testBundler: testBundler,
          pubspecReader: pubspecReader,
          androidTestBackend: MockAndroidTestBackend(),
          iosTestBackend: iosTestBackend,
          analytics: MockAnalytics(),
          logger: logger,
          readFlutterVersion: (_) => FlutterVersion('3.38.0', 'stable'),
        ),
      );
      return runner.run(['test-without-building', ...args]);
    }

    test('rethrows an interrupt with exit code 130 and no bug report '
        'message', () async {
      when(
        () => iosTestBackend.execute(
          any(),
          any(),
          showFlutterLogs: any(named: 'showFlutterLogs'),
          hideTestSteps: any(named: 'hideTestSteps'),
          clearTestSteps: any(named: 'clearTestSteps'),
          onlyTests: any(named: 'onlyTests'),
        ),
      ).thenThrow(const ToolInterrupted('xcodebuild'));

      await expectLater(
        run(['--bundle-id', 'com.example.app']),
        throwsA(
          isA<ToolInterrupted>().having(
            (err) => err.exitCode,
            'exitCode',
            exitCodeInterrupted,
          ),
        ),
      );

      verifyNever(() => logger.err(any(that: contains('please report it'))));
    });
  });
}
