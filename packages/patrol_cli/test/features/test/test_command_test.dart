import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/commands/test_command.dart';
import 'package:patrol_cli/src/features/devices/device_finder.dart';
import 'package:patrol_cli/src/features/run_commons/dart_defines_reader.dart';
import 'package:patrol_cli/src/features/run_commons/test_finder.dart';
import 'package:patrol_cli/src/features/test/android_test_backend.dart';
import 'package:patrol_cli/src/features/test/ios_test_backend.dart';
import 'package:patrol_cli/src/features/test/native_test_runner.dart';
import 'package:patrol_cli/src/features/test/pubspec_reader.dart';
import 'package:test/test.dart';

import '../../fakes.dart';
import '../../fixtures.dart';
import '../../mocks.dart';

final _defaultConfig = TestCommandConfig(
  devices: [androidDevice],
  targets: [],
  repeat: 1,
  dartDefines: {'PATROL_WAIT': '0', 'PATROL_VERBOSE': 'false'},
  displayLabel: true,
  uninstall: true,
  // Android-specific options
  packageName: null,
  androidFlavor: null,
  // iOS-specific options
  bundleId: null,
  iosFlavor: null,
  scheme: 'Runner',
  xcconfigFile: 'Flutter/Debug.xcconfig',
  configuration: 'Debug',
);

void main() {
  setUpFakes();

  late TestCommand testCommand;

  group('TestCommand', () {
    late DeviceFinder deviceFinder;
    late TestFinder testFinder;
    late AndroidTestBackend androidTestBackend;
    late IOSTestBackend iosTestBackend;
    late FileSystem fs;
    late NativeTestRunner testRunner;

    setUp(() {
      fs = MemoryFileSystem.test();
      final wd = fs.directory('/projects/awesome_app')
        ..createSync(recursive: true);
      fs.currentDirectory = wd;
      final integrationTestDir = fs.directory('integration_test')..createSync();
      fs.file('pubspec.yaml')
        ..createSync()
        ..writeAsString('name: awesome_app');

      deviceFinder = MockDeviceFinder();
      when(
        () => deviceFinder.find(any()),
      ).thenAnswer((_) async => [androidDevice]);

      testFinder = TestFinder(testDir: fs.directory(integrationTestDir));

      androidTestBackend = MockAndroidTestBackend();
      iosTestBackend = MockIOSTestBackend();
      testRunner = NativeTestRunner();

      testCommand = TestCommand(
        deviceFinder: deviceFinder,
        testFinder: testFinder,
        testRunner: testRunner,
        dartDefinesReader: DartDefinesReader(projectRoot: fs.currentDirectory),
        pubspecReader: PubspecReader(projectRoot: fs.currentDirectory),
        parentDisposeScope: DisposeScope(),
        androidTestBackend: androidTestBackend,
        iosTestBackend: iosTestBackend,
        logger: MockLogger(),
      );
    });

    test('has correct default config', () async {
      final config = await testCommand.configure();
      expect(config, _defaultConfig);
    });

    test('has correct config when single target is given', () async {
      fs.file('integration_test/app_test.dart').createSync();

      final config = await testCommand.configure();

      expect(
        config,
        _defaultConfig.copyWith(
          targets: ['/projects/awesome_app/integration_test/app_test.dart'],
        ),
      );
    });

    test('has correct config when single target is given', () async {
      fs.file('integration_test/app_test.dart').createSync();

      final config = await testCommand.configure();

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

      final config = await testCommand.configure();

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

      final config = await testCommand.configure();

      when(() => androidTestBackend.build(any(), any()))
          .thenAnswer((_) async {});
      when(() => androidTestBackend.execute(any(), any()))
          .thenAnswer((_) async {});

      final exitCode = await testCommand.execute(config);
      expect(exitCode, isZero);
    });

    test('returns exit code 1 when any test fails', () async {
      fs.file('integration_test/app_test.dart').createSync();
      fs.file('integration_test/login_test.dart').createSync();

      final config = await testCommand.configure();

      when(() => androidTestBackend.build(any(), any())).thenThrow(Exception());

      final exitCode = await testCommand.execute(config);
      expect(exitCode, equals(1));
    });
  });
}
