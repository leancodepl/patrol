import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dispose_scope/dispose_scope.dart';
import 'package:mocktail/mocktail.dart';
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

  group('watchPlaywrightProcess', () {
    late MockLogger logger;
    late WebTestBackend backend;
    late DisposeScope scope;
    late _FakeProcess process;

    setUp(() {
      logger = MockLogger();
      backend = WebTestBackend(
        processManager: MockProcessManager(),
        parentDisposeScope: DisposeScope(),
        logger: logger,
      );
      scope = DisposeScope();
      process = _FakeProcess();
    });

    tearDown(() async {
      if (!scope.disposed) {
        await scope.dispose();
      }
    });

    Future<void> watch({
      Duration outputDrainTimeout = const Duration(minutes: 1),
    }) => backend.watchPlaywrightProcess(
      process,
      scope: scope,
      reportDir: 'playwright-report',
      showFlutterLogs: false,
      hideTestSteps: true,
      clearTestSteps: false,
      hideTestLifecycle: true,
      outputDrainTimeout: outputDrainTimeout,
    );

    List<String> errors() =>
        verify(() => logger.err(captureAny())).captured.cast<String>();

    test('completes when all tests passed', () async {
      final result = watch();
      process
        ..writeStdout('Running 1 test using 1 worker')
        ..exit(0);
      await process.closeStreams();

      await expectLater(result, completes);
      verifyNever(() => logger.err(any()));
    });

    test('shows output that arrives after the exit code', () async {
      final result = watch();
      process.exit(1);
      await pumpEventQueue();
      process
        ..writeStdout(
          'Error: browserType.launch: Unsupported chromium channel "bogus"',
        )
        ..writeStderr('Error: PATROL_WEB_VIEWPORT must be a valid JSON');
      await process.closeStreams();

      await expectLater(
        result,
        throwsA('Playwright process exited unexpectedly with code 1'),
      );
      expect(errors().single.split('\n'), [
        'Last lines of Playwright output:',
        'Error: browserType.launch: Unsupported chromium channel "bogus"',
        'Error: PATROL_WEB_VIEWPORT must be a valid JSON',
      ]);
    });

    test('stops waiting for a pipe that stays open', () async {
      final result = watch(
        outputDrainTimeout: const Duration(milliseconds: 50),
      );
      process
        ..writeStdout('Error: global setup failed')
        ..exit(1);
      // The streams stay open, e.g. a child process still holds the pipes.

      await expectLater(
        result.timeout(const Duration(seconds: 5)),
        throwsA('Playwright process exited unexpectedly with code 1'),
      );
      expect(errors().single, contains('Error: global setup failed'));
    });

    test(
      'stops waiting and prints no output when the run is interrupted',
      () async {
        final result = watch();
        process
          ..writeStdout('Running 17 tests using 1 worker')
          ..exit(-15);
        await pumpEventQueue();

        final expectation = expectLater(
          result.timeout(const Duration(seconds: 5)),
          throwsA('Playwright process exited unexpectedly with code -15'),
        );
        await scope.dispose();

        await expectation;
        verifyNever(() => logger.err(any()));
      },
    );

    test('prints no output when a test failed', () async {
      final result = watch();
      process
        ..writeStdout(
          'PATROL_LOG {"type":"test","name":"cookies","status":"start"}',
        )
        ..writeStdout(
          'PATROL_LOG {"type":"test","name":"web.cookies_test cookies",'
          '"status":"failure"}',
        )
        ..writeStdout('  1 failed')
        ..exit(1);
      await process.closeStreams();

      await expectLater(result, throwsA('Some tests failed.'));
      verifyNever(() => logger.err(any()));
    });
  });
}

/// A Playwright process whose output and exit the test controls.
class _FakeProcess extends Fake implements Process {
  final _stdout = StreamController<List<int>>();
  final _stderr = StreamController<List<int>>();
  final _exitCode = Completer<int>();

  @override
  Stream<List<int>> get stdout => _stdout.stream;

  @override
  Stream<List<int>> get stderr => _stderr.stream;

  @override
  Future<int> get exitCode => _exitCode.future;

  void writeStdout(String line) => _stdout.add(utf8.encode('$line\n'));

  void writeStderr(String line) => _stderr.add(utf8.encode('$line\n'));

  void exit(int code) => _exitCode.complete(code);

  Future<void> closeStreams() async {
    await _stdout.close();
    await _stderr.close();
  }
}
