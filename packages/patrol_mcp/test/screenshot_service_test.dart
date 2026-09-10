import 'package:patrol_cli/patrol_cli.dart' show Device, TargetPlatform;
import 'package:patrol_mcp/src/screenshot_service.dart';
import 'package:test/test.dart';

Device _device(TargetPlatform platform) =>
    Device(name: 'id', id: 'id', targetPlatform: platform, real: false);

void main() {
  test('androidScreenshotArgs captures via adb exec-out screencap', () {
    final args = androidScreenshotArgs(_device(TargetPlatform.android));
    expect(args, ['-s', 'id', 'exec-out', 'screencap', '-p']);
  });

  test('iosScreenshotArgs writes to the given outputPath, not /dev/stdout', () {
    final args = iosScreenshotArgs(
      _device(TargetPlatform.iOS),
      '/tmp/shot.png',
    );
    expect(args, [
      'simctl',
      'io',
      'id',
      'screenshot',
      '--type=png',
      '/tmp/shot.png',
    ]);
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
