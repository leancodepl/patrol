import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:file/memory.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' show join;
import 'package:patrol_cli/src/commands/build_linux.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(
      const LinuxAppOptions(
        flutter: FlutterAppOptions(
          command: FlutterCommand('flutter'),
          target: 'patrol_test/test_bundle.dart',
          flavor: null,
          buildMode: BuildMode.debug,
          dartDefines: <String, String>{},
          dartDefineFromFilePaths: <String>[],
          buildName: null,
          buildNumber: null,
        ),
        appServerPort: 8082,
        testServerPort: 8081,
      ),
    );
  });

  group('BuildLinuxCommand', () {
    late MockLogger logger;
    late MockTestBundler testBundler;
    late MockLinuxTestBackend linuxTestBackend;
    late BuildLinuxCommand command;

    setUp(() {
      logger = MockLogger();
      final testFinderFactory = MockTestFinderFactory();
      final testFinder = MockTestFinder();
      testBundler = MockTestBundler();
      final dartDefinesReader = MockDartDefinesReader();
      final pubspecReader = MockPubspecReader();
      linuxTestBackend = MockLinuxTestBackend();

      when(() => logger.info(any())).thenReturn(null);
      when(() => logger.detail(any())).thenReturn(null);
      when(() => logger.err(any())).thenReturn(null);

      when(() => testFinderFactory.create(any())).thenReturn(testFinder);
      when(
        () => testFinder.findAllTests(
          excludes: any(named: 'excludes'),
          testFileSuffix: any(named: 'testFileSuffix'),
        ),
      ).thenReturn(['patrol_test/app_test.dart']);
      when(
        () => testBundler.getBundledTestFile(any()),
      ).thenReturn(MemoryFileSystem().file('patrol_test/test_bundle.dart'));

      when(dartDefinesReader.fromFile).thenReturn({'FROM_FILE': 'yes'});
      when(
        () => dartDefinesReader.fromCli(args: any(named: 'args')),
      ).thenReturn({});

      when(
        pubspecReader.read,
      ).thenReturn(PatrolPubspecConfig.empty(flutterPackageName: 'test_app'));

      when(() => linuxTestBackend.build(any())).thenAnswer((_) async {});
      when(() => linuxTestBackend.resolveBinaryPath(any())).thenAnswer(
        (_) async => join(
          Directory.current.path,
          'build/linux/x64/staging/release/bundle/test_app',
        ),
      );

      command = BuildLinuxCommand(
        testFinderFactory: testFinderFactory,
        testBundler: testBundler,
        dartDefinesReader: dartDefinesReader,
        pubspecReader: pubspecReader,
        linuxTestBackend: linuxTestBackend,
        analytics: MockAnalytics(),
        logger: logger,
        compatibilityChecker: MockCompatibilityChecker(),
      );
    });

    Future<int> run(List<String> args) async {
      final runner = CommandRunner<int>('test', 'Test runner')
        ..argParser.addOption('flutter-command', defaultsTo: 'flutter')
        ..addCommand(command);
      return await runner.run([
            'linux',
            '--no-generate-bundle',
            '--no-check-compatibility',
            ...args,
          ]) ??
          0;
    }

    test('builds once with the CLI options and prints the bundle', () async {
      final result = await run([
        '--release',
        '--flavor',
        'staging',
        '--app-server-port',
        '9000',
        '--test-server-port',
        '9001',
      ]);

      expect(result, 0);
      final options =
          verify(() => linuxTestBackend.build(captureAny())).captured.single
              as LinuxAppOptions;
      expect(options.flutter.buildMode, BuildMode.release);
      expect(options.flutter.flavor, 'staging');
      expect(options.flutter.target, 'patrol_test/test_bundle.dart');
      expect(options.appServerPort, 9000);
      expect(options.testServerPort, 9001);
      expect(options.flutter.dartDefines, containsPair('FROM_FILE', 'yes'));
      expect(
        options.flutter.dartDefines,
        containsPair('PATROL_APP_SERVER_PORT', '9000'),
      );
      expect(
        options.flutter.dartDefines,
        containsPair('PATROL_TEST_SERVER_PORT', '9001'),
      );
      verify(
        () =>
            logger.info('build/linux/x64/staging/release/bundle (app bundle)'),
      ).called(1);
    });

    test('passes --no-tree-shake-icons to flutter build linux', () async {
      final result = await run(['--no-tree-shake-icons']);

      expect(result, 0);
      final options =
          verify(() => linuxTestBackend.build(captureAny())).captured.single
              as LinuxAppOptions;
      expect(
        options.toFlutterBuildInvocation(BuildMode.debug),
        contains('--no-tree-shake-icons'),
      );
    });
  });
}
