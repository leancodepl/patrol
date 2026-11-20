import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:mcp_dart/mcp_dart.dart';
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

  group('a web session', () {
    final web = _device(TargetPlatform.web);
    final png = Uint8List.fromList(
      img.encodePng(img.Image(width: 4, height: 4)),
    );

    test('captures the page through the Chrome debugger port', () async {
      String? asked;
      final result = await ScreenshotService.handleScreenshotRequest(
        web,
        webDebuggerPort: '9222',
        captureWebPage: (port) async {
          asked = port;
          return png;
        },
      );

      expect(asked, '9222');
      expect(result.isError, isNot(true));
      expect(result.content.single, isA<ImageContent>());
    });

    test('says so when the browser has no debugger port yet', () async {
      final result = await ScreenshotService.handleScreenshotRequest(
        web,
        captureWebPage: (_) => throw StateError('must not be called'),
      );

      expect(result.isError, isTrue);
      expect(
        (result.content.single as TextContent).text,
        contains('no Chrome debugger port'),
      );
    });

    test('reports a capture that fails', () async {
      final result = await ScreenshotService.handleScreenshotRequest(
        web,
        webDebuggerPort: '9222',
        captureWebPage: (_) async => throw Exception('Chrome lists no page'),
      );

      expect(result.isError, isTrue);
      expect(
        (result.content.single as TextContent).text,
        contains('Chrome lists no page'),
      );
    });
  });
}
