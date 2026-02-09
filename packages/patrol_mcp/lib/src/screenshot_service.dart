import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:mcp_dart/mcp_dart.dart';

enum _Platform {
  android('adb', ['exec-out', 'screencap', '-p']),
  ios('xcrun', [
    'simctl',
    'io',
    'booted',
    'screenshot',
    '--type=png',
    '/dev/stdout',
  ]);

  const _Platform(this.command, this.args);

  final String command;
  final List<String> args;

  static _Platform fromString(String name) => switch (name.toLowerCase()) {
    'android' => _Platform.android,
    'ios' => _Platform.ios,
    _ => throw ArgumentError(
      'Invalid platform: $name. Must be "android" or "ios"',
    ),
  };
}

abstract final class ScreenshotService {
  static const _maxHeight = 800;

  static Future<CallToolResult> handleScreenshotRequest(
    Map<String, dynamic> args,
  ) async {
    try {
      final platformName = args['platform'] as String?;
      if (platformName == null) {
        return CallToolResult.fromContent(
          content: [
            const TextContent(text: 'Missing required parameter: platform'),
          ],
          isError: true,
        );
      }

      final platform = _Platform.fromString(platformName);
      final bytes = await _captureScreenshot(platform);
      final base64 = base64Encode(bytes);

      return CallToolResult.fromContent(
        content: [ImageContent(data: base64, mimeType: 'image/png')],
      );
    } on Exception catch (e) {
      return CallToolResult.fromContent(
        content: [TextContent(text: 'Failed to capture screenshot: $e')],
        isError: true,
      );
    }
  }

  static Future<Uint8List> _captureScreenshot(_Platform platform) async {
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
