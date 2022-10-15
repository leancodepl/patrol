import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:logging/logging.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/common/artifacts_repository.dart';
import 'package:patrol_cli/src/features/devices/device_finder.dart';
import 'package:patrol_cli/src/features/drive/drive_command.dart';
import 'package:patrol_cli/src/features/drive/test_finder.dart';
import 'package:patrol_cli/src/features/drive/test_runner.dart';
import 'package:test/test.dart';

import 'fixures/devices.dart';

class MockArtifactsRepository extends Mock implements ArtifactsRepository {}

class MockDeviceFinder extends Mock implements DeviceFinder {}

const _defaultConfig = DriveCommandConfig(
  targets: [],
  devices: [androidDevice],
  host: 'localhost',
  port: '8081',
  driver: 'test_driver/integration_test.dart',
  flavor: null,
  dartDefines: {'PATROL_WAIT': '0'},
  packageName: null,
  bundleId: null,
);

void main() {
  late DriveCommand driveCommand;
  late FileSystem fs;

  group('drive command', () {
    setUp(() {
      final parentDisposeScope = DisposeScope();
      final artifactsRepository = MockArtifactsRepository();

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

      driveCommand = DriveCommand(
        parentDisposeScope: parentDisposeScope,
        artifactsRepository: artifactsRepository,
        deviceFinder: deviceFinder,
        testFinder: testFinder,
        testRunner: TestRunner(),
        logger: Logger(''),
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

      final exitCode = await driveCommand.execute(config);
      expect(exitCode, isZero);
    });

    test('returns exit code 1 when any test fails', () async {
      fs.file('integration_test/app_test.dart').createSync();
      fs.file('integration_test/login_test.dart').createSync();

      final config = await driveCommand.parseInput();

      final exitCode = await driveCommand.execute(config);
      expect(exitCode, equals(1));
    });
  });
}
