import 'dart:convert';

import 'package:mcp_dart/mcp_dart.dart';
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';

/// Fetches the Flutter widget tree of the app under test through the
/// `ext.flutter.patrol.getFlutterTree` service extension (patrol 4.11.0+).
///
/// Unlike the native tree it lists widget keys, types and form state (typed
/// text, checkbox and switch values), which is what Patrol finders and
/// assertions target. A test that passed has already replaced the app with
/// flutter_test's "Test finished." screen; after a failed test the tree is
/// left as it was when the test failed.
abstract final class FlutterTreeService {
  static const _extension = 'ext.flutter.patrol.getFlutterTree';

  static Future<CallToolResult> handleGetFlutterTreeRequest(
    String? vmServiceUrl,
  ) async {
    if (vmServiceUrl == null) {
      return const CallToolResult(
        content: [
          TextContent(
            text:
                'No app attached yet. Run a test first; the tree is available '
                'once the develop session has attached for hot restart.',
          ),
        ],
        isError: true,
      );
    }

    VmService? service;
    try {
      service = await vmServiceConnectUri(wsUri(vmServiceUrl));
      final vm = await service.getVM();
      for (final ref in vm.isolates ?? const <IsolateRef>[]) {
        final isolate = await service.getIsolate(ref.id!);
        if (!(isolate.extensionRPCs ?? const []).contains(_extension)) {
          continue;
        }
        final response = await service.callServiceExtension(
          _extension,
          isolateId: ref.id,
        );
        final json = response.json ?? const {};
        if (json['error'] != null) {
          return CallToolResult(
            content: [
              TextContent(text: 'Failed to read the tree: ${json['error']}'),
            ],
            isError: true,
          );
        }
        final elements = jsonDecode(json['result'] as String) as List<Object?>;
        final payload = {'elements': elements};
        return CallToolResult(
          content: [TextContent(text: jsonEncode(payload))],
          structuredContent: payload,
        );
      }
      return const CallToolResult(
        content: [
          TextContent(
            text:
                'The app does not expose $_extension. '
                'It needs patrol 4.11.0 or newer.',
          ),
        ],
        isError: true,
      );
    } on Exception catch (e) {
      return CallToolResult(
        content: [TextContent(text: 'Failed to fetch the Flutter tree: $e')],
        isError: true,
      );
    } finally {
      await service?.dispose();
    }
  }

  /// The WebSocket URI of a VM service URL, e.g.
  /// `http://127.0.0.1:61070/abc=/` -> `ws://127.0.0.1:61070/abc=/ws`. A
  /// `ws://` URI is returned as is.
  static String wsUri(String url) {
    final uri = Uri.parse(url);
    if (uri.scheme == 'ws' || uri.scheme == 'wss') {
      return url;
    }
    final segments = [...uri.pathSegments.where((s) => s.isNotEmpty), 'ws'];
    return uri
        .replace(
          scheme: uri.scheme == 'https' ? 'wss' : 'ws',
          pathSegments: segments,
        )
        .toString();
  }
}
