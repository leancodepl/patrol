import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/commands/validate.dart';
import 'package:patrol_cli/src/setup_validator/environment_checks.dart';
import 'package:patrol_cli/src/setup_validator/setup_validator.dart';
import 'package:platform/platform.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';

void main() {
  group('ValidateCommand', () {
    late MemoryFileSystem fs;
    late Directory projectRoot;
    late MockLogger mockLogger;
    late CommandRunner<int> runner;

    final platform = FakePlatform(
      operatingSystem: 'macos',
      environment: {'ANDROID_HOME': '/sdk'},
    );

    setUp(() {
      fs = MemoryFileSystem();
      projectRoot = fs.directory('/project')..createSync();
      mockLogger = MockLogger();

      final command = ValidateCommand(
        projectRoot: projectRoot,
        platform: platform,
        logger: mockLogger,
        setupValidator: SetupValidator(
          projectRoot: projectRoot,
          platform: platform,
          cliVersion: '4.5.0',
          environmentChecks: EnvironmentChecks(
            platform: platform,
            isToolInstalled: (_) => true,
          ),
        ),
      );
      runner = CommandRunner<int>('test', 'Test runner')..addCommand(command);
    });

    void writeCleanProject() {
      fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: example_app
dev_dependencies:
  patrol: ^4.7.0
patrol:
  app_name: My App
''');
      fs.file('/project/pubspec.lock').writeAsStringSync('''
packages:
  patrol:
    version: "4.7.0"
''');
      fs
          .file('/project/patrol_test/example_test.dart')
          .createSync(recursive: true);
      fs
          .file('/project/.gitignore')
          .writeAsStringSync('patrol_test/test_bundle.dart\n');
    }

    test('returns 0 for a clean project', () async {
      writeCleanProject();
      expect(await runner.run(['validate']), 0);
    });

    test('returns 1 and prints the finding for a broken project', () async {
      writeCleanProject();
      fs.directory('/project/patrol_test').deleteSync(recursive: true);
      expect(await runner.run(['validate']), 1);
      verify(() => mockLogger.err(any(that: contains('[S4]')))).called(1);
    });

    test('returns 1 when there is no pubspec.yaml', () async {
      expect(await runner.run(['validate']), 1);
      verify(
        () => mockLogger.err(any(that: contains('No pubspec.yaml'))),
      ).called(1);
    });

    test('--quiet suppresses notices', () async {
      writeCleanProject();
      fs.file('/project/.gitignore').deleteSync();
      expect(await runner.run(['validate', '--quiet']), 0);
      verifyNever(() => mockLogger.info(any(that: contains('[S6]'))));
    });

    test('--platform narrows validated platforms', () async {
      writeCleanProject();
      // Declared and broken Android setup, but filtered out by --platform.
      fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: example_app
dev_dependencies:
  patrol: ^4.7.0
patrol:
  app_name: My App
  android:
    package_name: com.example.app
''');
      expect(await runner.run(['validate', '--platform', 'ios']), 0);
      expect(await runner.run(['validate']), 1);
    });
  });
}
