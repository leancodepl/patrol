import 'dart:async';
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

  group('stopFlutterProcess', () {
    late WebTestBackend backend;

    setUp(() {
      backend = WebTestBackend(
        processManager: MockProcessManager(),
        parentDisposeScope: DisposeScope(),
        logger: MockLogger(),
      );
    });

    test('asks Flutter to quit instead of signalling it', () async {
      final process = _FakeFlutterProcess(quitsOnQ: true);

      await backend.stopFlutterProcess(process);

      expect(process.stdinText, 'q');
      expect(process.signals, isEmpty);
    });

    test('terminates Flutter when it does not quit in time', () async {
      final process = _FakeFlutterProcess(exitsOn: ProcessSignal.sigterm);

      await backend.stopFlutterProcess(
        process,
        timeout: const Duration(milliseconds: 10),
      );

      expect(process.signals, [ProcessSignal.sigterm]);
    });

    test('kills Flutter when it ignores the termination signal', () async {
      final process = _FakeFlutterProcess(exitsOn: ProcessSignal.sigkill);

      await backend.stopFlutterProcess(
        process,
        timeout: const Duration(milliseconds: 10),
      );

      expect(process.signals, [ProcessSignal.sigterm, ProcessSignal.sigkill]);
    });

    test('tolerates a broken pipe when Flutter has already exited', () async {
      final process = _FakeFlutterProcess(
        exitsOn: ProcessSignal.sigterm,
        stdin: IOSink(_BrokenPipe()),
      );

      await backend.stopFlutterProcess(
        process,
        timeout: const Duration(milliseconds: 10),
      );

      expect(process.signals, [ProcessSignal.sigterm]);
    });

    test('signals Flutter when its stdin is already closed', () async {
      final process = _FakeFlutterProcess(
        exitsOn: ProcessSignal.sigterm,
        stdinClosed: true,
      );

      await backend.stopFlutterProcess(
        process,
        timeout: const Duration(milliseconds: 10),
      );

      expect(process.signals, [ProcessSignal.sigterm]);
    });
  });
}

/// A `flutter run` process that exits when it reads `q` from stdin or when it
/// receives [exitsOn].
class _FakeFlutterProcess implements Process {
  _FakeFlutterProcess({
    bool quitsOnQ = false,
    this.exitsOn,
    bool stdinClosed = false,
    IOSink? stdin,
  }) : _brokenStdin = stdin {
    _stdinController.stream.listen((bytes) {
      stdinText += String.fromCharCodes(bytes);
      if (quitsOnQ && stdinText.contains('q')) {
        _exit(0);
      }
    });
    if (stdinClosed) {
      _stdinController.close();
    }
  }

  final ProcessSignal? exitsOn;
  final signals = <ProcessSignal>[];
  String stdinText = '';
  final _exitCode = Completer<int>();
  final _stdinController = StreamController<List<int>>();
  late final _stdin = IOSink(_stdinController.sink);
  final IOSink? _brokenStdin;

  void _exit(int code) {
    if (!_exitCode.isCompleted) {
      _exitCode.complete(code);
    }
  }

  @override
  IOSink get stdin => _brokenStdin ?? _stdin;

  @override
  Future<int> get exitCode => _exitCode.future;

  @override
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) {
    signals.add(signal);
    if (signal == exitsOn) {
      _exit(-signal.signalNumber);
    }
    return true;
  }

  @override
  int get pid => 42;

  @override
  Stream<List<int>> get stdout => const Stream.empty();

  @override
  Stream<List<int>> get stderr => const Stream.empty();
}

/// A pipe whose reader has gone away, like the stdin of an exited process.
class _BrokenPipe implements StreamConsumer<List<int>> {
  @override
  Future<void> addStream(Stream<List<int>> stream) =>
      Future.error(const SocketException('Broken pipe'));

  @override
  Future<void> close() => Future.value();
}
