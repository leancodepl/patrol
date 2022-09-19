import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/memory.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/common/artifacts_repository.dart';
import 'package:patrol_cli/src/features/drive/drive_command.dart';
import 'package:patrol_cli/src/features/drive/test_finder.dart';
import 'package:patrol_cli/src/top_level_flags.dart';
import 'package:test/test.dart';

class MockArtifactsRepository extends Mock implements ArtifactsRepository {}

const _defaultConfig = DriveCommandConfig(
  targets: [],
  devices: [],
  host: 'localhost',
  port: '8081',
  driver: 'test_driver/integration_test.dar',
  flavor: null,
  dartDefines: {},
  packageName: null,
  bundleId: null,
);

void main() {
  late DriveCommand driveCommand;

  group('parse input', () {
    setUp(() {
      final parentDisposeScope = DisposeScope();
      final topLevelFlags = TopLevelFlags();
      final artifactsRepository = MockArtifactsRepository();

      final fs = MemoryFileSystem.test();
      final wd = fs.directory('/projects/awesome_app')
        ..createSync(recursive: true);
      fs.currentDirectory = wd;
      final integrationTestDir = fs.directory('integration_test')..createSync();

      final testFinder = TestFinder(
        integrationTestDir: fs.directory(integrationTestDir),
        fileSystem: fs,
      );

      driveCommand = DriveCommand(
        parentDisposeScope,
        topLevelFlags,
        artifactsRepository,
        testFinder,
      );
    });

    test(
      'creates empty default config when config file does not exist',
      () async {},
    );

    test('creates empty default config when config file is empty', () async {
      final config = await driveCommand.parseInput();

      expect(config, _defaultConfig);
    });
  });
}
