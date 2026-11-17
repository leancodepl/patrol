import 'dart:io';

import 'package:dispose_scope/dispose_scope.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:patrol_cli/src/web/web_test_backend.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';
import '../src/self_signed_certificate.dart';

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

  group('remoteBrowserEndpoint', () {
    const flutterOpts = FlutterAppOptions(
      command: FlutterCommand('flutter'),
      target: 'patrol_test/example_test.dart',
      buildMode: BuildMode.debug,
      flavor: null,
      buildName: null,
      buildNumber: null,
      dartDefines: {},
      dartDefineFromFilePaths: [],
    );

    test('is null when no endpoint is configured', () {
      expect(
        WebTestBackend.remoteBrowserEndpoint(
          const WebAppOptions(flutter: flutterOpts),
          {},
        ),
        isNull,
      );
    });

    test('reads the --web-connect-ws-endpoint option', () {
      expect(
        WebTestBackend.remoteBrowserEndpoint(
          const WebAppOptions(
            flutter: flutterOpts,
            connectWsEndpoint: 'ws://127.0.0.1:3000/',
          ),
          {},
        ),
        'ws://127.0.0.1:3000/',
      );
    });

    test('reads PATROL_WEB_CONNECT_WS_ENDPOINT from the environment', () {
      expect(
        WebTestBackend.remoteBrowserEndpoint(
          const WebAppOptions(flutter: flutterOpts),
          {'PATROL_WEB_CONNECT_WS_ENDPOINT': 'ws://grid:3000/'},
        ),
        'ws://grid:3000/',
      );
    });

    test('prefers the option over the environment', () {
      expect(
        WebTestBackend.remoteBrowserEndpoint(
          const WebAppOptions(
            flutter: flutterOpts,
            connectWsEndpoint: 'ws://127.0.0.1:3000/',
          ),
          {'PATROL_WEB_CONNECT_WS_ENDPOINT': 'ws://grid:3000/'},
        ),
        'ws://127.0.0.1:3000/',
      );
    });

    test('treats an empty value as not configured', () {
      expect(
        WebTestBackend.remoteBrowserEndpoint(
          const WebAppOptions(flutter: flutterOpts),
          {'PATROL_WEB_CONNECT_WS_ENDPOINT': ''},
        ),
        isNull,
      );
    });
  });

  group('describeEndpoint', () {
    test('keeps the scheme, host and port', () {
      expect(
        WebTestBackend.describeEndpoint('ws://127.0.0.1:3000/'),
        'ws://127.0.0.1:3000',
      );
    });

    test('drops user info, path and query, which may hold credentials', () {
      expect(
        WebTestBackend.describeEndpoint(
          'wss://user:secret@grid.example.com/playwright?caps=%7B%22key%22%3A%22secret%22%7D',
        ),
        'wss://grid.example.com',
      );
    });

    test('does not echo a value it cannot parse', () {
      expect(
        WebTestBackend.describeEndpoint('not a url with secret'),
        'the configured endpoint',
      );
    });
  });

  group('verifyServerReady', () {
    late MockLogger logger;
    late WebTestBackend backend;

    /// Starts a server on 127.0.0.1 that responds with 200, or redirects
    /// requests for `/` to the URI that [redirect] returns for them. With
    /// [secure], it serves https with a self-signed certificate.
    Future<HttpServer> startServer({
      bool secure = false,
      Uri Function(Uri requestedUri)? redirect,
    }) async {
      final server = secure
          ? await HttpServer.bindSecure(
              InternetAddress.loopbackIPv4,
              0,
              selfSignedSecurityContext(),
            )
          : await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      server.listen((request) {
        if (redirect != null && request.uri.path == '/') {
          request.response.redirect(redirect(request.requestedUri));
        } else {
          request.response.close();
        }
      });
      return server;
    }

    setUp(() {
      logger = MockLogger();
      backend = WebTestBackend(
        processManager: MockProcessManager(),
        parentDisposeScope: DisposeScope(),
        logger: logger,
      );
    });

    /// Fails unless the check failed on the TLS handshake, so that any other
    /// error (e.g. `localhost` not reaching the server) can't pass for it.
    void expectCertificateRejected() => verify(
      () => logger.detail(any(that: contains('HandshakeException'))),
    ).called(1);

    test('returns true for a responding http server', () async {
      final server = await startServer();

      expect(
        await backend.verifyServerReady('http://127.0.0.1:${server.port}'),
        isTrue,
      );
    });

    test(
      'accepts the self-signed certificate of the https server it checks',
      () async {
        final server = await startServer(secure: true);

        expect(
          await backend.verifyServerReady('https://127.0.0.1:${server.port}'),
          isTrue,
        );
      },
    );

    test('follows a redirect to the same host and port', () async {
      final server = await startServer(
        secure: true,
        redirect: (uri) => uri.replace(path: '/redirected'),
      );

      expect(
        await backend.verifyServerReady('https://127.0.0.1:${server.port}'),
        isTrue,
      );
    });

    test(
      'rejects a self-signed certificate after a redirect to another host',
      () async {
        // The same server, reached as localhost instead of 127.0.0.1.
        final server = await startServer(
          secure: true,
          redirect: (uri) =>
              uri.replace(host: 'localhost', path: '/redirected'),
        );

        expect(
          await backend.verifyServerReady('https://127.0.0.1:${server.port}'),
          isFalse,
        );
        expectCertificateRejected();
      },
    );

    test(
      'rejects a self-signed certificate after a redirect to another port',
      () async {
        final otherServer = await startServer(secure: true);
        final server = await startServer(
          secure: true,
          redirect: (uri) => uri.replace(port: otherServer.port),
        );

        expect(
          await backend.verifyServerReady('https://127.0.0.1:${server.port}'),
          isFalse,
        );
        expectCertificateRejected();
      },
    );
  });
}
