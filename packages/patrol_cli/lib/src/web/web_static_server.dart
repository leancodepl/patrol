import 'dart:async';
import 'dart:io'
    show HttpHeaders, HttpRequest, HttpServer, HttpStatus, InternetAddress;

import 'package:file/file.dart';
import 'package:patrol_cli/src/base/logger.dart';

/// Headers that make the page cross-origin isolated, which a wasm build needs
/// for multi-threading. Same values `flutter run` serves.
const _crossOriginIsolationHeaders = {
  'Cross-Origin-Opener-Policy': 'same-origin',
  'Cross-Origin-Embedder-Policy': 'credentialless',
};

const _mimeTypes = {
  '.html': 'text/html',
  '.htm': 'text/html',
  '.js': 'text/javascript',
  '.mjs': 'text/javascript',
  '.wasm': 'application/wasm',
  '.json': 'application/json',
  '.map': 'application/json',
  '.css': 'text/css',
  '.txt': 'text/plain',
  '.symbols': 'text/plain',
  '.xml': 'application/xml',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.gif': 'image/gif',
  '.webp': 'image/webp',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.bmp': 'image/bmp',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.eot': 'application/vnd.ms-fontobject',
  '.mp3': 'audio/mpeg',
  '.wav': 'audio/wav',
  '.mp4': 'video/mp4',
  '.webm': 'video/webm',
  '.pdf': 'application/pdf',
};

/// Serves a directory produced by `flutter build web`.
///
/// It exists so that running a prebuilt artifact needs nothing but this CLI:
/// `flutter run` is what normally serves the app, and it isn't installed on the
/// machines this is meant for.
class WebStaticServer {
  WebStaticServer._(
    this._server,
    this._root, {
    required bool crossOriginIsolated,
  }) : _crossOriginIsolated = crossOriginIsolated;

  /// Starts serving [root] on [port], or on a free port when it is null.
  static Future<WebStaticServer> serve(
    Directory root, {
    int? port,
    required Logger logger,
  }) async {
    final httpServer = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      port ?? 0,
    );

    final server = WebStaticServer._(
      httpServer,
      root,
      // Mirrors `flutter run`, which only isolates when the build is wasm.
      crossOriginIsolated: root.childFile('main.dart.wasm').existsSync(),
    );

    // Requests are dispatched without awaiting each other, so the workers of a
    // sharded run all load the app at once.
    httpServer.listen(
      (request) => unawaited(server._handle(request)),
      onError: (Object err) => logger.detail('Web server error: $err'),
    );

    logger.detail('Serving ${root.path} at ${server.baseUrl}');
    return server;
  }

  final HttpServer _server;
  final Directory _root;
  final bool _crossOriginIsolated;

  String get baseUrl => 'http://127.0.0.1:${_server.port}';

  Future<void> close() => _server.close(force: true);

  Future<void> _handle(HttpRequest request) async {
    final response = request.response;

    if (request.method != 'GET' && request.method != 'HEAD') {
      response.statusCode = HttpStatus.methodNotAllowed;
      await response.close();
      return;
    }

    try {
      final file = _resolve(request.uri.path) ?? _root.childFile('index.html');
      if (!file.existsSync()) {
        response.statusCode = HttpStatus.notFound;
        await response.close();
        return;
      }

      final extension = _root.fileSystem.path.extension(file.path);
      response.headers
        ..set(
          HttpHeaders.contentTypeHeader,
          _mimeTypes[extension] ?? 'application/octet-stream',
        )
        ..set('Cross-Origin-Resource-Policy', 'cross-origin')
        ..set('Access-Control-Allow-Origin', '*');

      if (_crossOriginIsolated && (extension == '.html' || extension.isEmpty)) {
        _crossOriginIsolationHeaders.forEach(response.headers.set);
      }

      if (request.method == 'HEAD') {
        response.headers.contentLength = file.lengthSync();
        await response.close();
        return;
      }

      await response.addStream(file.openRead());
      await response.close();
    } on Object catch (_) {
      // A browser aborting a request mid-flight lands here; it must not take
      // the server, and with it the rest of the run, down.
      try {
        await response.close();
      } on Object catch (_) {}
    }
  }

  /// The file [requestPath] points at, or null when it escapes the root or
  /// isn't there.
  File? _resolve(String requestPath) {
    final path = _root.fileSystem.path;
    final relative = requestPath.startsWith('/')
        ? requestPath.substring(1)
        : requestPath;

    if (relative.isEmpty) {
      return _root.childFile('index.html');
    }

    final candidate = _root.fileSystem.file(
      path.normalize(path.join(_root.path, Uri.decodeComponent(relative))),
    );

    final rootPath = path.normalize(_root.absolute.path);
    if (!path.isWithin(rootPath, path.normalize(candidate.absolute.path))) {
      return null;
    }

    return candidate.existsSync() ? candidate : null;
  }
}
