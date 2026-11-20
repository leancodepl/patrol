import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/mcp/screenshot_service.dart';
import 'package:test/test.dart';

Device _device(TargetPlatform platform) =>
    Device(name: 'id', id: 'id', targetPlatform: platform, real: false);

void main() {
  group('ScreenshotPlatform.argsFor', () {
    test('captures via adb exec-out screencap', () {
      expect(
        ScreenshotPlatform.android.argsFor(_device(TargetPlatform.android)),
        ['-s', 'id', 'exec-out', 'screencap', '-p'],
      );
    });

    test('writes an iOS capture to the given path', () {
      expect(
        ScreenshotPlatform.ios.argsFor(
          _device(TargetPlatform.iOS),
          outputPath: '/tmp/shot.png',
        ),
        ['simctl', 'io', 'id', 'screenshot', '--type=png', '/tmp/shot.png'],
      );
    });

    test('refuses an iOS capture with no path to write to', () {
      // `simctl io screenshot` renames a temp file into the destination
      // directory, which fails on /dev/stdout with a permission error.
      expect(
        () => ScreenshotPlatform.ios.argsFor(_device(TargetPlatform.iOS)),
        throwsArgumentError,
      );
    });
  });

  group('ScreenshotPlatform.fromDevice', () {
    test('maps android and iOS to their platform', () {
      expect(
        ScreenshotPlatform.fromDevice(_device(TargetPlatform.android)),
        ScreenshotPlatform.android,
      );
      expect(
        ScreenshotPlatform.fromDevice(_device(TargetPlatform.iOS)),
        ScreenshotPlatform.ios,
      );
    });

    test('throws for unsupported platforms', () {
      expect(
        () => ScreenshotPlatform.fromDevice(_device(TargetPlatform.web)),
        throwsArgumentError,
      );
    });
  });
}
