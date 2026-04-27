import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:mcp_dart/mcp_dart.dart';
import 'package:patrol_cli/patrol_cli.dart' show Device, TargetPlatform;

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

  static Future<CallToolResult> handleScreenshotRequest(
    Device? device, {
    String? webDebuggerPort,
  }) async {
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

      if (device.targetPlatform == TargetPlatform.web) {
        return _handleWebScreenshot(webDebuggerPort);
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

  static Future<CallToolResult> _handleWebScreenshot(
    String? debuggerPort,
  ) async {
    if (debuggerPort == null) {
      return const CallToolResult(
        content: [
          TextContent(text: 'Web debugger port not available.'),
        ],
        isError: true,
      );
    }

    try {
      final bytes = await _captureWebScreenshot(debuggerPort);
      final resized = _resizeImage(bytes);
      final base64Data = base64Encode(resized);

      return CallToolResult(
        content: [ImageContent(data: base64Data, mimeType: 'image/png')],
      );
    } catch (e) {
      return CallToolResult(
        content: [TextContent(text: 'Failed to capture web screenshot: $e')],
        isError: true,
      );
    }
  }

  /// Captures a screenshot via Chrome DevTools Protocol.
  static Future<Uint8List> _captureWebScreenshot(String debuggerPort) async {
    // Get the list of debuggable targets
    final httpClient = HttpClient();
    try {
      final request = await httpClient.getUrl(
        Uri.parse('http://localhost:$debuggerPort/json'),
      );
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final targets = jsonDecode(body) as List;

      // Find the first page target
      final pageTarget = targets.firstWhere(
        (t) => (t as Map)['type'] == 'page',
        orElse: () => throw Exception('No page target found'),
      ) as Map;

      final wsUrl = pageTarget['webSocketDebuggerUrl'] as String?;
      if (wsUrl == null) {
        throw Exception('No WebSocket debugger URL for page target');
      }

      // Connect via WebSocket and send CDP command
      final ws = await WebSocket.connect(wsUrl);
      try {
        ws.add(jsonEncode({'id': 1, 'method': 'Page.captureScreenshot'}));

        await for (final message in ws.timeout(const Duration(seconds: 10))) {
          final data = jsonDecode(message as String) as Map<String, dynamic>;
          if (data['id'] == 1) {
            final result = data['result'] as Map<String, dynamic>?;
            if (result == null || result['data'] == null) {
              throw Exception(
                'CDP screenshot failed: ${data['error'] ?? 'no result'}',
              );
            }
            return base64Decode(result['data'] as String);
          }
        }

        throw Exception('WebSocket closed without response');
      } finally {
        await ws.close();
      }
    } finally {
      httpClient.close();
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

    final rawBytes = Uint8List.fromList(bytes);
    _validatePng(rawBytes);
    return _resizeImage(rawBytes);
  }

  /// Throws if the captured bytes don't start with a valid PNG header.
  /// Any text that `screencap` printed to stdout before the image data
  /// is included in the exception message so users can diagnose the issue.
  static void _validatePng(Uint8List bytes) {
    const pngSignature = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];

    if (bytes.length >= pngSignature.length &&
        pngSignature.indexed.every((e) => bytes[e.$1] == e.$2)) {
      return;
    }

    final prefixBytes = bytes.length > 512 ? bytes.sublist(0, 512) : bytes;
    final prefix = String.fromCharCodes(
      prefixBytes.where((b) => b >= 0x20 && b < 0x7F),
    );

    throw Exception(
      'screencap returned invalid image data.\n'
      'Output prefix: $prefix',
    );
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
