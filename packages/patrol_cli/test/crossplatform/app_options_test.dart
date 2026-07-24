import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:test/test.dart';

import '../src/fixtures.dart';

void main() {
  const flutterCommand = FlutterCommand('flutter');

  group('AndroidAppOptions', () {
    late AndroidAppOptions options;

    group('correctly encodes default invocation', () {
      test('on Windows', () {
        const flutterOptions = FlutterAppOptions(
          command: flutterCommand,
          target: r'C:\Users\john\app\patrol_test\app_test.dart',
          buildMode: BuildMode.debug,
          flavor: null,
          buildName: null,
          buildNumber: null,
          dartDefines: {},
          dartDefineFromFilePaths: ['somePath.json', 'someOtherPath.json'],
        );
        options = const AndroidAppOptions(
          flutter: flutterOptions,
          appServerPort: 1,
          testServerPort: 2,
          uninstall: false,
        );

        final invocation = options.toGradleAssembleTestInvocation(
          isWindows: true,
        );
        expect(
          invocation,
          equals([
            r'.\gradlew.bat',
            ':app:assembleDebugAndroidTest',
            r'-Ptarget=C:\Users\john\app\patrol_test\app_test.dart',
            '-Pandroid.injected.androidTest.leaveApksInstalledAfterRun=true',
            '-Papp-server-port=1',
            '-Ptest-server-port=2',
            '-Ppatrol-enabled=true',
          ]),
        );
      });

      test('on macOS', () {
        const flutterOpts = FlutterAppOptions(
          command: flutterCommand,
          target: '/Users/john/app/patrol_test/app_test.dart',
          buildMode: BuildMode.release,
          flavor: null,
          buildName: null,
          buildNumber: null,
          dartDefines: {},
          dartDefineFromFilePaths: ['somePath.json', 'someOtherPath.json'],
        );
        options = const AndroidAppOptions(
          flutter: flutterOpts,
          appServerPort: 1,
          testServerPort: 2,
          uninstall: false,
        );

        final invocation = options.toGradleAssembleTestInvocation(
          isWindows: false,
        );
        expect(
          invocation,
          equals([
            './gradlew',
            ':app:assembleReleaseAndroidTest',
            '-Ptarget=/Users/john/app/patrol_test/app_test.dart',
            '-Pandroid.injected.androidTest.leaveApksInstalledAfterRun=true',
            '-Papp-server-port=1',
            '-Ptest-server-port=2',
            '-Ppatrol-enabled=true',
          ]),
        );
      });
    });

    group('correctly encodes customized invocation', () {
      const dartDefines = {
        'EMAIL': 'user@example.com',
        'PASSWORD': 'ny4ncat',
        'foo': 'bar',
      };

      test('on Windows', () {
        const flutterOpts = FlutterAppOptions(
          command: flutterCommand,
          target: r'C:\Users\john\app\patrol_test\app_test.dart',
          buildMode: BuildMode.release,
          flavor: 'dev',
          buildName: null,
          buildNumber: null,
          dartDefines: dartDefines,
          dartDefineFromFilePaths: [],
        );
        options = const AndroidAppOptions(
          flutter: flutterOpts,
          appServerPort: 1,
          testServerPort: 2,
          uninstall: true,
        );

        final invocation = options.toGradleAssembleTestInvocation(
          isWindows: true,
        );
        expect(
          invocation,
          equals([
            r'.\gradlew.bat',
            ':app:assembleDevReleaseAndroidTest',
            r'-Ptarget=C:\Users\john\app\patrol_test\app_test.dart',
            '-Pdart-defines=RU1BSUw9dXNlckBleGFtcGxlLmNvbQ==,UEFTU1dPUkQ9bnk0bmNhdA==,Zm9vPWJhcg==',
            '-Papp-server-port=1',
            '-Ptest-server-port=2',
            '-Ppatrol-enabled=true',
          ]),
        );
      });

      test('on macOS', () {
        const flutterOpts = FlutterAppOptions(
          command: flutterCommand,
          target: '/Users/john/app/patrol_test/app_test.dart',
          buildMode: BuildMode.debug,
          flavor: 'dev',
          buildName: null,
          buildNumber: null,
          dartDefines: dartDefines,
          dartDefineFromFilePaths: [],
        );
        options = const AndroidAppOptions(
          flutter: flutterOpts,
          appServerPort: 1,
          testServerPort: 2,
          uninstall: true,
        );

        final invocation = options.toGradleAssembleTestInvocation(
          isWindows: false,
        );
        expect(
          invocation,
          equals([
            './gradlew',
            ':app:assembleDevDebugAndroidTest',
            '-Ptarget=/Users/john/app/patrol_test/app_test.dart',
            '-Pdart-defines=RU1BSUw9dXNlckBleGFtcGxlLmNvbQ==,UEFTU1dPUkQ9bnk0bmNhdA==,Zm9vPWJhcg==',
            '-Papp-server-port=1',
            '-Ptest-server-port=2',
            '-Ppatrol-enabled=true',
          ]),
        );
      });

      test('on macOS with no uninstall', () {
        const flutterOpts = FlutterAppOptions(
          command: flutterCommand,
          target: '/Users/john/app/patrol_test/app_test.dart',
          buildMode: BuildMode.debug,
          flavor: 'dev',
          buildName: null,
          buildNumber: null,
          dartDefines: dartDefines,
          dartDefineFromFilePaths: [],
        );
        options = const AndroidAppOptions(
          flutter: flutterOpts,
          appServerPort: 1,
          testServerPort: 2,
          uninstall: false,
        );

        final invocation = options.toGradleConnectedTestInvocation(
          isWindows: false,
        );
        expect(
          invocation,
          equals([
            './gradlew',
            ':app:connectedDevDebugAndroidTest',
            '-Ptarget=/Users/john/app/patrol_test/app_test.dart',
            '-Pdart-defines=RU1BSUw9dXNlckBleGFtcGxlLmNvbQ==,UEFTU1dPUkQ9bnk0bmNhdA==,Zm9vPWJhcg==',
            '-Pandroid.injected.androidTest.leaveApksInstalledAfterRun=true',
            '-Papp-server-port=1',
            '-Ptest-server-port=2',
            '-Ppatrol-enabled=true',
          ]),
        );
      });
    });
  });

  group('IOSAppOptions', () {
    late IOSAppOptions options;

    group(
      'correctly encodes default xcodebuild invocation for simulator with dartDefineFromFile path',
      () {
        const flutterOpts = FlutterAppOptions(
          command: flutterCommand,
          target: 'patrol_test/app_test.dart',
          buildMode: BuildMode.debug,
          flavor: null,
          buildName: null,
          buildNumber: null,
          dartDefines: {},
          dartDefineFromFilePaths: ['somePath.json', 'someOtherPath.json'],
        );

        setUp(() {
          options = IOSAppOptions(
            flutter: flutterOpts,
            scheme: 'Runner',
            configuration: 'Debug',
            simulator: true,
            osVersion: 'latest',
            testServerPort: 8081,
            appServerPort: 8082,
          );
        });

        test('when building tests', () {
          final flutterInvocation = options.toFlutterBuildInvocation(
            flutterOpts.buildMode,
          );

          expect(
            flutterInvocation,
            equals([
              ...['flutter', 'build', 'ios'],
              '--no-version-check',
              '--suppress-analytics',
              ...['--config-only', '--no-codesign', '--debug', '--simulator'],
              ...['--target', 'patrol_test/app_test.dart'],
              ...['--dart-define-from-file', 'somePath.json'],
              ...['--dart-define-from-file', 'someOtherPath.json'],
            ]),
          );

          final xcodebuildInvocation = options.buildForTestingInvocation();

          expect(
            xcodebuildInvocation,
            equals([
              ...['xcodebuild', 'build-for-testing'],
              ...['-workspace', 'Runner.xcworkspace'],
              ...['-scheme', 'Runner'],
              ...['-configuration', 'Debug'],
              ...['-sdk', 'iphonesimulator'],
              ...['-destination', 'generic/platform=iOS Simulator'],
              '-quiet',
              ...['-derivedDataPath', '../build/ios_integ'],
              r'OTHER_SWIFT_FLAGS=$(inherited) -D PATROL_ENABLED',
              r'OTHER_LDFLAGS=$(inherited) -weak_framework XCTest -F$(PLATFORM_DIR)/Developer/Library/Frameworks -L$(PLATFORM_DIR)/Developer/usr/lib',
              r'OTHER_CFLAGS=$(inherited) -D FULL_ISOLATION=0 -D CLEAR_PERMISSIONS=0',
            ]),
          );
        });

        test('when executing tests', () {
          const xcTestRunPath =
              '/Users/charlie/awesome_app/build/ios_integ/Build/Products/Runner_iphonesimulator16.4-arm64-x86_64.xctestrun';

          final xcodebuildInvocation = options.testWithoutBuildingInvocation(
            iosDevice,
            xcTestRunPath: xcTestRunPath,
            resultBundlePath: '',
          );

          expect(
            xcodebuildInvocation,
            equals([
              ...['xcodebuild', 'test-without-building'],
              ...['-xctestrun', xcTestRunPath],
              ...['-only-testing', 'RunnerUITests/RunnerUITests'],
              ...['-destination', 'platform=iOS,id=$iosDeviceId'],
              ...['-destination-timeout', '1'],
              ...['-resultBundlePath', ''],
            ]),
          );
        });
      },
    );

    group(
      'correctly encodes default xcodebuild invocation for simulator without dartDefineFromFile path',
      () {
        const flutterOpts = FlutterAppOptions(
          command: flutterCommand,
          target: 'patrol_test/app_test.dart',
          buildMode: BuildMode.debug,
          flavor: null,
          buildName: null,
          buildNumber: null,
          dartDefines: {},
          dartDefineFromFilePaths: [],
        );

        setUp(() {
          options = IOSAppOptions(
            flutter: flutterOpts,
            scheme: 'Runner',
            configuration: 'Debug',
            simulator: true,
            osVersion: '17.5',
            testServerPort: 8081,
            appServerPort: 8082,
          );
        });

        test('when building tests', () {
          final flutterInvocation = options.toFlutterBuildInvocation(
            flutterOpts.buildMode,
          );

          expect(
            flutterInvocation,
            equals([
              ...['flutter', 'build', 'ios'],
              '--no-version-check',
              '--suppress-analytics',
              ...['--config-only', '--no-codesign', '--debug', '--simulator'],
              ...['--target', 'patrol_test/app_test.dart'],
            ]),
          );

          final xcodebuildInvocation = options.buildForTestingInvocation();

          expect(
            xcodebuildInvocation,
            equals([
              ...['xcodebuild', 'build-for-testing'],
              ...['-workspace', 'Runner.xcworkspace'],
              ...['-scheme', 'Runner'],
              ...['-configuration', 'Debug'],
              ...['-sdk', 'iphonesimulator'],
              ...['-destination', 'generic/platform=iOS Simulator'],
              '-quiet',
              ...['-derivedDataPath', '../build/ios_integ'],
              r'OTHER_SWIFT_FLAGS=$(inherited) -D PATROL_ENABLED',
              r'OTHER_LDFLAGS=$(inherited) -weak_framework XCTest -F$(PLATFORM_DIR)/Developer/Library/Frameworks -L$(PLATFORM_DIR)/Developer/usr/lib',
              r'OTHER_CFLAGS=$(inherited) -D FULL_ISOLATION=0 -D CLEAR_PERMISSIONS=0',
            ]),
          );
        });

        test('when executing tests', () {
          const xcTestRunPath =
              '/Users/charlie/awesome_app/build/ios_integ/Build/Products/Runner_iphonesimulator16.4-arm64-x86_64.xctestrun';

          final xcodebuildInvocation = options.testWithoutBuildingInvocation(
            iosDevice,
            xcTestRunPath: xcTestRunPath,
            resultBundlePath: '',
          );

          expect(
            xcodebuildInvocation,
            equals([
              ...['xcodebuild', 'test-without-building'],
              ...['-xctestrun', xcTestRunPath],
              ...['-only-testing', 'RunnerUITests/RunnerUITests'],
              ...['-destination', 'platform=iOS,id=$iosDeviceId'],
              ...['-destination-timeout', '1'],
              ...['-resultBundlePath', ''],
            ]),
          );
        });
      },
    );

    group('correctly encodes customized xcodebuild invocation for real device', () {
      const flutterOpts = FlutterAppOptions(
        command: flutterCommand,
        target: 'patrol_test/app_test.dart',
        buildMode: BuildMode.release,
        flavor: 'prod',
        buildName: '1.2.3',
        buildNumber: '123',
        dartDefines: {
          'EMAIL': 'user@example.com',
          'PASSWORD': 'ny4ncat',
          'foo': 'bar',
        },
        dartDefineFromFilePaths: [],
      );

      setUp(() {
        options = IOSAppOptions(
          flutter: flutterOpts,
          scheme: 'prod',
          configuration: 'Release-prod',
          simulator: false,
          osVersion: 'latest',
          testServerPort: 8081,
          appServerPort: 8082,
          fullIsolation: true,
        );
      });

      test('when building tests', () {
        final flutterInvocation = options.toFlutterBuildInvocation(
          flutterOpts.buildMode,
        );

        expect(
          flutterInvocation,
          equals([
            ...['flutter', 'build', 'ios'],
            '--no-version-check',
            '--suppress-analytics',
            ...['--config-only', '--no-codesign', '--release'],
            ...['--flavor', 'prod'],
            ...['--build-name', '1.2.3'],
            ...['--build-number', '123'],
            ...['--target', 'patrol_test/app_test.dart'],
            ...['--dart-define', 'EMAIL=user@example.com'],
            ...['--dart-define', 'PASSWORD=ny4ncat'],
            ...['--dart-define', 'foo=bar'],
          ]),
        );

        final xcodebuildInvocation = options.buildForTestingInvocation();

        expect(
          xcodebuildInvocation,
          equals([
            ...['xcodebuild', 'build-for-testing'],
            ...['-workspace', 'Runner.xcworkspace'],
            ...['-scheme', 'prod'],
            ...['-configuration', 'Release-prod'],
            ...['-sdk', 'iphoneos'],
            ...['-destination', 'generic/platform=iOS'],
            '-quiet',
            ...['-derivedDataPath', '../build/ios_integ'],
            r'OTHER_SWIFT_FLAGS=$(inherited) -D PATROL_ENABLED',
            r'OTHER_LDFLAGS=$(inherited) -weak_framework XCTest -F$(PLATFORM_DIR)/Developer/Library/Frameworks -L$(PLATFORM_DIR)/Developer/usr/lib',
            r'OTHER_CFLAGS=$(inherited) -D FULL_ISOLATION=1 -D CLEAR_PERMISSIONS=0',
          ]),
        );
      });
    });

    group('works when device name contains a comma', () {
      setUp(() {
        options = IOSAppOptions(
          flutter: const FlutterAppOptions(
            command: flutterCommand,
            target: 'patrol_test/app_test.dart',
            buildMode: BuildMode.debug,
            flavor: null,
            buildName: null,
            buildNumber: null,
            dartDefines: {},
            dartDefineFromFilePaths: [],
          ),
          scheme: 'Runner',
          configuration: 'Debug',
          simulator: false,
          osVersion: 'latest',
          testServerPort: 8081,
          appServerPort: 8082,
        );
      });

      test('testWithoutBuildingInvocation', () {
        const deviceWithCommaInName = Device(
          name: 'Test, test device',
          id: iosDeviceId,
          targetPlatform: TargetPlatform.iOS,
          real: true,
        );

        const xcTestRunPath =
            '/Users/charlie/awesome_app/build/ios_integ/Build/Products/Runner_iphoneos.xctestrun';

        final xcodebuildInvocation = options.testWithoutBuildingInvocation(
          deviceWithCommaInName,
          xcTestRunPath: xcTestRunPath,
          resultBundlePath: '',
        );

        expect(
          xcodebuildInvocation,
          equals([
            ...['xcodebuild', 'test-without-building'],
            ...['-xctestrun', xcTestRunPath],
            ...['-only-testing', 'RunnerUITests/RunnerUITests'],
            ...['-destination', 'platform=iOS,id=$iosDeviceId'],
            ...['-destination-timeout', '1'],
            ...['-resultBundlePath', ''],
          ]),
        );
      });
    });
  });

  group('MacOSAppOptions', () {
    late MacOSAppOptions options;

    group('correctly encodes Flutter build invocation with build flags', () {
      test('with build name and number', () {
        const flutterOpts = FlutterAppOptions(
          command: flutterCommand,
          target: 'patrol_test/app_test.dart',
          buildMode: BuildMode.release,
          flavor: 'prod',
          buildName: '2.1.0',
          buildNumber: '210',
          dartDefines: {'ENV': 'production'},
          dartDefineFromFilePaths: [],
        );

        options = MacOSAppOptions(
          flutter: flutterOpts,
          scheme: 'prod',
          configuration: 'Release-prod',
          appServerPort: 8082,
          testServerPort: 8081,
        );

        final flutterInvocation = options.toFlutterBuildInvocation(
          flutterOpts.buildMode,
        );

        expect(
          flutterInvocation,
          equals([
            ...['flutter', 'build', 'macos'],
            '--no-version-check',
            '--suppress-analytics',
            ...['--config-only', '--release'],
            ...['--flavor', 'prod'],
            ...['--build-name', '2.1.0'],
            ...['--build-number', '210'],
            ...['--target', 'patrol_test/app_test.dart'],
            ...['--dart-define', 'ENV=production'],
          ]),
        );
      });

      test('without build name and number', () {
        const flutterOpts = FlutterAppOptions(
          command: flutterCommand,
          target: 'patrol_test/app_test.dart',
          buildMode: BuildMode.debug,
          flavor: null,
          buildName: null,
          buildNumber: null,
          dartDefines: {},
          dartDefineFromFilePaths: [],
        );

        options = MacOSAppOptions(
          flutter: flutterOpts,
          scheme: 'Runner',
          configuration: 'Debug',
          appServerPort: 8082,
          testServerPort: 8081,
        );

        final flutterInvocation = options.toFlutterBuildInvocation(
          flutterOpts.buildMode,
        );

        expect(
          flutterInvocation,
          equals([
            ...['flutter', 'build', 'macos'],
            '--no-version-check',
            '--suppress-analytics',
            ...['--config-only', '--debug'],
            ...['--target', 'patrol_test/app_test.dart'],
          ]),
        );
      });
    });
  });

  group('WebAppOptions', () {
    late WebAppOptions options;

    group('correctly encodes Flutter build invocation', () {
      test('with minimal configuration', () {
        const flutterOpts = FlutterAppOptions(
          command: flutterCommand,
          target: 'patrol_test/app_test.dart',
          buildMode: BuildMode.debug,
          flavor: null,
          buildName: null,
          buildNumber: null,
          dartDefines: {},
          dartDefineFromFilePaths: [],
        );

        options = const WebAppOptions(flutter: flutterOpts);

        final flutterInvocation = options.toFlutterBuildInvocation();

        expect(
          flutterInvocation,
          equals([
            'flutter',
            'build',
            'web',
            '--target=patrol_test/app_test.dart',
            '--debug',
          ]),
        );
      });

      test('with release build mode', () {
        const flutterOpts = FlutterAppOptions(
          command: flutterCommand,
          target: 'integration_test/app_test.dart',
          buildMode: BuildMode.release,
          flavor: null,
          buildName: null,
          buildNumber: null,
          dartDefines: {},
          dartDefineFromFilePaths: [],
        );

        options = const WebAppOptions(flutter: flutterOpts);

        final flutterInvocation = options.toFlutterBuildInvocation();

        expect(
          flutterInvocation,
          equals([
            'flutter',
            'build',
            'web',
            '--target=integration_test/app_test.dart',
            '--release',
          ]),
        );
      });

      test('with dart defines', () {
        const flutterOpts = FlutterAppOptions(
          command: flutterCommand,
          target: 'patrol_test/app_test.dart',
          buildMode: BuildMode.debug,
          flavor: null,
          buildName: null,
          buildNumber: null,
          dartDefines: {
            'EMAIL': 'user@example.com',
            'PASSWORD': 'ny4ncat',
            'API_KEY': 'secret123',
          },
          dartDefineFromFilePaths: [],
        );

        options = const WebAppOptions(flutter: flutterOpts);

        final flutterInvocation = options.toFlutterBuildInvocation();

        expect(
          flutterInvocation,
          equals([
            'flutter',
            'build',
            'web',
            '--target=patrol_test/app_test.dart',
            '--debug',
            '--dart-define=EMAIL=user@example.com',
            '--dart-define=PASSWORD=ny4ncat',
            '--dart-define=API_KEY=secret123',
          ]),
        );
      });

      test('with dart define from file paths', () {
        const flutterOpts = FlutterAppOptions(
          command: flutterCommand,
          target: 'patrol_test/app_test.dart',
          buildMode: BuildMode.release,
          flavor: null,
          buildName: null,
          buildNumber: null,
          dartDefines: {},
          dartDefineFromFilePaths: ['defines.json', 'secrets.env'],
        );

        options = const WebAppOptions(flutter: flutterOpts);

        final flutterInvocation = options.toFlutterBuildInvocation();

        expect(
          flutterInvocation,
          equals([
            'flutter',
            'build',
            'web',
            '--target=patrol_test/app_test.dart',
            '--release',
            '--dart-define-from-file=defines.json',
            '--dart-define-from-file=secrets.env',
          ]),
        );
      });

      test('with both dart defines and dart define from file', () {
        const flutterOpts = FlutterAppOptions(
          command: flutterCommand,
          target: 'patrol_test/web_test.dart',
          buildMode: BuildMode.profile,
          flavor: null,
          buildName: null,
          buildNumber: null,
          dartDefines: {'ENV': 'production', 'DEBUG_MODE': 'false'},
          dartDefineFromFilePaths: ['config.json'],
        );

        options = const WebAppOptions(flutter: flutterOpts);

        final flutterInvocation = options.toFlutterBuildInvocation();

        expect(
          flutterInvocation,
          equals([
            'flutter',
            'build',
            'web',
            '--target=patrol_test/web_test.dart',
            '--profile',
            '--dart-define=ENV=production',
            '--dart-define=DEBUG_MODE=false',
            '--dart-define-from-file=config.json',
          ]),
        );
      });

      test('with custom flutter command arguments', () {
        const customFlutterCommand = FlutterCommand('flutter', [
          '--verbose',
          '--no-pub',
        ]);

        const flutterOpts = FlutterAppOptions(
          command: customFlutterCommand,
          target: 'test/my_test.dart',
          buildMode: BuildMode.debug,
          flavor: null,
          buildName: null,
          buildNumber: null,
          dartDefines: {},
          dartDefineFromFilePaths: [],
        );

        options = const WebAppOptions(flutter: flutterOpts);

        final flutterInvocation = options.toFlutterBuildInvocation();

        expect(
          flutterInvocation,
          equals([
            'flutter',
            '--verbose',
            '--no-pub',
            'build',
            'web',
            '--target=test/my_test.dart',
            '--debug',
          ]),
        );
      });

      test('flavor is ignored for web builds', () {
        // Note: Web builds don't support flavors, so this should be handled
        // by not including --flavor in the command
        const flutterOpts = FlutterAppOptions(
          command: flutterCommand,
          target: 'patrol_test/app_test.dart',
          buildMode: BuildMode.release,
          flavor: 'production', // This should be ignored for web
          buildName: null,
          buildNumber: null,
          dartDefines: {},
          dartDefineFromFilePaths: [],
        );

        options = const WebAppOptions(flutter: flutterOpts);

        final flutterInvocation = options.toFlutterBuildInvocation();

        // Verify that --flavor is NOT included in the invocation
        expect(
          flutterInvocation,
          equals([
            'flutter',
            'build',
            'web',
            '--target=patrol_test/app_test.dart',
            '--release',
          ]),
        );
        expect(flutterInvocation, isNot(contains('--flavor')));
      });
    });

    group('toEnvironmentVariables', () {
      const flutterOpts = FlutterAppOptions(
        command: flutterCommand,
        target: 'patrol_test/app_test.dart',
        buildMode: BuildMode.debug,
        flavor: null,
        buildName: null,
        buildNumber: null,
        dartDefines: {},
        dartDefineFromFilePaths: [],
      );

      test('omits unset options', () {
        options = const WebAppOptions(flutter: flutterOpts);

        expect(options.toEnvironmentVariables(), isEmpty);
      });

      test('includes only the options that were set', () {
        options = const WebAppOptions(
          flutter: flutterOpts,
          timeout: 30000,
          headless: true,
          channel: 'chrome',
        );

        expect(
          options.toEnvironmentVariables(),
          equals({
            'PATROL_WEB_TIMEOUT': '30000',
            'PATROL_WEB_HEADLESS': 'true',
            'PATROL_WEB_CHANNEL': 'chrome',
          }),
        );
      });

      test('stringifies every supported option', () {
        options = const WebAppOptions(
          flutter: flutterOpts,
          retries: 2,
          video: 'on',
          timeout: 30000,
          workers: 4,
          reporter: 'html',
          locale: 'en-US',
          timezone: 'UTC',
          colorScheme: 'dark',
          geolocation: '{"latitude":1,"longitude":2}',
          permissions: '["geolocation"]',
          userAgent: 'test-agent',
          viewport: '{"width":800,"height":600}',
          globalTimeout: 60000,
          shard: '1/2',
          headless: false,
          browserArgs: '["--no-sandbox"]',
          channel: 'msedge',
          executablePath: '/usr/bin/chromium',
          slowMo: 100,
          chromiumSandbox: false,
          downloadsPath: '/tmp/downloads',
          ignoreDefaultArgs: 'true',
          proxy: '{"server":"http://localhost:8080"}',
          browserTimeout: 5000,
          tracesDir: '/tmp/traces',
          bypassCsp: true,
          ignoreHttpsErrors: true,
          offline: false,
          httpCredentials: '{"username":"user","password":"pass"}',
          extraHttpHeaders: '{"X-Test":"1"}',
          screenshot: 'only-on-failure',
          trace: 'retain-on-failure',
          storageState: '/tmp/state.json',
          acceptDownloads: true,
        );

        expect(
          options.toEnvironmentVariables(),
          equals({
            'PATROL_WEB_RETRIES': '2',
            'PATROL_WEB_VIDEO': 'on',
            'PATROL_WEB_TIMEOUT': '30000',
            'PATROL_WEB_WORKERS': '4',
            'PATROL_WEB_REPORTER': 'html',
            'PATROL_WEB_LOCALE': 'en-US',
            'PATROL_WEB_TIMEZONE': 'UTC',
            'PATROL_WEB_COLOR_SCHEME': 'dark',
            'PATROL_WEB_GEOLOCATION': '{"latitude":1,"longitude":2}',
            'PATROL_WEB_PERMISSIONS': '["geolocation"]',
            'PATROL_WEB_USER_AGENT': 'test-agent',
            'PATROL_WEB_VIEWPORT': '{"width":800,"height":600}',
            'PATROL_WEB_GLOBAL_TIMEOUT': '60000',
            'PATROL_WEB_SHARD': '1/2',
            'PATROL_WEB_HEADLESS': 'false',
            'PATROL_WEB_BROWSER_ARGS': '["--no-sandbox"]',
            'PATROL_WEB_CHANNEL': 'msedge',
            'PATROL_WEB_EXECUTABLE_PATH': '/usr/bin/chromium',
            'PATROL_WEB_SLOW_MO': '100',
            'PATROL_WEB_CHROMIUM_SANDBOX': 'false',
            'PATROL_WEB_DOWNLOADS_PATH': '/tmp/downloads',
            'PATROL_WEB_IGNORE_DEFAULT_ARGS': 'true',
            'PATROL_WEB_PROXY': '{"server":"http://localhost:8080"}',
            'PATROL_WEB_BROWSER_TIMEOUT': '5000',
            'PATROL_WEB_TRACES_DIR': '/tmp/traces',
            'PATROL_WEB_BYPASS_CSP': 'true',
            'PATROL_WEB_IGNORE_HTTPS_ERRORS': 'true',
            'PATROL_WEB_OFFLINE': 'false',
            'PATROL_WEB_HTTP_CREDENTIALS':
                '{"username":"user","password":"pass"}',
            'PATROL_WEB_EXTRA_HTTP_HEADERS': '{"X-Test":"1"}',
            'PATROL_WEB_SCREENSHOT': 'only-on-failure',
            'PATROL_WEB_TRACE': 'retain-on-failure',
            'PATROL_WEB_STORAGE_STATE': '/tmp/state.json',
            'PATROL_WEB_ACCEPT_DOWNLOADS': 'true',
          }),
        );
      });
    });
  });
}
