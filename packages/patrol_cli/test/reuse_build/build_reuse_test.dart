import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:patrol_cli/src/android/android_test_backend.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:patrol_cli/src/reuse_build/android_kernel_swapper.dart';
import 'package:patrol_cli/src/reuse_build/build_reuse.dart';
import 'package:patrol_cli/src/reuse_build/kernel_compiler.dart';
import 'package:patrol_cli/src/reuse_build/native_fingerprint.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:platform/testing.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';

void main() {
  late MemoryFileSystem fs;
  late Directory root;

  setUp(() {
    fs = MemoryFileSystem.test();
    root = fs.directory('/app')..createSync();
  });

  File touch(String path) => fs.file('/app/$path')..createSync(recursive: true);

  group('AndroidApks.locateBuilt', () {
    test('finds the APKs of a build without a flavor', () {
      touch('build/app/outputs/apk/debug/app-debug.apk');
      touch(
        'build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk',
      );
      touch('build/app/outputs/apk/dev/debug/app-dev-debug.apk');

      final apks = AndroidApks.locateBuilt(root, buildMode: 'debug');

      expect(apks!.app.path, endsWith('apk/debug/app-debug.apk'));
      expect(apks.test.path, endsWith('app-debug-androidTest.apk'));
    });

    test('finds the APKs of a flavor', () {
      touch('build/app/outputs/apk/debug/app-debug.apk');
      touch('build/app/outputs/apk/dev/debug/app-dev-debug.apk');
      touch(
        'build/app/outputs/apk/androidTest/dev/debug/'
        'app-dev-debug-androidTest.apk',
      );

      final apks = AndroidApks.locateBuilt(
        root,
        buildMode: 'debug',
        flavor: 'dev',
      );

      expect(apks!.app.path, endsWith('app-dev-debug.apk'));
      expect(apks.test.path, endsWith('app-dev-debug-androidTest.apk'));
    });

    test('returns null without a test APK', () {
      touch('build/app/outputs/apk/debug/app-debug.apk');
      expect(AndroidApks.locateBuilt(root, buildMode: 'debug'), isNull);
    });
  });

  group('KernelCompiler.bundleInvocation', () {
    test('passes the dart-defines and the flavor', () {
      final cmd = KernelCompiler.bundleInvocation(
        const FlutterAppOptions(
          command: FlutterCommand('flutter'),
          target: '/app/patrol_test/test_bundle.dart',
          flavor: 'dev',
          buildMode: BuildMode.debug,
          dartDefines: {'PATROL_WAIT': '0', 'API': 'staging'},
          dartDefineFromFilePaths: ['defines.json'],
          buildName: null,
          buildNumber: null,
        ),
        platform: ReusePlatform.iosSimulator,
        assetDir: '/out/flutter_assets',
        depfile: '/out/kernel_blob.bin.d',
      );

      expect(cmd.take(3), ['flutter', 'build', 'bundle']);
      expect(cmd, containsAllInOrder(['--target-platform', 'ios']));
      expect(
        cmd,
        containsAllInOrder(['--target', '/app/patrol_test/test_bundle.dart']),
      );
      expect(cmd, containsAllInOrder(['--dart-define', 'API=staging']));
      expect(
        cmd,
        containsAllInOrder(['--dart-define', 'FLUTTER_APP_FLAVOR=dev']),
      );
      // Their contents are already in dartDefines.
      expect(cmd, isNot(contains('--dart-define-from-file')));
    });
  });

  group('KernelCompiler.assembleIOSInvocation', () {
    test('builds a release App.framework with the dart-defines', () {
      final cmd = KernelCompiler.assembleIOSInvocation(
        const FlutterAppOptions(
          command: FlutterCommand('flutter'),
          target: '/app/patrol_test/test_bundle.dart',
          flavor: 'dev',
          buildMode: BuildMode.release,
          dartDefines: {'A': '1'},
          dartDefineFromFilePaths: [],
          buildName: null,
          buildNumber: null,
        ),
        configuration: 'Release-dev',
        sdkRoot: '/sdk',
        outputDir: '/out',
        sourceRoot: '/app/ios',
      );

      expect(cmd.take(2), ['flutter', 'assemble']);
      expect(
        cmd,
        containsAll([
          '--output=/out/',
          '-dBuildMode=release',
          '-dFlavor=dev',
          '-dConfiguration=Release-dev',
          '-dIosArchs=arm64',
          '-dSdkRoot=/sdk',
          '-dTreeShakeIcons=true',
          // base64 of `A=1`
          '--DartDefines=QT0x',
        ]),
      );
      expect(cmd.last, 'release_ios_bundle_flutter_assets');
    });
  });

  group('BuildReuseCache', () {
    late BuildReuseCache cache;
    const inputs = NativeBuildInputs(
      platform: ReusePlatform.android,
      flavor: null,
      buildName: null,
      buildNumber: null,
      appServerPort: 8082,
      testServerPort: 8081,
    );

    final f1 = NativeFingerprint({'android/app/build.gradle': '1'});
    final f2 = NativeFingerprint({'android/app/build.gradle': '2'});

    setUp(() {
      cache = BuildReuseCache(
        rootDirectory: root,
        processManager: MockProcessManager(),
        platform: TestNativePlatform(operatingSystem: NativePlatform.macOS),
        logger: MockLogger(),
      );
    });

    test('reuses a recorded build', () {
      final apk = touch('build/app/outputs/apk/debug/app-debug.apk');
      cache.record(inputs, fingerprint: f1, artifacts: [apk]);

      expect(
        cache.whyNotReusable(inputs, fingerprint: f1, artifacts: [apk]),
        isNull,
      );
    });

    test('does not reuse without a recorded build', () {
      final apk = touch('build/app/outputs/apk/debug/app-debug.apk');
      expect(
        cache.whyNotReusable(inputs, fingerprint: f1, artifacts: [apk]),
        'no build recorded yet',
      );
    });

    test('does not reuse when the fingerprint differs', () {
      final apk = touch('build/app/outputs/apk/debug/app-debug.apk');
      cache.record(inputs, fingerprint: f1, artifacts: [apk]);

      expect(
        cache.whyNotReusable(inputs, fingerprint: f2, artifacts: [apk]),
        'changed: android/app/build.gradle',
      );
    });

    test('does not reuse a build that changed since', () {
      final apk = touch('build/app/outputs/apk/debug/app-debug.apk');
      cache.record(inputs, fingerprint: f1, artifacts: [apk]);
      apk.setLastModifiedSync(DateTime(2030));

      expect(
        cache.whyNotReusable(inputs, fingerprint: f1, artifacts: [apk]),
        'the last build changed since it was recorded',
      );
    });

    test('does not reuse a build that is gone', () {
      final apk = touch('build/app/outputs/apk/debug/app-debug.apk');
      cache.record(inputs, fingerprint: f1, artifacts: [apk]);
      apk.deleteSync();

      expect(
        cache.whyNotReusable(inputs, fingerprint: f1, artifacts: [apk]),
        'the last build is gone',
      );
    });

    test('keeps flavors apart', () {
      final apk = touch('build/app/outputs/apk/debug/app-debug.apk');
      cache.record(inputs, fingerprint: f1, artifacts: [apk]);

      const dev = NativeBuildInputs(
        platform: ReusePlatform.android,
        flavor: 'dev',
        buildName: null,
        buildNumber: null,
        appServerPort: 8082,
        testServerPort: 8081,
      );
      expect(
        cache.whyNotReusable(dev, fingerprint: f1, artifacts: [apk]),
        'no build recorded yet',
      );
    });
  });

  group('AndroidTestBackend.orchestratorInvocation', () {
    test('runs the instrumentation through the orchestrator', () {
      expect(
        AndroidTestBackend.orchestratorInvocation(
          instrumentation:
              'com.example.test/pl.leancode.patrol.PatrolJUnitRunner',
          clearPackageData: true,
        ),
        r'CLASSPATH=$(pm path androidx.test.services) app_process / '
        'androidx.test.services.shellexecutor.ShellMain am instrument -w '
        '-e clearPackageData true -e targetInstrumentation '
        'com.example.test/pl.leancode.patrol.PatrolJUnitRunner '
        'androidx.test.orchestrator/androidx.test.orchestrator.AndroidTestOrchestrator',
      );
    });

    test('runs only the given classes', () {
      expect(
        AndroidTestBackend.orchestratorInvocation(
          instrumentation: 'a/b',
          clearPackageData: false,
          classArg: 'com.example.PatrolGeneratedTests_a,com.example.B',
        ),
        contains(
          '-e class com.example.PatrolGeneratedTests_a,com.example.B '
          '-e targetInstrumentation a/b',
        ),
      );
    });

    test('leaves clearPackageData out when the app does not set it', () {
      expect(
        AndroidTestBackend.orchestratorInvocation(
          instrumentation: 'a/b',
          clearPackageData: false,
        ),
        isNot(contains('clearPackageData')),
      );
    });
  });
}
