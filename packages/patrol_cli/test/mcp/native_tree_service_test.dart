import 'dart:convert';
import 'dart:io';

import 'package:mcp_dart/mcp_dart.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/mcp/native_tree_service.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';

void main() {
  const android = Device(
    name: 'emulator',
    id: 'emulator-5554',
    targetPlatform: TargetPlatform.android,
    real: false,
  );

  String text(CallToolResult result) =>
      (result.content.single as TextContent).text;

  group('trimTree', () {
    test('keeps only the fields a selector can use', () {
      final trimmed = NativeTreeService.trimTree({
        'roots': [
          {
            'elementType': 'button',
            'text': 'Log in',
            'resourceName': 'login',
            'bounds': {'x': 0},
            'enabled': true,
            'contentDescription': '',
            'label': null,
          },
        ],
      });

      expect(trimmed, {
        'roots': [
          {'elementType': 'button', 'text': 'Log in', 'resourceName': 'login'},
        ],
      });
    });

    test('hoists wrapper nodes with no identity and drops empty ones', () {
      final trimmed = NativeTreeService.trimTree({
        'roots': [
          {
            'elementType': 'other',
            'children': [
              {
                'elementType': 'other',
                'children': [
                  {'elementType': 'text', 'text': 'Hello'},
                ],
              },
              {'elementType': 'other'},
            ],
          },
          {'elementType': 'other', 'label': 'Toolbar', 'children': <Object>[]},
        ],
      });

      expect(trimmed, {
        'roots': [
          {'elementType': 'text', 'text': 'Hello'},
          {'elementType': 'other', 'label': 'Toolbar'},
        ],
      });
    });
  });

  group('handleGetNativeTreeRequest', () {
    test('refuses without a device', () async {
      final result = await NativeTreeService.handleGetNativeTreeRequest(
        null,
        null,
        processManager: MockProcessManager(),
      );

      expect(result.isError, isTrue);
      expect(text(result), contains('No active patrol session'));
    });

    /// Serves [body] with [status] on a free port, standing in for the app's
    /// native automator.
    Future<HttpServer> automator(String body, {int status = 200}) async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((request) async {
        request.response
          ..statusCode = status
          ..write(body);
        await request.response.close();
      });
      addTearDown(server.close);
      return server;
    }

    test('says the automator is not ready while the tree is empty', () async {
      final server = await automator(jsonEncode({'roots': <Object>[]}));

      final result = await NativeTreeService.handleGetNativeTreeRequest(
        android,
        server.port,
        processManager: MockProcessManager(),
      );

      expect(result.isError, isNot(true));
      expect(text(result), contains('not ready yet'));
    });

    test('hands back the trimmed tree', () async {
      final server = await automator(
        jsonEncode({
          'roots': [
            {'elementType': 'button', 'text': 'Log in', 'enabled': true},
          ],
        }),
      );

      final result = await NativeTreeService.handleGetNativeTreeRequest(
        android,
        server.port,
        processManager: MockProcessManager(),
      );

      expect(result.structuredContent, {
        'roots': [
          {'elementType': 'button', 'text': 'Log in'},
        ],
      });
    });

    test('reports a body that is not an object as the tool error', () async {
      final server = await automator('[1, 2, 3]');

      final result = await NativeTreeService.handleGetNativeTreeRequest(
        android,
        server.port,
        processManager: MockProcessManager(),
      );

      expect(result.isError, isTrue);
      expect(text(result), contains('Failed to fetch native tree'));
    });

    test('reports a failing automator as the tool error', () async {
      final server = await automator('boom', status: 500);

      final result = await NativeTreeService.handleGetNativeTreeRequest(
        android,
        server.port,
        processManager: MockProcessManager(),
      );

      expect(result.isError, isTrue);
      expect(text(result), contains('HTTP 500'));
    });
  });
}
