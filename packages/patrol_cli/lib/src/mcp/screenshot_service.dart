import 'dart:convert';
import 'dart:io' show HttpClient, WebSocket;
import 'dart:typed_data';

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:image/image.dart' as img;
import 'package:mcp_dart/mcp_dart.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:process/process.dart';

enum ScreenshotPlatform {
  android('adb'),
  ios('xcrun');

  const ScreenshotPlatform(this.command);

  final String command;

  /// Builds the command arguments that target [device] specifically, so
  /// the capture doesn't fail (or silently hit the wrong device) when
  /// multiple devices/simulators are attached.
  ///
  /// `screencap` writes the PNG to stdout. `simctl io screenshot` writes
  /// atomically -- a temp file in the destination directory, then a rename --
  /// so [outputPath] must be a real, writable path there.
  List<String> argsFor(Device device, {String? outputPath}) => switch (this) {
    ScreenshotPlatform.android => [
      '-s',
      device.id,
      'exec-out',
      'screencap',
      '-p',
    ],
    ScreenshotPlatform.ios => [
      'simctl',
      'io',
      device.id,
      'screenshot',
      '--type=png',
      outputPath ?? (throw ArgumentError('iOS capture needs an output path')),
    ],
  };

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

/// Captures the page a Chrome instance shows, as PNG bytes, through its
/// remote debugging port.
typedef WebPageCapture = Future<Uint8List> Function(String debuggerPort);

abstract final class ScreenshotService {
  static const _maxHeight = 800;

  static Future<CallToolResult> handleScreenshotRequest(
    Device? device, {
    String? webDebuggerPort,
    WebPageCapture captureWebPage = captureChromePage,
    ProcessManager processManager = const LocalProcessManager(),
    FileSystem fileSystem = const LocalFileSystem(),
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
        if (webDebuggerPort == null) {
          return const CallToolResult(
            content: [
              TextContent(
                text:
                    'The web session has no Chrome debugger port yet. '
                    'Wait for the run to start the browser and try again.',
              ),
            ],
            isError: true,
          );
        }
        final page = await captureWebPage(webDebuggerPort);
        _validatePng(page);
        return CallToolResult(
          content: [
            ImageContent(
              data: base64Encode(_resizeImage(page)),
              mimeType: 'image/png',
            ),
          ],
        );
      }

      final platform = ScreenshotPlatform.fromDevice(device);
      final bytes = await _captureScreenshot(
        platform,
        device,
        processManager,
        fileSystem,
      );
      final base64Data = base64Encode(bytes);

      return CallToolResult(
        content: [ImageContent(data: base64Data, mimeType: 'image/png')],
      );
    } catch (err) {
      // Catches both Exception and Error (e.g. ArgumentError from
      // unsupported platform).
      return CallToolResult(
        content: [TextContent(text: 'Failed to capture screenshot: $err')],
        isError: true,
      );
    }
  }

  static Future<Uint8List> _captureScreenshot(
    ScreenshotPlatform platform,
    Device device,
    ProcessManager processManager,
    FileSystem fileSystem,
  ) async {
    final rawBytes = switch (platform) {
      ScreenshotPlatform.android => await _captureFromStdout(
        device,
        processManager,
      ),
      ScreenshotPlatform.ios => await _captureViaTempFile(
        device,
        processManager,
        fileSystem,
      ),
    };

    _validatePng(rawBytes);
    return _resizeImage(rawBytes);
  }

  static Future<Uint8List> _captureFromStdout(
    Device device,
    ProcessManager processManager,
  ) async {
    final process = await processManager.start([
      ScreenshotPlatform.android.command,
      ...ScreenshotPlatform.android.argsFor(device),
    ]);

    final bytes = await process.stdout.expand((chunk) => chunk).toList();

    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      final stderr = await process.stderr.transform(utf8.decoder).join();
      throw Exception('Failed to capture screenshot: $stderr');
    }

    return Uint8List.fromList(bytes);
  }

  static Future<Uint8List> _captureViaTempFile(
    Device device,
    ProcessManager processManager,
    FileSystem fileSystem,
  ) async {
    final tempFile = fileSystem.file(
      fileSystem.path.join(
        fileSystem.systemTempDirectory.path,
        'patrol_mcp_screenshot_${DateTime.now().microsecondsSinceEpoch}.png',
      ),
    );

    try {
      final process = await processManager.start([
        ScreenshotPlatform.ios.command,
        ...ScreenshotPlatform.ios.argsFor(device, outputPath: tempFile.path),
      ]);

      final stderr = process.stderr.transform(utf8.decoder).join();
      final exitCode = await process.exitCode;
      if (exitCode != 0) {
        throw Exception('Failed to capture screenshot: ${await stderr}');
      }

      return await tempFile.readAsBytes();
    } finally {
      if (tempFile.existsSync()) {
        await tempFile.delete();
      }
    }
  }

  /// Throws if the captured bytes don't start with a valid PNG header.
  /// Any text the capture command printed in place of image data is included
  /// in the exception message so users can diagnose the issue.
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
      'Screenshot capture returned invalid image data.\n'
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

/// Captures the first page Chrome lists on [debuggerPort] with the DevTools
/// Protocol's `Page.captureScreenshot`. Every step is bounded: a browser that
/// stopped answering fails the call.
Future<Uint8List> captureChromePage(String debuggerPort) async {
  const step = Duration(seconds: 5);
  final httpClient = HttpClient();
  try {
    final request = await httpClient
        .getUrl(Uri.parse('http://127.0.0.1:$debuggerPort/json'))
        .timeout(step);
    final response = await request.close().timeout(step);
    final body = await response.transform(utf8.decoder).join().timeout(step);
    final page = (jsonDecode(body) as List)
        .whereType<Map<String, dynamic>>()
        .firstWhere(
          (target) => target['type'] == 'page',
          orElse: () => throw Exception('Chrome lists no page to capture'),
        );
    final socketUrl = page['webSocketDebuggerUrl'] as String?;
    if (socketUrl == null) {
      throw Exception('Chrome gives no debugger URL for the page');
    }

    final socket = await WebSocket.connect(socketUrl).timeout(step);
    try {
      socket.add(jsonEncode({'id': 1, 'method': 'Page.captureScreenshot'}));
      await for (final message in socket.timeout(step * 2)) {
        final reply = jsonDecode(message as String) as Map<String, dynamic>;
        if (reply['id'] != 1) {
          continue;
        }
        final data = (reply['result'] as Map<String, dynamic>?)?['data'];
        if (data is! String) {
          throw Exception(
            'Page.captureScreenshot failed: ${reply['error'] ?? 'no data'}',
          );
        }
        return base64Decode(data);
      }
      throw Exception('Chrome closed the connection before answering');
    } finally {
      await socket.close();
    }
  } finally {
    httpClient.close(force: true);
  }
}
