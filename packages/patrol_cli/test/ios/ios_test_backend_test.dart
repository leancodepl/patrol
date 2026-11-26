import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:meta/meta.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:platform/testing.dart';
import 'package:process/process.dart';
import 'package:test/test.dart';

const legacyRunnerLine = 'PATROL_INTEGRATION_TEST_IOS_RUNNER(RunnerUITests)';

void main() {
  group('BuildMode', () {
    test('infers build options in debug mode when flavor is null', () {
      const buildMode = BuildMode.debug;
      String? flavor;

      expect(buildMode.createConfiguration(flavor), 'Debug');
      expect(buildMode.createScheme(flavor), 'Runner');
    });

    test('infers build options in debug mode when flavor is not null', () {
      const buildMode = BuildMode.debug;
      const flavor = 'dev';

      expect(buildMode.createConfiguration(flavor), 'Debug-dev');
      expect(buildMode.createScheme(flavor), 'dev');
    });

    test('infers build options in release mode when flavor is null', () {
      const buildMode = BuildMode.release;
      String? flavor;

      expect(buildMode.createConfiguration(flavor), 'Release');
      expect(buildMode.createScheme(flavor), 'Runner');
    });

    test('infers build options in release mode when flavor is not null', () {
      const buildMode = BuildMode.release;
      const flavor = 'prod';

      expect(buildMode.createConfiguration(flavor), 'Release-prod');
      expect(buildMode.createScheme(flavor), 'prod');
    });
  });

  group('IOSTestBackend', () {
    late IOSTestBackend iosTestBackend;
    late FileSystem fs;

    setUp(() {
      fs = MemoryFileSystem.test();
      fs.directory('example_app').createSync();
      fs.currentDirectory = 'example_app';

      iosTestBackend = IOSTestBackend(
        processManager: FakeProcessManager(),
        platform: TestNativePlatform(),
        fs: fs,
        rootDirectory: fs.currentDirectory,
        parentDisposeScope: DisposeScope(),
        logger: FakeLogger(),
      );
    });

    group('xcTestRunPath', () {
      @isTest
      void testXcTestRunPath(
        String description, {
        String scheme = 'Runner',
        bool simulator = false,
        String? arch,
        String? testPlan,
      }) {
        test(description, () async {
          final target = simulator ? 'iphonesimulator' : 'iphoneos';
          final archSuffix = arch != null ? '-$arch' : '';

          final xcTestPlan = testPlan != null ? '-$testPlan' : '';

          final name =
              '${scheme}_$xcTestPlan${target}16.2$archSuffix.xctestrun';

          fs
              .file('build/ios_integ/Build/Products/$name')
              .createSync(recursive: true);

          final found = await iosTestBackend.xcTestRunPath(
            real: !simulator,
            scheme: scheme,
            sdkVersion: '16.2',
          );

          expect(found, '/example_app/build/ios_integ/Build/Products/$name');
        });
      }

      testXcTestRunPath('finds xctestrun with no arch on iphoneos');

      testXcTestRunPath(
        'finds xctestrun with single arch on iphoneos',
        arch: 'arm64',
      );

      testXcTestRunPath(
        'finds xctestrun with single arch on iphoneos (test plan)',
        arch: 'arm64',
        testPlan: 'TestPlan',
      );

      testXcTestRunPath(
        'finds xctestrun with double arch on iphoneos',
        arch: 'arm64-x86_64',
      );

      testXcTestRunPath(
        'finds xctestrun with no arch and custom scheme on iphoneos',
        scheme: 'dev',
      );

      testXcTestRunPath(
        'finds xctestrun with single arch and custom scheme on iphoneos',
        arch: 'arm64',
        scheme: 'dev',
      );

      testXcTestRunPath(
        'finds xctestrun with double arch and custom scheme on iphoneos',
        arch: 'arm64-x86_64',
        scheme: 'dev',
      );

      testXcTestRunPath(
        'finds xctestrun with no arch on iphonesimulator',
        simulator: true,
      );

      testXcTestRunPath(
        'finds xctestrun with single arch on iphonesimulator',
        arch: 'arm64',
        simulator: true,
      );

      testXcTestRunPath(
        'finds xctestrun with double arch on iphonesimulator',
        arch: 'arm64-x86_64',
        simulator: true,
      );

      testXcTestRunPath(
        'finds xctestrun with no arch and custom scheme on iphonesimulator',
        simulator: true,
        scheme: 'dev',
      );

      testXcTestRunPath(
        'finds xctestrun with single arch and custom scheme on iphonesimulator',
        arch: 'arm64',
        simulator: true,
        scheme: 'dev',
      );

      testXcTestRunPath(
        'finds xctestrun with double arch and custom scheme on iphonesimulator',
        arch: 'arm64-x86_64',
        simulator: true,
        scheme: 'dev',
      );

      testXcTestRunPath(
        'finds xctestrun with double arch and custom scheme on iphonesimulator (test plan)',
        arch: 'arm64-x86_64',
        simulator: true,
        scheme: 'dev',
        testPlan: 'SomeTestPlan',
      );

      test(
        'finds xctestrun with absolutePath when cwd is the ios directory',
        () async {
          const name = 'Runner_iphoneos16.2.xctestrun';
          fs
              .file('build/ios_integ/Build/Products/$name')
              .createSync(recursive: true);
          fs.directory('ios').createSync();
          fs.currentDirectory = 'ios';

          final found = await iosTestBackend.xcTestRunPath(
            real: true,
            scheme: 'Runner',
            sdkVersion: '16.2',
          );

          expect(found, '/example_app/build/ios_integ/Build/Products/$name');
        },
      );

      test('returns a CWD-relative path when absolutePath is false', () async {
        const name = 'Runner_iphoneos16.2.xctestrun';
        fs
            .file('build/ios_integ/Build/Products/$name')
            .createSync(recursive: true);

        final found = await iosTestBackend.xcTestRunPath(
          real: true,
          scheme: 'Runner',
          sdkVersion: '16.2',
          absolutePath: false,
        );

        expect(found, 'build/ios_integ/Build/Products/$name');
      });
    });

    group('extractVmServiceUrl', () {
      // As printed by `xcrun simctl spawn <udid> log stream --type log`.
      test('extracts the URL from the simulator log line', () {
        const line =
            '2026-09-04 13:17:11.693981+0200 0x1cb243   Default     0x0      '
            '            39258  0    Runner: (Flutter) flutter: The Dart VM '
            'service is listening on http://127.0.0.1:54296/4crAtS2Ux7w=/';

        expect(
          IOSTestBackend.extractVmServiceUrl(line),
          'http://127.0.0.1:54296/4crAtS2Ux7w=/',
        );
      });

      test('ignores other log lines', () {
        expect(
          IOSTestBackend.extractVmServiceUrl(
            'Runner: (Flutter) flutter: PATROL_LOG {"type":"step"}',
          ),
          isNull,
        );
      });
    });

    group('stripFlavorFromAppId', () {
      test('simply returns appId when flavor is null', () {
        const appId = 'com.company.app';
        const String? flavor = null;

        expect(
          iosTestBackend.stripFlavorFromAppId(appId, flavor),
          'com.company.app',
        );
      });

      test('works when appId contains flavor', () {
        const appId = 'com.company.app.dev';
        const flavor = 'dev';

        expect(
          iosTestBackend.stripFlavorFromAppId(appId, flavor),
          'com.company.app',
        );
      });

      test('ignores when appId contains flavor not preceded by a dot', () {
        const appId = 'com.company.app_dev';
        const flavor = 'dev';

        expect(
          iosTestBackend.stripFlavorFromAppId(appId, flavor),
          'com.company.app_dev',
        );
      });
    });

    group('build', () {
      void writeRunner({required bool static}) {
        final body = static
            ? 'PATROL_INTEGRATION_TEST_IOS_RUNNER_STATIC_BASE(RunnerUITests)\n'
                  '#include "PatrolGeneratedTests.inc"\n'
            : 'PATROL_INTEGRATION_TEST_IOS_RUNNER(RunnerUITests)\n';
        fs.file('ios/RunnerUITests/RunnerUITests.m')
          ..createSync(recursive: true)
          ..writeAsStringSync(body);
      }

      IOSAppOptions options({required bool emitTestManifest}) => IOSAppOptions(
        flutter: const FlutterAppOptions(
          command: FlutterCommand('flutter'),
          target: 'patrol_test/test_bundle.dart',
          flavor: null,
          buildMode: BuildMode.release,
          dartDefines: {},
          dartDefineFromFilePaths: [],
          buildName: null,
          buildNumber: null,
        ),
        bundleId: 'com.company.app',
        scheme: 'Runner',
        configuration: 'Release',
        simulator: false,
        osVersion: 'latest',
        appServerPort: 8080,
        testServerPort: 8081,
        emitTestManifest: emitTestManifest,
      );

      const legacyRunner =
          'PATROL_INTEGRATION_TEST_IOS_RUNNER(RunnerUITests)\n';
      const migratedRunner =
          'PATROL_INTEGRATION_TEST_IOS_RUNNER(RunnerUITests)\n'
          '#if __has_include("PatrolGeneratedTests.inc")\n'
          '#include "PatrolGeneratedTests.inc"\n'
          '#endif\n';

      File runner() => fs.file('ios/RunnerUITests/RunnerUITests.m');
      File inc() => fs.file('ios/RunnerUITests/PatrolGeneratedTests.inc');

      // The fake process manager throws once the build gets past the setup
      // checks, so a non-ToolExit error means the checks passed.
      Future<void> buildPastSetup({required bool emitTestManifest}) =>
          expectLater(
            iosTestBackend.build(options(emitTestManifest: emitTestManifest)),
            throwsA(isNot(isA<ToolExit>())),
          );

      test(
        'adds the include to a pre-5.0 runner when discovery is on',
        () async {
          writeRunner(static: false);

          await buildPastSetup(emitTestManifest: true);

          expect(runner().readAsStringSync(), migratedRunner);
        },
      );

      test('leaves a pre-5.0 runner alone when discovery is off', () async {
        writeRunner(static: false);

        await buildPastSetup(emitTestManifest: false);

        expect(runner().readAsStringSync(), legacyRunner);
        expect(inc().readAsStringSync(), isNot(contains('@interface')));
      });

      test('replaces a stale generated include with an empty one', () async {
        writeRunner(static: false);
        inc()
          ..createSync(recursive: true)
          ..writeAsStringSync(
            '@interface PatrolGeneratedTests_old : X\n@end\n',
          );

        await buildPastSetup(emitTestManifest: false);

        expect(inc().readAsStringSync(), isNot(contains('@interface')));
      });

      for (final emitTestManifest in [true, false]) {
        test(
          'accepts a 4.x STATIC_BASE runner (discovery: $emitTestManifest)',
          () async {
            writeRunner(static: true);
            final before = runner().readAsStringSync();

            await buildPastSetup(emitTestManifest: emitTestManifest);

            expect(runner().readAsStringSync(), before);
          },
        );

        test(
          'explains the removed STATIC_BEGIN/END form (discovery: $emitTestManifest)',
          () async {
            runner()
              ..createSync(recursive: true)
              ..writeAsStringSync(
                'PATROL_INTEGRATION_TEST_IOS_RUNNER_STATIC_BEGIN(RunnerUITests)\n'
                '#include "PatrolGeneratedTests.inc"\n'
                'PATROL_INTEGRATION_TEST_IOS_RUNNER_STATIC_END\n',
              );

            await expectLater(
              iosTestBackend.build(options(emitTestManifest: emitTestManifest)),
              throwsA(
                isA<ToolExit>().having(
                  (e) => e.message,
                  'message',
                  contains('removed in Patrol 5.0'),
                ),
              ),
            );
          },
        );
      }

      test("explains a runner it can't migrate when discovery is on", () async {
        runner()
          ..createSync(recursive: true)
          ..writeAsStringSync('@implementation RunnerUITests\n@end\n');

        await expectLater(
          iosTestBackend.build(options(emitTestManifest: true)),
          throwsA(
            isA<ToolExit>().having(
              (e) => e.message,
              'message',
              contains('--no-emit-test-manifest'),
            ),
          ),
        );
      });
    });

    group('hasGeneratedTests', () {
      File modeFile() =>
          fs.file('build/ios_integ/patrol_test_discovery_mode')
            ..createSync(recursive: true);
      File inc() =>
          fs.file('ios/RunnerUITests/PatrolGeneratedTests.inc')
            ..createSync(recursive: true);

      test('reads the mode stored with the build', () {
        modeFile().writeAsStringSync('build-time');

        expect(iosTestBackend.hasGeneratedTests, isTrue);
      });

      test('ignores a leftover .inc when the build used runtime discovery', () {
        modeFile().writeAsStringSync('runtime');
        inc().writeAsStringSync(
          '@interface PatrolGeneratedTests_a : X\n@end\n',
        );

        expect(iosTestBackend.hasGeneratedTests, isFalse);
      });

      test('falls back to the .inc for a build without a stored mode', () {
        inc().writeAsStringSync(
          '@interface PatrolGeneratedTests_a : X\n@end\n',
        );

        expect(iosTestBackend.hasGeneratedTests, isTrue);
      });

      test('a new build drops the mode of the previous one', () async {
        modeFile().writeAsStringSync('build-time');
        fs.file('ios/RunnerUITests/RunnerUITests.m')
          ..createSync(recursive: true)
          ..writeAsStringSync(legacyRunnerLine);

        await expectLater(
          iosTestBackend.build(
            IOSAppOptions(
              flutter: const FlutterAppOptions(
                command: FlutterCommand('flutter'),
                target: 'patrol_test/test_bundle.dart',
                flavor: null,
                buildMode: BuildMode.release,
                dartDefines: {},
                dartDefineFromFilePaths: [],
                buildName: null,
                buildNumber: null,
              ),
              scheme: 'Runner',
              configuration: 'Release',
              simulator: false,
              osVersion: 'latest',
              appServerPort: 8080,
              testServerPort: 8081,
            ),
          ),
          throwsA(isNot(isA<ToolExit>())),
        );

        expect(
          fs.file('build/ios_integ/patrol_test_discovery_mode').existsSync(),
          isFalse,
        );
      });
    });

    group('addGeneratedTestsInclude', () {
      test('adds the guarded include right after the macro', () {
        expect(
          IOSTestBackend.addGeneratedTestsInclude(
            '@import patrol;\n\n$legacyRunnerLine\n// trailing\n',
          ),
          '@import patrol;\n\n$legacyRunnerLine\n'
          '#if __has_include("PatrolGeneratedTests.inc")\n'
          '#include "PatrolGeneratedTests.inc"\n'
          '#endif\n'
          '// trailing\n',
        );
      });

      test('handles a file without a trailing newline', () {
        final migrated = IOSTestBackend.addGeneratedTestsInclude(
          legacyRunnerLine,
        );
        expect(migrated, endsWith('#endif'));
        expect(IOSTestBackend.includesGeneratedTests(migrated!), isTrue);
      });

      test('returns null without a single runner macro line', () {
        expect(IOSTestBackend.addGeneratedTestsInclude('@end\n'), isNull);
        expect(
          IOSTestBackend.addGeneratedTestsInclude(
            '$legacyRunnerLine\n$legacyRunnerLine\n',
          ),
          isNull,
        );
      });
    });

    group('includesGeneratedTests', () {
      test('finds #include and #import', () {
        expect(
          IOSTestBackend.includesGeneratedTests(
            '#include "PatrolGeneratedTests.inc"\n',
          ),
          isTrue,
        );
        expect(
          IOSTestBackend.includesGeneratedTests(
            '#import "PatrolGeneratedTests.inc"\n',
          ),
          isTrue,
        );
      });

      test('ignores a commented-out include', () {
        expect(
          IOSTestBackend.includesGeneratedTests(
            '// #include "PatrolGeneratedTests.inc"\n',
          ),
          isFalse,
        );
      });
    });
  });
}

class FakeProcessManager extends Fake implements ProcessManager {}

class FakeLogger extends Fake implements Logger {
  @override
  void detail(String? message, {String? Function(String?)? style}) {}

  @override
  void info(String? message, {String? Function(String?)? style}) {}

  @override
  ProgressTask task(String message) => FakeProgressTask();
}

class FakeProgressTask extends Fake implements ProgressTask {}
