import 'dart:convert';
import 'dart:io' show ProcessResult;

import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:meta/meta.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:platform/platform.dart';
import 'package:process/process.dart';
import 'package:test/test.dart';

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
        platform: FakePlatform(),
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
        platform: FakePlatform(),
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
      expect(saved, ['patrol_before_tap_1.png', 'patrol_failure_0.png']);
    });

    test(
      'does not throw and writes nothing when the bundle is missing',
      () async {
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
}

class FakeProcessManager extends Fake implements ProcessManager {}

class MockProcessManager extends Mock implements ProcessManager {}

class FakeLogger extends Fake implements Logger {
  @override
  void detail(String? message, {String? Function(String?)? style}) {}

  @override
  void info(String? message, {String? Function(String?)? style}) {}

  @override
  void warn(
    String? message, {
    String tag = 'WARN',
    String? Function(String?)? style,
  }) {}
}
