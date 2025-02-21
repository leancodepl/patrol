import 'package:patrol_cli/src/crossplatform/app_options.dart';
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
          target: r'C:\Users\john\app\integration_test\app_test.dart',
          buildMode: BuildMode.debug,
          flavor: null,
          dartDefines: {},
          dartDefineFromFilePaths: ['somePath.json', 'someOtherPath.json'],
        );
        options = const AndroidAppOptions(
          flutter: flutterOptions,
          appServerPort: 1,
          testServerPort: 2,
        );

        final invocation =
            options.toGradleAssembleTestInvocation(isWindows: true);
        expect(
          invocation,
          equals([
            r'.\gradlew.bat',
            ':app:assembleDebugAndroidTest',
            r'-Ptarget=C:\Users\john\app\integration_test\app_test.dart',
            '-Ptest-server-port=2',
          ]),
        );
      });

      test('on macOS', () {
        const flutterOpts = FlutterAppOptions(
          command: flutterCommand,
          target: '/Users/john/app/integration_test/app_test.dart',
          buildMode: BuildMode.release,
          flavor: null,
          dartDefines: {},
          dartDefineFromFilePaths: ['somePath.json', 'someOtherPath.json'],
        );
        options = const AndroidAppOptions(
          flutter: flutterOpts,
          appServerPort: 1,
          testServerPort: 2,
        );

        final invocation =
            options.toGradleAssembleTestInvocation(isWindows: false);
        expect(
          invocation,
          equals([
            './gradlew',
            ':app:assembleReleaseAndroidTest',
            '-Ptarget=/Users/john/app/integration_test/app_test.dart',
            '-Papp-server-port=1',
            '-Ptest-server-port=2',
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
          target: r'C:\Users\john\app\integration_test\app_test.dart',
          buildMode: BuildMode.release,
          flavor: 'dev',
          dartDefines: dartDefines,
          dartDefineFromFilePaths: [],
        );
        options = const AndroidAppOptions(
          flutter: flutterOpts,
          appServerPort: 1,
          testServerPort: 2,
        );

        final invocation =
            options.toGradleAssembleTestInvocation(isWindows: true);
        expect(
          invocation,
          equals([
            r'.\gradlew.bat',
            ':app:assembleDevReleaseAndroidTest',
            r'-Ptarget=C:\Users\john\app\integration_test\app_test.dart',
            '-Pdart-defines=RU1BSUw9dXNlckBleGFtcGxlLmNvbQ==,UEFTU1dPUkQ9bnk0bmNhdA==,Zm9vPWJhcg==,RkxVVFRFUl9BUFBfRkxBVk9SPWRldg==',
            '-Papp-server-port=1',
            '-Ptest-server-port=2',
          ]),
        );
      });

      test('on macOS', () {
        const flutterOpts = FlutterAppOptions(
          command: flutterCommand,
          target: '/Users/john/app/integration_test/app_test.dart',
          buildMode: BuildMode.debug,
          flavor: 'dev',
          dartDefines: dartDefines,
          dartDefineFromFilePaths: [],
        );
        options = const AndroidAppOptions(
          flutter: flutterOpts,
          appServerPort: 1,
          testServerPort: 2,
        );

        final invocation =
            options.toGradleAssembleTestInvocation(isWindows: false);
        expect(
          invocation,
          equals([
            './gradlew',
            ':app:assembleDevDebugAndroidTest',
            '-Ptarget=/Users/john/app/integration_test/app_test.dart',
            '-Pdart-defines=RU1BSUw9dXNlckBleGFtcGxlLmNvbQ==,UEFTU1dPUkQ9bnk0bmNhdA==,Zm9vPWJhcg==,RkxVVFRFUl9BUFBfRkxBVk9SPWRldg==',
            '-Papp-server-port=1',
            '-Ptest-server-port=2',
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
        target: 'integration_test/app_test.dart',
        buildMode: BuildMode.debug,
        flavor: null,
        dartDefines: {},
        dartDefineFromFilePaths: ['somePath.json', 'someOtherPath.json'],
      );

      setUp(() {
        options = IOSAppOptions(
          flutter: flutterOpts,
          scheme: 'Runner',
          configuration: 'Debug',
          simulator: true,
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
            ...['--target', 'integration_test/app_test.dart'],
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
            ...['-destination', 'platform=iOS,name=iPhone 13'],
            ...['-destination-timeout', '1'],
            ...['-resultBundlePath', ''],
          ]),
        );
      });
    });

    group(
        'correctly encodes default xcodebuild invocation for simulator without dartDefineFromFile path',
        () {
      const flutterOpts = FlutterAppOptions(
        command: flutterCommand,
        target: 'integration_test/app_test.dart',
        buildMode: BuildMode.debug,
        flavor: null,
        dartDefines: {},
        dartDefineFromFilePaths: [],
      );

      setUp(() {
        options = IOSAppOptions(
          flutter: flutterOpts,
          scheme: 'Runner',
          configuration: 'Debug',
          simulator: true,
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
            ...['--target', 'integration_test/app_test.dart'],
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
            ...['-destination', 'platform=iOS,name=iPhone 13'],
            ...['-destination-timeout', '1'],
            ...['-resultBundlePath', ''],
          ]),
        );
      });
    });

    group(
      'correctly encodes customized xcodebuild invocation for real device',
      () {
        const flutterOpts = FlutterAppOptions(
          command: flutterCommand,
          target: 'integration_test/app_test.dart',
          buildMode: BuildMode.release,
          flavor: 'prod',
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
              ...['--config-only', '--no-codesign', '--release'],
              ...['--flavor', 'prod'],
              ...['--target', 'integration_test/app_test.dart'],
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
            ]),
          );
        });
      },
    );
  });
}
