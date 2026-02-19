import 'dart:convert';
import 'dart:io';

import 'package:adb/adb.dart';
import 'package:mcp_dart/mcp_dart.dart';
import 'package:patrol_cli/develop.dart' show Device, TargetPlatform;

abstract final class NativeTreeService {
  static const _host = 'localhost';
  static final _port = Platform.environment['PATROL_TEST_PORT'] ?? '8081';

  static Future<CallToolResult> handleGetNativeTreeRequest(
    Device? device,
  ) async {
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

      await _setupConnection(device);

      final tree = await _fetchNativeTree();

      if (_isTreeEmpty(tree)) {
        return const CallToolResult(
          content: [
            TextContent(
              text:
                  'Native automator not ready yet. '
                  'Please wait a moment and try again.',
            ),
          ],
        );
      }

      final trimmed = _trimTree(tree);

      return CallToolResult(
        content: [
          TextContent(
            text: const JsonEncoder.withIndent('  ').convert(trimmed),
          ),
        ],
      );
    } on Exception catch (e) {
      return CallToolResult(
        content: [TextContent(text: 'Failed to fetch native tree: $e')],
        isError: true,
      );
    }
  }

  static Future<List<String>> _getIosInstalledApps() async {
    try {
      final listApps = await Process.run('xcrun', [
        'simctl',
        'listapps',
        'booted',
      ], runInShell: true);

      if (listApps.exitCode != 0) {
        return [];
      }

      return const LineSplitter()
          .convert(listApps.stdout as String)
          .where((line) => line.contains('CFBundleIdentifier ='))
          .map(
            (line) =>
                line.substring(line.indexOf('"') + 1, line.lastIndexOf('"')),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  static bool _isTreeEmpty(Map<String, dynamic> tree) {
    final roots = tree['roots'] as List<dynamic>?;
    return roots == null || roots.isEmpty;
  }

  static Map<String, dynamic> _trimTree(Map<String, dynamic> tree) {
    final roots = tree['roots'] as List<dynamic>?;
    if (roots == null) {
      return tree;
    }

    final trimmedRoots = roots
        .map((node) => _trimNode(node as Map<String, dynamic>))
        .toList();

    // Flatten any top-level wrappers
    return {'roots': _flattenRoots(trimmedRoots)};
  }

  static List<Map<String, dynamic>> _flattenRoots(List<dynamic> nodes) {
    final result = <Map<String, dynamic>>[];
    for (final node in nodes) {
      result.addAll(_flattenNode(node as Map<String, dynamic>));
    }
    return result;
  }

  /// Flattens "other" nodes that have no identifying info.
  static List<Map<String, dynamic>> _flattenNode(Map<String, dynamic> node) {
    final elementType = node['elementType'];
    final hasIdentity =
        node.containsKey('identifier') ||
        node.containsKey('label') ||
        node.containsKey('title') ||
        node.containsKey('value') ||
        node.containsKey('resourceName') ||
        node.containsKey('text') ||
        node.containsKey('contentDescription');

    // Only flatten "other" nodes without identity - hoist their children
    if (elementType == 'other' && !hasIdentity) {
      final children = node['children'] as List<dynamic>?;
      if (children != null && children.isNotEmpty) {
        return _flattenRoots(children);
      }
      return []; // Skip empty "other" nodes
    }

    // Keep this node, but flatten its children
    final children = node['children'] as List<dynamic>?;
    if (children != null) {
      final flatChildren = _flattenRoots(children);
      if (flatChildren.isNotEmpty) {
        node['children'] = flatChildren;
      } else {
        node.remove('children');
      }
    }

    return [node];
  }

  static const _keepFields = {
    'identifier',
    'label',
    'title',
    'value',
    'placeholderValue',
    'resourceName',
    'text',
    'contentDescription',
    'className',
    'elementType',
    'children',
  };

  static Map<String, dynamic> _trimNode(Map<String, dynamic> node) {
    final trimmed = <String, dynamic>{};

    for (final entry in node.entries) {
      final key = entry.key;
      final value = entry.value;

      // Only keep selector-relevant fields
      if (!_keepFields.contains(key)) {
        continue;
      }

      // Recursively trim children
      if (key == 'children' && value is List) {
        final children = value
            .map((child) => _trimNode(child as Map<String, dynamic>))
            .toList();
        if (children.isNotEmpty) {
          trimmed['children'] = children;
        }
        continue;
      }

      // Skip null/empty values
      if (value == null) {
        continue;
      }
      if (value is String && value.isEmpty) {
        continue;
      }

      trimmed[key] = value;
    }

    return trimmed;
  }

  static Future<Map<String, dynamic>> _fetchNativeTree() async {
    final client = HttpClient();
    try {
      final iosApps = await _getIosInstalledApps();

      final uri = Uri.http('$_host:$_port', '/getNativeViews');
      final request = await client.postUrl(uri)
        ..headers.contentType = ContentType.json
        ..write(
          jsonEncode({
            'selector': null,
            'iosInstalledApps': iosApps,
            'appId': '',
          }),
        );

      final response = await request.close();

      if (response.statusCode != HttpStatus.ok) {
        final errorBody = await response.transform(utf8.decoder).join();
        throw Exception('HTTP ${response.statusCode}: $errorBody');
      }

      final responseBody = await response.transform(utf8.decoder).join();
      return jsonDecode(responseBody) as Map<String, dynamic>;
    } finally {
      client.close();
    }
  }

  static Future<void> _setupConnection(Device device) async {
    if (device.targetPlatform != TargetPlatform.android) {
      // iOS simulator traffic goes directly to localhost.
      return;
    }

    final port = int.parse(_port);
    await Adb().forwardPorts(fromHost: port, toDevice: port);
  }
}
