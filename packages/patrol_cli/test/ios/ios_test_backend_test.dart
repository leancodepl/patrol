import 'dart:convert';
import 'dart:io' show ProcessException, ProcessResult;

import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:meta/meta.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:platform/testing.dart';
import 'package:process/process.dart';
import 'package:test/test.dart';

const legacyRunnerLine = 'PATROL_INTEGRATION_TEST_IOS_RUNNER(RunnerUITests)';

/// PNG file signature followed by a couple of filler bytes.
final _pngBytes = <int>[0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0, 0];

/// Binary plist signature - what XCTest's automatic "UI Snapshot" element-tree
/// attachments look like (not an image).
final _bplistBytes = <int>[0x62, 0x70, 0x6C, 0x69, 0x73, 0x74, 0x30, 0x30];

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
      const currentRunner =
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
        'builds with discovery when the runner includes the tests',
        () async {
          runner()
            ..createSync(recursive: true)
            ..writeAsStringSync(currentRunner);

          await buildPastSetup(emitTestManifest: true);

          expect(runner().readAsStringSync(), currentRunner);
        },
      );

      test('stops when discovery is on and the include is missing', () async {
        writeRunner(static: false);

        await expectLater(
          iosTestBackend.build(options(emitTestManifest: true)),
          throwsA(
            isA<ToolExit>().having(
              (e) => e.message,
              'message',
              allOf(
                contains('#include "PatrolGeneratedTests.inc"'),
                contains('--no-emit-test-manifest'),
              ),
            ),
          ),
        );
        expect(runner().readAsStringSync(), legacyRunner);
      });

      test('leaves a pre-5.0 runner alone when discovery is off', () async {
        writeRunner(static: false);

        await buildPastSetup(emitTestManifest: false);

        expect(runner().readAsStringSync(), legacyRunner);
        expect(inc().existsSync(), isFalse);
      });

      test(
        'deletes a stale .inc when the runner does not include it',
        () async {
          writeRunner(static: false);
          inc()
            ..createSync(recursive: true)
            ..writeAsStringSync(
              '@interface PatrolGeneratedTests_old : X\n@end\n',
            );

          await buildPastSetup(emitTestManifest: false);

          expect(inc().existsSync(), isFalse);
        },
      );

      test('empties a stale .inc when the runner includes it', () async {
        writeRunner(static: true);
        inc()
          ..createSync(recursive: true)
          ..writeAsStringSync(
            '@interface PatrolGeneratedTests_old : X\n@end\n',
          );

        await buildPastSetup(emitTestManifest: false);

        expect(inc().readAsStringSync(), isNot(contains('@interface')));
      });

      test('keeps an unchanged empty .inc untouched', () async {
        writeRunner(static: true);
        await buildPastSetup(emitTestManifest: false);
        final modified = DateTime(2020);
        inc().setLastModifiedSync(modified);

        await buildPastSetup(emitTestManifest: false);

        expect(inc().lastModifiedSync(), modified);
      });

      test('ignores the removed STATIC_BEGIN macro in a comment', () async {
        runner()
          ..createSync(recursive: true)
          ..writeAsStringSync(
            '// was PATROL_INTEGRATION_TEST_IOS_RUNNER_STATIC_BEGIN(X)\n'
            '$currentRunner',
          );

        await buildPastSetup(emitTestManifest: false);
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
    });

    group('discoverySetupProblem', () {
      File runner() =>
          fs.file('ios/RunnerUITests/RunnerUITests.m')
            ..createSync(recursive: true);

      test('is null when the runner includes the generated tests', () {
        runner().writeAsStringSync(
          '$legacyRunnerLine\n#include "PatrolGeneratedTests.inc"\n',
        );

        expect(iosTestBackend.discoverySetupProblem(), isNull);
      });

      test('is null without a runner', () {
        expect(iosTestBackend.discoverySetupProblem(), isNull);
      });

      test('names the lines to add when the include is missing', () {
        runner().writeAsStringSync('$legacyRunnerLine;\r\n');

        expect(
          iosTestBackend.discoverySetupProblem(),
          contains('#if __has_include("PatrolGeneratedTests.inc")'),
        );
        expect(runner().readAsStringSync(), '$legacyRunnerLine;\r\n');
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

      test('finds an angle-bracket include', () {
        expect(
          IOSTestBackend.includesGeneratedTests(
            '#include <PatrolGeneratedTests.inc>\n',
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

  group('IOSTestBackend.extractScreenshots', () {
    late IOSTestBackend iosTestBackend;
    late MockProcessManager processManager;
    late FileSystem fs;
    late Directory rootDirectory;

    setUp(() {
      processManager = MockProcessManager();
      fs = MemoryFileSystem.test();
      rootDirectory = fs.currentDirectory;

      iosTestBackend = IOSTestBackend(
        processManager: processManager,
        platform: TestNativePlatform(),
        fs: fs,
        rootDirectory: rootDirectory,
        parentDisposeScope: DisposeScope(),
        logger: FakeLogger(),
      );
    });

    /// Makes the mocked `xcresulttool export attachments` write [manifest] plus
    /// the given [files] (name -> bytes) into whatever `--output-path` it is
    /// given, mimicking the real tool.
    void stubExport({
      required List<Map<String, dynamic>> manifest,
      required Map<String, List<int>> files,
      int exitCode = 0,
    }) {
      when(
        () => processManager.run(any(), runInShell: any(named: 'runInShell')),
      ).thenAnswer((invocation) async {
        final args = (invocation.positionalArguments.first as List)
            .cast<String>();
        final outIndex = args.indexOf('--output-path');
        final outDir = fs.directory(args[outIndex + 1])
          ..createSync(recursive: true);
        if (exitCode == 0) {
          outDir
              .childFile('manifest.json')
              .writeAsStringSync(jsonEncode(manifest));
          files.forEach((name, bytes) {
            outDir.childFile(name).writeAsBytesSync(bytes);
          });
        }
        return ProcessResult(0, exitCode, '', '');
      });
    }

    Map<String, dynamic> attachment(
      String file,
      String name, {
      bool failure = false,
    }) => {
      'exportedFileName': file,
      'suggestedHumanReadableName': name,
      'isAssociatedWithFailure': failure,
    };

    test('keeps patrol-named and failure PNGs, drops the rest', () async {
      fs.directory('build/out.xcresult').createSync(recursive: true);
      stubExport(
        manifest: [
          {
            'testIdentifier': 'RunnerUITests/RunnerUITests/test_login',
            'attachments': [
              attachment('a', 'patrol_failure'),
              attachment('b', 'patrol_before_tap'),
              attachment('c', 'UI Snapshot', failure: true),
              attachment('d', 'UI Snapshot'),
              attachment('e', 'patrol_broken'),
              attachment('f', 'Screenshot', failure: true),
            ],
          },
        ],
        files: {
          'a': _pngBytes,
          'b': _pngBytes,
          // Failure-associated but a bplist element tree, not an image - dropped.
          'c': _bplistBytes,
          // Not patrol, not a failure - dropped.
          'd': _pngBytes,
          // Patrol-named but not a PNG - dropped.
          'e': _bplistBytes,
          // Not patrol-named, but a PNG XCTest attached to the failure - kept.
          'f': _pngBytes,
        },
      );

      await iosTestBackend.extractScreenshots(
        xcresultPath: 'build/out.xcresult',
        outputDir: 'screenshots',
      );

      final testDir = rootDirectory
          .childDirectory('screenshots')
          .childDirectory('RunnerUITests_RunnerUITests_test_login');
      final saved = testDir.listSync().map((e) => e.basename).toList()..sort();
      expect(saved, [
        'Screenshot_0.png',
        'patrol_before_tap_0.png',
        'patrol_failure_0.png',
      ]);
    });

    test('names files after the attachment, not the export name', () async {
      fs.directory('build/out.xcresult').createSync(recursive: true);
      // What xcresulttool really suggests: `<name>_<n>_<UUID>.png`.
      stubExport(
        manifest: [
          {
            'testIdentifier': 'RunnerUITests/test_login',
            'attachments': [
              attachment(
                'a',
                'patrol_failure_0_8CCF158A-7BCA-4026-A773-B6FAF3C1196C.png',
              ),
              attachment(
                'b',
                'patrol_after_tap_0_E378A313-39AF-41D9-BF18-EFDC09DF1501.png',
              ),
              attachment(
                'c',
                'Screenshot_0_A1008077-3494-4600-88B0-79BE4561876A.png',
                failure: true,
              ),
              // The same tag again, and a tag that sanitizes to the same name.
              attachment(
                'd',
                'patrol_after_tap_1_0B0A1C52-0000-4000-8000-000000000001.png',
              ),
              attachment(
                'e',
                'patrol_after tap_0_0B0A1C52-0000-4000-8000-000000000002.png',
              ),
            ],
          },
        ],
        files: {
          'a': _pngBytes,
          'b': _pngBytes,
          'c': _pngBytes,
          'd': _pngBytes,
          'e': _pngBytes,
        },
      );

      await iosTestBackend.extractScreenshots(
        xcresultPath: 'build/out.xcresult',
        outputDir: 'screenshots',
      );

      final testDir = rootDirectory
          .childDirectory('screenshots')
          .childDirectory('RunnerUITests_test_login');
      final saved = testDir.listSync().map((e) => e.basename).toList()..sort();
      expect(saved, [
        'Screenshot_0.png',
        'patrol_after_tap_0.png',
        'patrol_after_tap_1.png',
        'patrol_after_tap_2.png',
        'patrol_failure_0.png',
      ]);
    });

    test('keeps test ids that sanitize to the same name apart', () async {
      fs.directory('build/out.xcresult').createSync(recursive: true);
      stubExport(
        manifest: [
          {
            'testIdentifier': 'RunnerUITests/login+happy',
            'attachments': [attachment('a', 'patrol_failure')],
          },
          {
            'testIdentifier': 'RunnerUITests/login_happy',
            'attachments': [attachment('b', 'patrol_failure')],
          },
          // The same test reported again (e.g. a retry) must not overwrite.
          {
            'testIdentifier': 'RunnerUITests/login+happy',
            'attachments': [attachment('c', 'patrol_failure')],
          },
        ],
        files: {'a': _pngBytes, 'b': _pngBytes, 'c': _pngBytes},
      );

      await iosTestBackend.extractScreenshots(
        xcresultPath: 'build/out.xcresult',
        outputDir: 'screenshots',
      );

      List<String> filesIn(String dir) {
        final files = rootDirectory
            .childDirectory('screenshots')
            .childDirectory(dir)
            .listSync();
        return files.map((e) => e.basename).toList()..sort();
      }

      expect(filesIn('RunnerUITests_login_happy'), [
        'patrol_failure_0.png',
        'patrol_failure_1.png',
      ]);
      expect(filesIn('RunnerUITests_login_happy_2'), ['patrol_failure_0.png']);
    });

    test(
      'clears stale screenshots and writes nothing when the bundle is missing',
      () async {
        // Left over from a previous run; must not pass for this run's.
        fs.file('screenshots/old_test/patrol_failure_0.png')
          ..createSync(recursive: true)
          ..writeAsBytesSync(_pngBytes);

        await iosTestBackend.extractScreenshots(
          xcresultPath: 'build/missing.xcresult',
          outputDir: 'screenshots',
        );

        verifyNever(
          () => processManager.run(any(), runInShell: any(named: 'runInShell')),
        );
        expect(
          rootDirectory.childDirectory('screenshots').existsSync(),
          isFalse,
        );
      },
    );

    test('does not throw when xcresulttool is too old', () async {
      fs.directory('build/out.xcresult').createSync(recursive: true);
      stubExport(manifest: [], files: {}, exitCode: 1);

      await iosTestBackend.extractScreenshots(
        xcresultPath: 'build/out.xcresult',
        outputDir: 'screenshots',
      );

      expect(rootDirectory.childDirectory('screenshots').existsSync(), isFalse);
    });
  });

  _lockStateTests();
}

void _lockStateTests() {
  group('IOSTestBackend.waitUntilUnlocked', () {
    late MockProcessManager processManager;
    late RecordingLogger logger;
    late FileSystem fs;
    late DisposeScope parentScope;
    late IOSTestBackend iosTestBackend;

    const device = Device(
      name: 'iPhone',
      id: '00008130-0005589A3E82001C',
      targetPlatform: TargetPlatform.iOS,
      real: true,
    );

    setUp(() {
      processManager = MockProcessManager();
      logger = RecordingLogger();
      fs = MemoryFileSystem.test();
      parentScope = DisposeScope();
      iosTestBackend = IOSTestBackend(
        processManager: processManager,
        platform: TestNativePlatform(),
        fs: fs,
        rootDirectory: fs.currentDirectory,
        parentDisposeScope: parentScope,
        logger: logger,
      );
    });

    /// Makes consecutive lockState calls report [states] (the last one
    /// repeats). A null state makes devicectl fail.
    void stubLockStates(List<bool?> states) {
      var call = 0;
      when(() => processManager.run(any())).thenAnswer((invocation) async {
        final args = (invocation.positionalArguments.first as List)
            .cast<String>();
        expect(args, containsAllInOrder(['--device', device.id]));
        final state = states[call < states.length ? call : states.length - 1];
        call++;
        if (state == null) {
          return ProcessResult(0, 1, '', '');
        }
        final path = args[args.indexOf('--json-output') + 1];
        fs
            .file(path)
            .writeAsStringSync(
              jsonEncode({
                'result': {'passcodeRequired': state},
              }),
            );
        return ProcessResult(0, 0, '', '');
      });
    }

    Future<void> wait() =>
        iosTestBackend.waitUntilUnlocked(device, pollInterval: Duration.zero);

    test('returns at once when the device is unlocked', () async {
      stubLockStates([false]);

      await wait();

      expect(logger.output, isEmpty);
      verify(() => processManager.run(any())).called(1);
    });

    test('rings and waits until the device is unlocked', () async {
      stubLockStates([true, true, true, false]);

      await wait();

      expect(logger.output, ['\x07']);
      expect(logger.tasks.single.completed, isTrue);
      verify(() => processManager.run(any())).called(4);
    });

    test('stops waiting when the lock state stops being readable', () async {
      stubLockStates([true, null]);

      await wait();

      verify(() => processManager.run(any())).called(2);
    });

    test('returns when devicectl fails', () async {
      stubLockStates([null]);

      await wait();

      expect(logger.output, isEmpty);
    });

    test('returns when devicectl is missing', () async {
      when(
        () => processManager.run(any()),
      ).thenThrow(const ProcessException('xcrun', []));

      await wait();

      expect(logger.output, isEmpty);
    });

    test('throws when interrupted while waiting', () async {
      stubLockStates([true]);

      final waiting = expectLater(wait(), throwsA(isA<ToolInterrupted>()));
      await parentScope.dispose();
      await waiting;

      expect(logger.tasks.single.failed, isTrue);
    });
  });
}

class RecordingLogger extends FakeLogger {
  final output = <String?>[];
  final tasks = <RecordingProgressTask>[];

  @override
  void write(String? message) => output.add(message);

  @override
  ProgressTask task(String message) {
    final task = RecordingProgressTask();
    tasks.add(task);
    return task;
  }
}

class RecordingProgressTask extends Fake implements ProgressTask {
  bool completed = false;
  bool failed = false;

  @override
  void complete([String? update]) => completed = true;

  @override
  void fail([String? update]) => failed = true;
}

class FakeProcessManager extends Fake implements ProcessManager {}

class MockProcessManager extends Mock implements ProcessManager {}

class FakeLogger extends Fake implements Logger {
  @override
  void detail(String? message, {String? Function(String?)? style}) {}

  @override
  void info(String? message, {String? Function(String?)? style}) {}

  @override
  ProgressTask task(String message) => FakeProgressTask();

  @override
  void warn(
    String? message, {
    String tag = 'WARN',
    String? Function(String?)? style,
  }) {}
}

class FakeProgressTask extends Fake implements ProgressTask {}
