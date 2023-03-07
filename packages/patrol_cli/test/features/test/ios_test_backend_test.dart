import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:test/test.dart';

void main() {
  group('IOSAppOptions', () {
    late IOSAppOptions options;

    test('correctly encodes default invocation on simulator', () {
      options = IOSAppOptions(
        target: 'integration_test/app_test.dart',
        flavor: null,
        dartDefines: {},
        scheme: 'Runner',
        xcconfigFile: 'Flutter/Debug.xcconfig',
        configuration: 'Debug',
        simulator: true,
      );

      final flutterInvocation = options.toFlutterBuildInvocation();
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
      options = IOSAppOptions(
        target: 'integration_test/app_test.dart',
        flavor: 'dev',
        dartDefines: {
          'EMAIL': 'user@example.com',
          'PASSWORD': 'ny4ncat',
          'foo': 'bar',
        },
        scheme: 'dev',
        xcconfigFile: 'Flutter/Debug.xcconfig',
        configuration: 'Debug-dev',
        simulator: false,
      );

      final flutterInvocation = options.toFlutterBuildInvocation();
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
