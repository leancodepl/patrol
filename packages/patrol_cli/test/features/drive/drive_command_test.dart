import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/features/drive/drive_command.dart';
import 'package:patrol_cli/src/features/drive/flutter_tool.dart';
import 'package:patrol_cli/src/features/drive/test_runner.dart';
import 'package:patrol_cli/src/features/run_commons/dart_defines_reader.dart';
import 'package:patrol_cli/src/features/run_commons/test_finder.dart';
import 'package:test/test.dart';

import '../../fakes.dart';
import '../../fixtures.dart';
import '../../mocks.dart';

const _defaultConfig = DriveCommandConfig(
  targets: [],
  devices: [androidDevice],
  host: 'localhost',
  port: '8081',
  driver: 'test_driver/integration_test.dart',
  flavor: null,
  dartDefines: {'PATROL_WAIT': '0', 'PATROL_VERBOSE': 'false'},
  packageName: null,
  bundleId: null,
  repeat: 1,
  useApplicationBinary: null,
  displayLabel: true,
);

void main() {
  setUpFakes();

  late DriveCommand driveCommand;
  late FileSystem fs;
  late FlutterTool flutterTool;

  group('drive command', () {
    setUp(() {
      final parentDisposeScope = DisposeScope();

      fs = MemoryFileSystem.test();
      final wd = fs.directory('/projects/awesome_app')
        ..createSync(recursive: true);
      fs.currentDirectory = wd;
      final integrationTestDir = fs.directory('integration_test')..createSync();

      final deviceFinder = MockDeviceFinder();
      when(
        () => deviceFinder.find(any()),
      ).thenAnswer((_) async => [androidDevice]);

      final testFinder = TestFinder(
        integrationTestDir: fs.directory(integrationTestDir),
        fs: fs,
      );

      final androidDriver = MockAndroidDriver();
      when(
        () => androidDriver.run(
          port: any(named: 'port'),
          device: any(named: 'device'),
          flavor: any(named: 'flavor'),
        ),
      ).thenAnswer((_) async {});

      final iosDriver = MockIOSDriver();
      flutterTool = MockFlutterTool();
      when(() => flutterTool.build(any(), any())).thenAnswer((_) async {});

      driveCommand = DriveCommand(
        deviceFinder: deviceFinder,
        testFinder: testFinder,
        iosDriver: iosDriver,
        androidDriver: androidDriver,
        flutterTool: flutterTool,
        testRunner: TestRunner(),
        dartDefinesReader: DartDefinesReader(
          fs: fs,
          projectRoot: fs.currentDirectory,
        ),
        parentDisposeScope: parentDisposeScope,
        logger: MockLogger(),
      );
    });

    test('has correct default config', () async {
      final config = await driveCommand.parseInput();
      expect(config, _defaultConfig);
    });

    test('has correct config when single target is given', () async {
      fs.file('integration_test/app_test.dart').createSync();

      final config = await driveCommand.parseInput();

      expect(
        config,
        _defaultConfig.copyWith(
          targets: ['/projects/awesome_app/integration_test/app_test.dart'],
        ),
      );
    });

    test('has correct config when multiple targets are given', () async {
      fs.file('integration_test/app_test.dart').createSync();
      fs.file('integration_test/login_test.dart').createSync();

      final config = await driveCommand.parseInput();

      expect(
        config,
        _defaultConfig.copyWith(
          targets: [
            '/projects/awesome_app/integration_test/app_test.dart',
            '/projects/awesome_app/integration_test/login_test.dart'
          ],
        ),
      );
    });

    test('returns exit code 0 when all tests pass', () async {
      fs.file('integration_test/app_test.dart').createSync();
      fs.file('integration_test/login_test.dart').createSync();

      final config = await driveCommand.parseInput();

      when(() => flutterTool.drive(any(), any(), null))
          .thenAnswer((_) async {});

      final exitCode = await driveCommand.execute(config);
      expect(exitCode, isZero);
    });

    test('returns exit code 1 when any test fails', () async {
      fs.file('integration_test/app_test.dart').createSync();
      fs.file('integration_test/login_test.dart').createSync();

      final config = await driveCommand.parseInput();

      when(() => flutterTool.drive(any(), any(), null)).thenThrow(
        FlutterDriverFailedException(1),
      );

      final exitCode = await driveCommand.execute(config);
      expect(exitCode, equals(1));
    });
  });
}
