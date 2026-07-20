// Smoke test: spawn the MCP server, complete the `initialize` handshake over
// stdio, then close stdin and assert it exits cleanly. Guards startup (#3035)
// and shutdown-on-EOF (#3122). Dart, not shell, so it runs identically on every
// OS. Run from the package root: dart run tool/smoke_test.dart
//
// Resolution is the caller's choice (pub.dev in prepare, melos in cli-compat);
// this script only drives the server.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

const _handshakeTimeout = Duration(seconds: 60);
const _shutdownTimeout = Duration(seconds: 15);

Future<void> main() async {
  stdout.writeln('[smoke] starting patrol_mcp server...');

  final process = await Process.start(
    Platform.resolvedExecutable, // the `dart` running this script
    ['run', 'bin/patrol_mcp.dart'],
    workingDirectory: Directory.current.path,
  );

  // If the server exits early, writes to its stdin break; swallow that so the
  // exitCode race below reports the real failure instead of an unhandled error.
  unawaited(process.stdin.done.catchError((Object _) {}));

  // The server logs to stderr; mirror it so CI shows what happened on failure.
  // allowMalformed: a non-UTF-8 console code page (Windows) must not crash us.
  final stderrBuffer = StringBuffer();
  process.stderr.transform(const Utf8Decoder(allowMalformed: true)).listen((
    chunk,
  ) {
    stderrBuffer.write(chunk);
    stderr.write(chunk);
  });

  // MCP stdio transport is newline-delimited JSON-RPC. Complete on the first
  // line that is a JSON-RPC response to our initialize request (id == 1).
  final handshake = Completer<String>();
  final stdoutSub = process.stdout
      .transform(const Utf8Decoder(allowMalformed: true))
      .transform(const LineSplitter())
      .listen((line) {
        final message = _tryDecode(line);
        if (!handshake.isCompleted &&
            message != null &&
            message['id'] == 1 &&
            message['result'] != null) {
          handshake.complete(line);
        }
      });

  const initializeRequest = {
    'jsonrpc': '2.0',
    'id': 1,
    'method': 'initialize',
    'params': {
      'protocolVersion': '2024-11-05',
      'capabilities': <String, dynamic>{},
      'clientInfo': {'name': 'patrol_mcp_smoke', 'version': '1.0.0'},
    },
  };
  // A broken pipe here just means the server already exited; the race reports it.
  try {
    process.stdin.writeln(jsonEncode(initializeRequest));
    await process.stdin.flush();
  } on Object {
    /* ignored — surfaced via the exit branch below */
  }

  // Race the handshake against early exit so a startup crash fails fast. The
  // exit branch yields a sentinel (not _fail) so it's a no-op if handshake wins.
  const exitedSentinel = ' process-exited';
  final line =
      await Future.any([
        handshake.future,
        process.exitCode.then((_) => exitedSentinel),
      ]).timeout(
        _handshakeTimeout,
        onTimeout: () => _fail(
          process,
          'timed out after ${_handshakeTimeout.inSeconds}s waiting for the '
          'initialize response',
          stderrBuffer,
        ),
      );
  await stdoutSub.cancel();

  if (identical(line, exitedSentinel)) {
    _fail(
      process,
      'server exited early (code ${await process.exitCode}) before answering '
      'initialize',
      stderrBuffer,
    );
  }

  final result =
      (jsonDecode(line) as Map<String, dynamic>)['result']
          as Map<String, dynamic>;
  final serverInfo = result['serverInfo'] as Map<String, dynamic>?;
  final serverName = serverInfo?['name'];
  if (serverName != 'patrol_mcp') {
    _fail(
      process,
      "handshake returned unexpected serverInfo.name: '$serverName' "
      "(expected 'patrol_mcp'). Full result: $result",
      stderrBuffer,
    );
  }

  stdout.writeln(
    '[smoke] handshake OK — server "$serverName" '
    'v${serverInfo?['version']} responded to initialize',
  );

  // Closing stdin sends EOF — how MCP clients disconnect. Server must exit
  // cleanly, not hang and orphan its process subtree (#3122). A throw here means
  // it already exited — fine, the exitCode check below still runs.
  try {
    await process.stdin.close();
  } on Object {
    /* ignored */
  }

  final exitCode = await process.exitCode.timeout(
    _shutdownTimeout,
    onTimeout: () => _fail(
      process,
      'server did not exit within ${_shutdownTimeout.inSeconds}s of stdin '
      'closing (EOF) — it is blocking on shutdown and would orphan its '
      'process subtree (#3122)',
      stderrBuffer,
    ),
  );

  if (exitCode != 0) {
    _fail(
      process,
      'server exited with code $exitCode after stdin EOF (expected 0)',
      stderrBuffer,
    );
  }

  stdout
    ..writeln('[smoke] shutdown OK — server exited 0 on stdin EOF')
    ..writeln('[smoke] PASS');
}

Map<String, dynamic>? _tryDecode(String line) {
  if (line.trim().isEmpty) {
    return null;
  }
  try {
    final decoded = jsonDecode(line);
    return decoded is Map<String, dynamic> ? decoded : null;
  } on FormatException {
    return null; // non-JSON log line on stdout — ignore
  }
}

Never _fail(Process process, String message, StringBuffer serverStderr) {
  process.kill();
  stderr
    ..writeln('[smoke] FAIL: $message')
    ..writeln('[smoke] --- server stderr ---')
    ..writeln(serverStderr.toString().trim());
  exit(1);
}
