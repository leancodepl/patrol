import 'package:path/path.dart' as path;
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:platform/platform.dart';
import 'package:test/test.dart';

import '../src/common.dart';
import '../src/fixtures.dart';

void main() {
  _test(initFakePlatform(Platform.macOS));
  _test(initFakePlatform(Platform.windows));
}

final _path = path.Context(style: path.Style.posix);

void _test(Platform platform) {
  group('AndroidAppOptions', () {
    late AndroidAppOptions options;

    group('correctly encodes default invocation', () {
      test('on Windows', () {
        final flutterOptions = FlutterAppOptions(
          target: r'C:\Users\john\app\integration_test\app_test.dart',
          buildMode: BuildMode.debug,
          flavor: null,
          dartDefines: {},
        );
        options = AndroidAppOptions(flutter: flutterOptions);

        final invocation =
            options.toGradleAssembleTestInvocation(isWindows: true);
        expect(
          invocation,
          equals([
            r'.\gradlew.bat',
            ':app:assembleDebugAndroidTest',
            r'-Ptarget=C:\Users\john\app\integration_test\app_test.dart',
          ]),
        );
      });

      test('on macOS', () {
        final flutterOpts = FlutterAppOptions(
          target: '/Users/john/app/integration_test/app_test.dart',
          buildMode: BuildMode.debug,
          flavor: null,
          dartDefines: {},
        );
        options = AndroidAppOptions(flutter: flutterOpts);

        final invocation =
            options.toGradleAssembleTestInvocation(isWindows: false);
        expect(
          invocation,
          equals([
            './gradlew',
            ':app:assembleDebugAndroidTest',
            '-Ptarget=/Users/john/app/integration_test/app_test.dart',
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
        final flutterOpts = FlutterAppOptions(
          target: r'C:\Users\john\app\integration_test\app_test.dart',
          buildMode: BuildMode.debug,
          flavor: 'dev',
          dartDefines: dartDefines,
        );
        options = AndroidAppOptions(flutter: flutterOpts);

        final invocation =
            options.toGradleAssembleTestInvocation(isWindows: true);
        expect(
          invocation,
          equals([
            r'.\gradlew.bat',
            ':app:assembleDevDebugAndroidTest',
            r'-Ptarget=C:\Users\john\app\integration_test\app_test.dart',
            '-Pdart-defines=RU1BSUw9dXNlckBleGFtcGxlLmNvbQ==,UEFTU1dPUkQ9bnk0bmNhdA==,Zm9vPWJhcg=='
          ]),
        );
      });

      test('on macOS', () {
        final flutterOpts = FlutterAppOptions(
          target: '/Users/john/app/integration_test/app_test.dart',
          buildMode: BuildMode.debug,
          flavor: 'dev',
          dartDefines: dartDefines,
        );
        options = AndroidAppOptions(flutter: flutterOpts);

        final invocation =
            options.toGradleAssembleTestInvocation(isWindows: false);
        expect(
          invocation,
          equals([
            './gradlew',
            ':app:assembleDevDebugAndroidTest',
            '-Ptarget=/Users/john/app/integration_test/app_test.dart',
            '-Pdart-defines=RU1BSUw9dXNlckBleGFtcGxlLmNvbQ==,UEFTU1dPUkQ9bnk0bmNhdA==,Zm9vPWJhcg=='
          ]),
        );
      });
    });
  });

  group('IOSAppOptions', () {
    late IOSAppOptions options;

    group('correctly encodes default xcodebuild invocation for simulator', () {
      final flutterOpts = FlutterAppOptions(
        target: 'integration_test/app_test.dart',
        buildMode: BuildMode.debug,
        flavor: null,
        dartDefines: {},
      );

      setUp(() {
        options = IOSAppOptions(
          flutter: flutterOpts,
          scheme: 'Runner',
          configuration: 'Debug',
          simulator: true,
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
            ...['--config-only', '--no-codesign', '--debug', '--simulator'],
            ...['--target', 'integration_test/app_test.dart'],
          ]),
        );

        final xcodebuildInvocation = options.buildForTestingInvocation(_path);

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
        );

        expect(
          xcodebuildInvocation,
          equals([
            ...['xcodebuild', 'test-without-building'],
            ...['-xctestrun', xcTestRunPath],
            ...['-only-testing', 'RunnerUITests'],
            ...['-destination', 'platform=iOS,name=iPhone 13'],
          ]),
        );
      });
    });

    group(
      'correctly encodes customized xcodebuild invocation for real device',
      () {
        final flutterOpts = FlutterAppOptions(
          target: 'integration_test/app_test.dart',
          buildMode: BuildMode.release,
          flavor: 'prod',
          dartDefines: {
            'EMAIL': 'user@example.com',
            'PASSWORD': 'ny4ncat',
            'foo': 'bar',
          },
        );

        setUp(() {
          options = IOSAppOptions(
            flutter: flutterOpts,
            scheme: 'prod',
            configuration: 'Release-prod',
            simulator: false,
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
              ...['--config-only', '--no-codesign', '--release'],
              ...['--flavor', 'prod'],
              ...['--target', 'integration_test/app_test.dart'],
              ...['--dart-define', 'EMAIL=user@example.com'],
              ...['--dart-define', 'PASSWORD=ny4ncat'],
              ...['--dart-define', 'foo=bar'],
            ]),
          );

          final xcodebuildInvocation = options.buildForTestingInvocation(_path);

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
