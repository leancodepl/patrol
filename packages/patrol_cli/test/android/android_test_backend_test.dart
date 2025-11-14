import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/android/android_test_backend.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:platform/platform.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';

void main() {
  group('AndroidTestBackend', () {
    late AndroidTestBackend androidTestBackend;
    late MockProcessManager processManager;
    late MockProcess process;
    late MockLogger logger;
    late FileSystem fs;
    late Directory rootDirectory;

    setUp(() {
      processManager = MockProcessManager();
      process = MockProcess();
      logger = MockLogger();
      fs = MemoryFileSystem.test();
      rootDirectory = fs.currentDirectory;

      androidTestBackend = AndroidTestBackend(
        adb: MockAdb(),
        processManager: processManager,
        platform: FakePlatform(),
        rootDirectory: rootDirectory,
        parentDisposeScope: DisposeScope(),
        logger: logger,
      );

      when(
        () => process.stdout,
      ).thenAnswer((_) => const Stream<List<int>>.empty());
      when(
        () => process.stderr,
      ).thenAnswer((_) => const Stream<List<int>>.empty());
      when(() => process.exitCode).thenAnswer((_) async => 0);

      when(
        () => processManager.start(any(), runInShell: any(named: 'runInShell')),
      ).thenAnswer((_) async => process);
    });

    group('buildApkConfigOnly', () {
      test('includes build flags when provided', () async {
        const flutterOptions = FlutterAppOptions(
          command: FlutterCommand('flutter'),
          target: 'patrol_test/test_bundle.dart',
          buildMode: BuildMode.debug,
          flavor: null,
          buildName: '1.2.3',
          buildNumber: '123',
          dartDefines: {},
          dartDefineFromFilePaths: [],
        );

        await androidTestBackend.buildApkConfigOnly(flutterOptions);

        verify(
          () => processManager.start([
            'flutter',
            'build',
            'apk',
            '--config-only',
            '--build-name',
            '1.2.3',
            '--build-number',
            '123',
            '-t',
            'patrol_test/test_bundle.dart',
          ], runInShell: true),
        );
      });

      test('does not include build flags when not provided', () async {
        const flutterOptions = FlutterAppOptions(
          command: FlutterCommand('flutter'),
          target: 'patrol_test/test_bundle.dart',
          buildMode: BuildMode.debug,
          flavor: null,
          buildName: null,
          buildNumber: null,
          dartDefines: {},
          dartDefineFromFilePaths: [],
        );

        await androidTestBackend.buildApkConfigOnly(flutterOptions);

        verify(
          () => processManager.start([
            'flutter',
            'build',
            'apk',
            '--config-only',
            '-t',
            'patrol_test/test_bundle.dart',
          ], runInShell: true),
        );
      });

      test('includes only build name when build number is null', () async {
        const flutterOptions = FlutterAppOptions(
          command: FlutterCommand('flutter'),
          target: 'patrol_test/test_bundle.dart',
          buildMode: BuildMode.debug,
          flavor: null,
          buildName: '1.2.3',
          buildNumber: null,
          dartDefines: {},
          dartDefineFromFilePaths: [],
        );

        await androidTestBackend.buildApkConfigOnly(flutterOptions);

        verify(
          () => processManager.start([
            'flutter',
            'build',
            'apk',
            '--config-only',
            '--build-name',
            '1.2.3',
            '-t',
            'patrol_test/test_bundle.dart',
          ], runInShell: true),
        );
      });

      test('includes only build number when build name is null', () async {
        const flutterOptions = FlutterAppOptions(
          command: FlutterCommand('flutter'),
          target: 'patrol_test/test_bundle.dart',
          buildMode: BuildMode.debug,
          flavor: null,
          buildName: null,
          buildNumber: '456',
          dartDefines: {},
          dartDefineFromFilePaths: [],
        );

        await androidTestBackend.buildApkConfigOnly(flutterOptions);

        verify(
          () => processManager.start([
            'flutter',
            'build',
            'apk',
            '--config-only',
            '--build-number',
            '456',
            '-t',
            'patrol_test/test_bundle.dart',
          ], runInShell: true),
        );
      });

      test('throws exception when flutter build exits with non-zero code', () {
        const exitCode = 1;
        const exceptionMessage =
            'Exception: Failed to build APK config with exit code $exitCode';

        const flutterOptions = FlutterAppOptions(
          command: FlutterCommand('flutter'),
          target: 'patrol_test/test_bundle.dart',
          buildMode: BuildMode.debug,
          flavor: null,
          buildName: null,
          buildNumber: null,
          dartDefines: {},
          dartDefineFromFilePaths: [],
        );

        when(() => process.exitCode).thenAnswer((_) async => exitCode);

        expect(
          () => androidTestBackend.buildApkConfigOnly(flutterOptions),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              exceptionMessage,
            ),
          ),
        );
      });
    });
  });
}
