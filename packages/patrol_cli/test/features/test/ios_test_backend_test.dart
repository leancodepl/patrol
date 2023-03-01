import 'package:patrol_cli/src/features/devices/device.dart';
import 'package:patrol_cli/src/features/test/ios_test_backend.dart';
import 'package:test/test.dart';

void main() {
  group('IOSAppOptions', () {
    late Device device;
    late IOSAppOptions options;

    test('correctly encodes default invocation on simulator', () {
      device = Device(
        name: 'iPhone 14',
        id: '633247FA-E35B-4E60-AEB3-FC2D9C52FAD5',
        targetPlatform: TargetPlatform.iOS,
        real: false,
      );
      options = IOSAppOptions(
        target: 'integration_test/app_test.dart',
        flavor: null,
        dartDefines: {},
        scheme: 'Runner',
        xcconfigFile: 'Flutter/Debug.xcconfig',
        configuration: 'Debug',
      );

      final flutterInvocation = options.toFlutterBuildInvocation(device);
      expect(
        flutterInvocation,
        equals([
          ...['flutter', 'build', 'ios'],
          '--no-version-check',
          ...['--config-only', '--no-codesign', '--debug', '--simulator'],
          ...['--target', 'integration_test/app_test.dart'],
        ]),
      );

      final xcodebuildInvocation = options.buildForTestingInvocation(device);

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
      device = Device(
        name: 'iPhone 14',
        id: '633247FA-E35B-4E60-AEB3-FC2D9C52FAD5',
        targetPlatform: TargetPlatform.iOS,
        real: true,
      );
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
      );

      final flutterInvocation = options.toFlutterBuildInvocation(device);
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

      final xcodebuildInvocation = options.buildForTestingInvocation(device);

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
