import 'dart:io';

import 'package:dispose_scope/dispose_scope.dart';
import 'package:patrol_cli/src/web/web_test_backend.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';

void main() {
  group('extractWebServerUrl', () {
    test('returns the http URL of the web server', () {
      const line = 'lib/main.dart is being served at http://localhost:62133';
      expect(
        WebTestBackend.extractWebServerUrl(line),
        'http://localhost:62133',
      );
    });

    test('returns the https URL when the web server serves TLS', () {
      const line =
          '/project/test_bundle.dart is being served at https://localhost:8443';
      expect(
        WebTestBackend.extractWebServerUrl(line),
        'https://localhost:8443',
      );
    });

    test('returns null for a line without a URL', () {
      const line = 'Launching test_bundle.dart on Web Server in debug mode...';
      expect(WebTestBackend.extractWebServerUrl(line), isNull);
    });

    test('returns null for the DevTools websocket URL', () {
      const line =
          '[CHROME]: DevTools listening on '
          'ws://127.0.0.1:38861/devtools/browser/431953d3-ef67-428f-9321';
      expect(WebTestBackend.extractWebServerUrl(line), isNull);
    });
  });

  group('verifyServerReady', () {
    late HttpServer server;
    late WebTestBackend backend;

    setUp(() {
      backend = WebTestBackend(
        processManager: MockProcessManager(),
        parentDisposeScope: DisposeScope(),
        logger: MockLogger(),
      );
    });

    tearDown(() => server.close(force: true));

    test('returns true for a responding http server', () async {
      server = (await HttpServer.bind(InternetAddress.loopbackIPv4, 0))
        ..listen((request) => request.response.close());

      expect(
        await backend.verifyServerReady('http://127.0.0.1:${server.port}'),
        isTrue,
      );
    });
  });
}
