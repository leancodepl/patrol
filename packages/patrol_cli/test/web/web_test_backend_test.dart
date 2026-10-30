import 'dart:async';
import 'dart:io';

import 'package:dispose_scope/dispose_scope.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:patrol_cli/src/web/web_test_backend.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';
import '../src/self_signed_certificate.dart';

const _webDevice = Device(
  name: 'Chrome',
  id: 'chrome',
  targetPlatform: TargetPlatform.web,
  real: false,
);

const _options = WebAppOptions(
  flutter: FlutterAppOptions(
    command: FlutterCommand('flutter'),
    target: 'patrol_test/app_test.dart',
    buildMode: BuildMode.debug,
    flavor: null,
    buildName: null,
    buildNumber: null,
    dartDefines: {},
    dartDefineFromFilePaths: [],
  ),
);

void main() {
  setUpAll(() => registerFallbackValue(ProcessSignal.sigterm));

  group('WebTestBackend.execute', () {
    late DisposeScope parentDisposeScope;
    late MockProcessManager processManager;
    late MockProcess flutterProcess;
    late Completer<int> flutterExitCode;
    late WebTestBackend webTestBackend;

    setUp(() {
      parentDisposeScope = DisposeScope();
      processManager = MockProcessManager();
      flutterProcess = MockProcess();
      flutterExitCode = Completer<int>();
      final logger = MockLogger();
      when(() => logger.info(any())).thenReturn(null);
      when(() => logger.detail(any())).thenReturn(null);

      when(
        () => processManager.start(any()),
      ).thenAnswer((_) async => flutterProcess);
      when(() => flutterProcess.stdout).thenAnswer((_) => const Stream.empty());
      when(() => flutterProcess.stderr).thenAnswer((_) => const Stream.empty());
      when(
        () => flutterProcess.exitCode,
      ).thenAnswer((_) => flutterExitCode.future);
      when(() => flutterProcess.kill(any())).thenAnswer((invocation) {
        final signal = invocation.positionalArguments.first as ProcessSignal;
        if (!flutterExitCode.isCompleted) {
          flutterExitCode.complete(-signal.signalNumber);
        }
        return true;
      });

      webTestBackend = WebTestBackend(
        processManager: processManager,
        parentDisposeScope: parentDisposeScope,
        logger: logger,
      );
    });

    test(
      'stops the Flutter web server when interrupted while it builds',
      () async {
        final execution = webTestBackend.execute(_options, _webDevice);
        await untilCalled(() => processManager.start(any()));

        await parentDisposeScope.dispose();

        await expectLater(execution, throwsA(isA<ToolInterrupted>()));
        verify(() => flutterProcess.kill(any())).called(greaterThan(0));
        verify(() => processManager.start(any())).called(1);
      },
    );

    test('does not start the Flutter web server when interrupted before '
        'execution', () async {
      await parentDisposeScope.dispose();

      await expectLater(
        webTestBackend.execute(_options, _webDevice),
        throwsA(isA<ToolInterrupted>()),
      );
      verifyNever(() => processManager.start(any()));
    });

    test('fails when Flutter exits with code 0 before serving', () async {
      final execution = webTestBackend.execute(_options, _webDevice);
      await untilCalled(() => processManager.start(any()));

      flutterExitCode.complete(0);

      await expectLater(
        execution,
        throwsA(contains('Flutter process exited unexpectedly with code 0')),
      );
    });
  });

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
}
