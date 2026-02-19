import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:mcp_dart/mcp_dart.dart';
import 'package:patrol_cli/develop.dart' show Device, TargetPlatform;

enum ScreenshotPlatform {
  android('adb', ['exec-out', 'screencap', '-p']),
  ios('xcrun', [
    'simctl',
    'io',
    'booted',
    'screenshot',
    '--type=png',
    '/dev/stdout',
  ]);

  const ScreenshotPlatform(this.command, this.args);

  final String command;
  final List<String> args;

  static ScreenshotPlatform fromDevice(Device device) =>
      switch (device.targetPlatform) {
        TargetPlatform.android => ScreenshotPlatform.android,
        TargetPlatform.iOS => ScreenshotPlatform.ios,
        _ => throw ArgumentError(
          'Screenshot not supported for platform: '
          '${device.targetPlatform.name}',
        ),
      };
}

abstract final class ScreenshotService {
  static const _maxHeight = 800;

  static Future<CallToolResult> handleScreenshotRequest(Device? device) async {
    try {
      if (device == null) {
        return const CallToolResult(
          content: [
            TextContent(
              text:
                  'No active patrol session. '
                  'Run a test first so the device platform can be detected.',
            ),
          ],
          isError: true,
        );
      }

      final platform = ScreenshotPlatform.fromDevice(device);
      final bytes = await _captureScreenshot(platform);
      final base64Data = base64Encode(bytes);

      return CallToolResult(
        content: [ImageContent(data: base64Data, mimeType: 'image/png')],
      );
    } catch (e) {
      // Catches both Exception and Error (e.g. ArgumentError from
      // unsupported platform).
      return CallToolResult(
        content: [TextContent(text: 'Failed to capture screenshot: $e')],
        isError: true,
      );
    }
  }

  static Future<Uint8List> _captureScreenshot(
    ScreenshotPlatform platform,
  ) async {
    final process = await Process.start(platform.command, platform.args);

    final bytes = await process.stdout.expand((chunk) => chunk).toList();

    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      final stderr = await process.stderr.transform(utf8.decoder).join();
      throw Exception('Failed to capture screenshot: $stderr');
    }

    return _resizeImage(Uint8List.fromList(bytes));
  }

  static Uint8List _resizeImage(Uint8List bytes) {
    try {
      final image = img.decodeImage(bytes);
      if (image == null || image.height <= _maxHeight) {
        return bytes;
      }

      final resized = img.copyResize(image, height: _maxHeight);
      return Uint8List.fromList(img.encodePng(resized));
    } on Exception {
      return bytes;
    }
  }
}
