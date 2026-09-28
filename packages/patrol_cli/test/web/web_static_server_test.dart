import 'dart:convert';
import 'dart:io' as io;

import 'package:file/memory.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/web/web_static_server.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';

void main() {
  late MemoryFileSystem fs;
  late MockLogger logger;
  late WebStaticServer server;

  Future<WebStaticServer> serveApp({bool wasm = false}) {
    final root = fs.directory('app');
    if (root.existsSync()) {
      root.deleteSync(recursive: true);
    }
    root.createSync(recursive: true);
    root.childFile('index.html').writeAsStringSync('<html>app</html>');
    root.childFile('main.dart.js').writeAsStringSync('console.log(1)');
    root.childDirectory('assets').createSync();
    root.childFile('assets/FontManifest.json').writeAsStringSync('[]');
    if (wasm) {
      root.childFile('main.dart.wasm').writeAsBytesSync([0, 97, 115, 109]);
    }

    return WebStaticServer.serve(root, logger: logger);
  }

  Future<io.HttpClientResponse> get(String path) async {
    final client = io.HttpClient();
    final request = await client.getUrl(Uri.parse('${server.baseUrl}$path'));
    final response = await request.close();
    client.close();
    return response;
  }

  setUp(() {
    fs = MemoryFileSystem();
    logger = MockLogger();
    when(() => logger.detail(any())).thenReturn(null);
  });

  tearDown(() => server.close());

  test('serves the app entrypoint', () async {
    server = await serveApp();

    final response = await get('/');

    expect(response.statusCode, equals(200));
    expect(response.headers.value('content-type'), equals('text/html'));
    expect(await response.transform(utf8.decoder).join(), contains('app'));
  });

  test('sends the content type browsers require for js and wasm', () async {
    server = await serveApp(wasm: true);

    expect(
      (await get('/main.dart.js')).headers.value('content-type'),
      equals('text/javascript'),
    );
    expect(
      (await get('/main.dart.wasm')).headers.value('content-type'),
      equals('application/wasm'),
    );
  });

  test('isolates the page cross-origin only for a wasm build', () async {
    server = await serveApp(wasm: true);
    final isolated = await get('/index.html');

    expect(
      isolated.headers.value('cross-origin-opener-policy'),
      equals('same-origin'),
    );
    expect(
      isolated.headers.value('cross-origin-embedder-policy'),
      equals('credentialless'),
    );

    await server.close();
    server = await serveApp();

    expect(
      (await get('/index.html')).headers.value('cross-origin-opener-policy'),
      isNull,
    );
  });

  test('serves concurrent requests, as a sharded run makes them', () async {
    server = await serveApp();

    final responses = await Future.wait([
      for (var i = 0; i < 8; i++) get('/main.dart.js'),
    ]);

    expect(responses.map((r) => r.statusCode), everyElement(equals(200)));
  });

  test('refuses to serve anything outside the app directory', () async {
    fs.file('secret.txt').writeAsStringSync('nope');
    server = await serveApp();

    final response = await get('/%2e%2e/secret.txt');

    // Unknown paths fall back to index.html, the way `flutter run` serves them.
    expect(await response.transform(utf8.decoder).join(), contains('app'));
  });
}
