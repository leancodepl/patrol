import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dispose_scope/dispose_scope.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:patrol_cli/src/coverage/bind_unused_port.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:process/process.dart';

/// Serves DevTools for a web develop session, with the project registered so
/// that the Patrol DevTools extension is discoverable.
///
/// DevTools finds extensions by scanning a package root, which it resolves
/// either from the app's entrypoint file path or from the Dart Tooling Daemon's
/// IDE workspace roots. A Flutter web app has no entrypoint file path -- its
/// root library is `org-dartlang-app:///...` -- so the DevTools instance served
/// by `flutter run` reports no extensions at all and the Patrol tab never shows
/// up. Editors work around this by registering workspace roots with DTD; this
/// does the same thing without an editor.
///
/// `setIDEWorkspaceRoots` is privileged and needs a secret only DTD's spawner
/// receives, which is why we start our own daemon instead of reusing the one
/// behind `flutter run --print-dtd`.
class WebDevtoolsServer {
  WebDevtoolsServer({
    required ProcessManager processManager,
    required Logger logger,
    required DisposeScope disposeScope,
  }) : _processManager = processManager,
       _logger = logger,
       _disposeScope = disposeScope;

  final ProcessManager _processManager;
  final Logger _logger;
  final DisposeScope _disposeScope;

  static const _startupTimeout = Duration(seconds: 45);

  /// Starts the daemon and the DevTools server, and returns the base URL to
  /// serve the extension from (e.g. `http://127.0.0.1:9100`).
  ///
  /// Returns null if anything fails. This is a convenience on top of a working
  /// develop session, so a failure here is logged and otherwise ignored.
  Future<String?> serve({
    required FlutterCommand flutterCommand,
    required String projectRoot,
  }) async {
    try {
      final dart = flutterCommand.toDartCommand();

      final daemon = await _startToolingDaemon(dart);
      if (daemon == null) {
        return null;
      }

      await _setWorkspaceRoots(
        daemonUri: daemon.uri,
        secret: daemon.secret,
        projectRoot: projectRoot,
      );

      return await _startDevtools(dart, daemon.uri);
    } on Object catch (err, st) {
      _logger
        ..detail('Failed to serve the Patrol DevTools extension: $err')
        ..detail('$st');
      return null;
    }
  }

  Future<_ToolingDaemon?> _startToolingDaemon(FlutterCommand dart) async {
    _logger.detail('Starting the Dart Tooling Daemon...');

    final process =
        await _processManager.start([
            dart.executable,
            ...dart.arguments,
            'tooling-daemon',
            '--machine',
          ])
          ..disposedBy(_disposeScope);

    final details = Completer<_ToolingDaemon>();

    process
        .listenStdOut((line) {
          if (details.isCompleted || !line.contains('tooling_daemon_details')) {
            return;
          }
          try {
            final json =
                (jsonDecode(line)
                        as Map<String, dynamic>)['tooling_daemon_details']
                    as Map<String, dynamic>;
            details.complete(
              _ToolingDaemon(
                uri: json['uri'] as String,
                secret: json['trusted_client_secret'] as String,
              ),
            );
          } on Object catch (err) {
            _logger.detail('Failed to parse tooling daemon details: $err');
          }
        })
        .disposedBy(_disposeScope);

    process
        .listenStdErr((line) => _logger.detail('Tooling daemon: $line'))
        .disposedBy(_disposeScope);

    try {
      return await details.future.timeout(_startupTimeout);
    } on TimeoutException {
      _logger.detail('The Dart Tooling Daemon did not report its URI in time');
      return null;
    }
  }

  Future<void> _setWorkspaceRoots({
    required String daemonUri,
    required String secret,
    required String projectRoot,
  }) async {
    final socket = await WebSocket.connect(
      daemonUri,
    ).timeout(const Duration(seconds: 20));

    try {
      final reply = Completer<Map<String, dynamic>>();

      socket
        ..listen(
          (dynamic data) {
            if (!reply.isCompleted) {
              reply.complete(
                jsonDecode(data as String) as Map<String, dynamic>,
              );
            }
          },
          onError: (Object err) {
            if (!reply.isCompleted) {
              reply.completeError(err);
            }
          },
        )
        ..add(
          jsonEncode({
            'jsonrpc': '2.0',
            'id': 1,
            'method': 'FileSystem.setIDEWorkspaceRoots',
            'params': {
              'roots': [Uri.directory(projectRoot).toString()],
              'secret': secret,
            },
          }),
        );

      final response = await reply.future.timeout(const Duration(seconds: 20));
      final error = response['error'];
      if (error != null) {
        throw StateError('setIDEWorkspaceRoots failed: $error');
      }
      _logger.detail('Registered $projectRoot as a DevTools workspace root');
    } finally {
      await socket.close();
    }
  }

  Future<String?> _startDevtools(FlutterCommand dart, String daemonUri) async {
    final port = await bindUnusedPort<int>((port) => port);

    _logger.detail('Starting the DevTools server on port $port...');

    final process =
        await _processManager.start([
            dart.executable,
            ...dart.arguments,
            'devtools',
            '--dtd-uri=$daemonUri',
            '--no-launch-browser',
            '--port=$port',
          ])
          ..disposedBy(_disposeScope);

    final url = Completer<String>();

    process
        .listenStdOut((line) {
          if (!url.isCompleted) {
            final match = RegExp(
              r'Serving DevTools at (http://\S+?)\.?$',
            ).firstMatch(line.trim());
            if (match != null) {
              url.complete(match.group(1));
              return;
            }
          }
          _logger.detail('DevTools: $line');
        })
        .disposedBy(_disposeScope);

    process
        .listenStdErr((line) => _logger.detail('DevTools: $line'))
        .disposedBy(_disposeScope);

    try {
      return await url.future.timeout(_startupTimeout);
    } on TimeoutException {
      _logger.detail('The DevTools server did not start in time');
      return null;
    }
  }
}

class _ToolingDaemon {
  const _ToolingDaemon({required this.uri, required this.secret});

  final String uri;
  final String secret;
}
