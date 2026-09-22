import 'package:args/command_runner.dart';
import 'package:file/memory.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/commands/build_web.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(
      const WebAppOptions(
        flutter: FlutterAppOptions(
          command: FlutterCommand('flutter'),
          target: 'test_bundle.dart',
          flavor: null,
          buildMode: BuildMode.debug,
          dartDefines: <String, String>{},
          dartDefineFromFilePaths: <String>[],
          buildName: null,
          buildNumber: null,
        ),
      ),
    );
    registerFallbackValue(
      PatrolPubspecConfig.empty(flutterPackageName: 'test_app'),
    );
    registerFallbackValue(MemoryFileSystem().file('test'));
  });

  group('BuildWebCommand', () {
    late BuildWebCommand command;
    late MemoryFileSystem fs;
    late MockLogger mockLogger;
    late MockTestFinderFactory mockTestFinderFactory;
    late MockTestFinder mockTestFinder;
    late MockTestBundler mockTestBundler;
    late MockDartDefinesReader mockDartDefinesReader;
    late MockPubspecReader mockPubspecReader;
    late MockWebTestBackend mockWebTestBackend;
    late MockAnalytics mockAnalytics;
    late MockCompatibilityChecker mockCompatibilityChecker;

    setUp(() {
      fs = MemoryFileSystem();
      fs.file('web/index.html').createSync(recursive: true);
      mockLogger = MockLogger();
      mockTestFinderFactory = MockTestFinderFactory();
      mockTestFinder = MockTestFinder();
      mockTestBundler = MockTestBundler();
      mockDartDefinesReader = MockDartDefinesReader();
      mockPubspecReader = MockPubspecReader();
      mockWebTestBackend = MockWebTestBackend();
      mockAnalytics = MockAnalytics();
      mockCompatibilityChecker = MockCompatibilityChecker();

      when(() => mockLogger.info(any())).thenReturn(null);
      when(() => mockLogger.detail(any())).thenReturn(null);
      when(() => mockLogger.err(any())).thenReturn(null);

      when(
        () => mockTestFinderFactory.create(any()),
      ).thenReturn(mockTestFinder);
      when(
        () => mockTestFinder.findAllTests(
          excludes: any(named: 'excludes'),
          testFileSuffix: any(named: 'testFileSuffix'),
        ),
      ).thenReturn(['integration_test/app_test.dart']);

      when(
        () => mockTestBundler.createTestBundle(
          any(),
          any(),
          any(),
          any(),
          web: any(named: 'web'),
        ),
      ).thenReturn(null);
      when(
        () => mockTestBundler.getBundledTestFile(any(), web: any(named: 'web')),
      ).thenReturn(fs.file('test_bundle.dart'));

      when(() => mockDartDefinesReader.fromFile()).thenReturn({});
      when(
        () => mockDartDefinesReader.fromCli(args: any(named: 'args')),
      ).thenReturn({});
      when(
        () => mockDartDefinesReader.extractDartDefineConfigJsonMap(any()),
      ).thenReturn({});

      when(
        () => mockPubspecReader.read(),
      ).thenReturn(PatrolPubspecConfig.empty(flutterPackageName: 'test_app'));
      when(() => mockPubspecReader.getPatrolVersion()).thenReturn('4.11.0');

      when(
        () => mockCompatibilityChecker.checkVersionsCompatibilityForBuild(
          patrolVersion: any(named: 'patrolVersion'),
        ),
      ).thenAnswer((_) async {});

      when(
        () => mockWebTestBackend.build(any(), output: any(named: 'output')),
      ).thenAnswer((invocation) async {
        final output = invocation.namedArguments[#output] as String;
        fs.file(fs.path.join(output, 'index.html')).createSync(recursive: true);
      });
      when(() => mockWebTestBackend.resolveWebRunnerPath()).thenAnswer((
        _,
      ) async {
        fs.file('web_runner/package.json').createSync(recursive: true);
        return 'web_runner';
      });

      command = BuildWebCommand(
        testFinderFactory: mockTestFinderFactory,
        testBundler: mockTestBundler,
        dartDefinesReader: mockDartDefinesReader,
        pubspecReader: mockPubspecReader,
        webTestBackend: mockWebTestBackend,
        compatibilityChecker: mockCompatibilityChecker,
        projectRoot: fs.currentDirectory,
        fs: fs,
        analytics: mockAnalytics,
        logger: mockLogger,
      );
    });

    Future<int> runCommand([List<String> args = const []]) async {
      final runner = CommandRunner<int>('test', 'Test runner')
        ..argParser.addOption('flutter-command', defaultsTo: 'flutter')
        ..addCommand(command);

      return await runner.run(['web', ...args]) ?? 0;
    }

    test('builds the artifact into the default output directory', () async {
      expect(await runCommand(), equals(0));

      final artifactRoot = fs.directory('build/patrol-web');
      expect(artifactRoot.childFile('app/index.html').existsSync(), isTrue);
      expect(
        artifactRoot.childFile('runner/package.json').existsSync(),
        isTrue,
      );
    });

    test('bundles the tests for web, not for a device', () async {
      await runCommand();

      verify(
        () => mockTestBundler.createTestBundle(
          any(),
          any(),
          any(),
          any(),
          web: true,
        ),
      ).called(1);
    });

    test('refuses release and profile, which stop the tests typing', () async {
      expect(await runCommand(['--release']), equals(1));
      expect(await runCommand(['--profile']), equals(1));

      verifyNever(
        () => mockWebTestBackend.build(any(), output: any(named: 'output')),
      );
    });

    test('builds in release when forced', () async {
      expect(await runCommand(['--release', '--force']), equals(0));

      final opts =
          verify(
                () => mockWebTestBackend.build(
                  captureAny(),
                  output: any(named: 'output'),
                ),
              ).captured.first
              as WebAppOptions;

      expect(opts.flutter.buildMode, equals(BuildMode.release));
    });

    test('says how to configure a project that has no web platform', () async {
      fs.file('web/index.html').deleteSync();

      expect(await runCommand(), equals(1));

      verify(
        () => mockLogger.err(any(that: contains('flutter create'))),
      ).called(1);
    });

    test('leaves a directory that is not a Patrol artifact alone', () async {
      fs.file('out/important.txt').createSync(recursive: true);

      expect(await runCommand(['--output', 'out']), equals(1));

      expect(fs.file('out/important.txt').existsSync(), isTrue);
      verifyNever(
        () => mockWebTestBackend.build(any(), output: any(named: 'output')),
      );
    });
  });
}
