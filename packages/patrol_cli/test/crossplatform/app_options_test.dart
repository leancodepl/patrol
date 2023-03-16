import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:test/test.dart';

void main() {
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

    test('correctly encodes default invocation on simulator', () {
      final flutterOpts = FlutterAppOptions(
        target: 'integration_test/app_test.dart',
        buildMode: BuildMode.debug,
        flavor: null,
        dartDefines: {},
      );
      options = IOSAppOptions(
        flutter: flutterOpts,
        scheme: 'Runner',
        configuration: 'Debug',
        simulator: true,
      );

      final flutterInvocation =
          options.toFlutterBuildInvocation(flutterOpts.buildMode);
      expect(
        flutterInvocation,
        equals([
          ...['flutter', 'build', 'ios'],
          '--no-version-check',
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
          ...['-xcconfig', 'Flutter/Debug.xcconfig'],
          ...['-configuration', 'Debug'],
          ...['-sdk', 'iphonesimulator'],
          ...['-destination', 'generic/platform=iOS Simulator'],
          '-quiet',
          ...['-derivedDataPath', '../build/ios_integ'],
          r'OTHER_SWIFT_FLAGS=$(inherited) -D PATROL_ENABLED',
        ]),
      );
    });

    test('correctly encodes customized invocation on real device', () {
      final flutterOpts = FlutterAppOptions(
        target: 'integration_test/app_test.dart',
        buildMode: BuildMode.debug,
        flavor: 'dev',
        dartDefines: {
          'EMAIL': 'user@example.com',
          'PASSWORD': 'ny4ncat',
          'foo': 'bar',
        },
      );
      options = IOSAppOptions(
        flutter: flutterOpts,
        scheme: 'dev',
        configuration: 'Debug-dev',
        simulator: false,
      );

      final flutterInvocation =
          options.toFlutterBuildInvocation(flutterOpts.buildMode);
      expect(
        flutterInvocation,
        equals([
          ...['flutter', 'build', 'ios'],
          '--no-version-check',
          ...['--config-only', '--no-codesign', '--debug'],
          ...['--flavor', 'dev'],
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
          ...['-scheme', 'dev'],
          ...['-xcconfig', 'Flutter/Debug.xcconfig'],
          ...['-configuration', 'Debug-dev'],
          ...['-sdk', 'iphoneos'],
          ...['-destination', 'generic/platform=iOS'],
          '-quiet',
          ...['-derivedDataPath', '../build/ios_integ'],
          r'OTHER_SWIFT_FLAGS=$(inherited) -D PATROL_ENABLED',
        ]),
      );
    });
  });
}
