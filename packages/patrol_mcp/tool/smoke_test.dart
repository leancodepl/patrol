// Startup smoke test for the patrol_mcp server.
//
// Dependency-resolution checks (`dart pub get`) prove the package *resolves*,
// but not that the server *runs*. Recent releases fixed runtime bugs that a
// `pub get` sails straight past. This guards the two that bookend a session's
// lifecycle:
//   - Startup: the Windows SIGTERM crash that stopped the server from starting
//     at all (#3035).
//   - Shutdown: MCP clients disconnect by closing stdin (EOF), not via a
//     signal; the server used to block forever on EOF and orphan its process
//     subtree (#3122). It must now exit cleanly on EOF.
//
// So this test spawns the real server, completes the MCP `initialize` handshake
// over stdio, then closes stdin and asserts the server exits with code 0. It
// needs no device or Patrol session — the handshake happens before any tool is
// invoked — so it is safe to run on a bare CI runner on every OS.
//
// Dependency resolution is the caller's choice — this script only spawns and
// drives the server, so it is agnostic to how deps were resolved:
//   - patrol_mcp-prepare runs it against pub.dev (newest, and constraint-floor).
//   - patrol_mcp-cli-compat runs it under melos against the local patrol_cli.
//
// It is written in Dart (not shell) on purpose: it must behave identically on
// ubuntu, macOS, and Windows, and pure-Dart process handling avoids the
// portability traps of `timeout`, background jobs, and PowerShell-vs-bash.
//
// Run from the package root:  dart run tool/smoke_test.dart

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

  // The server logs to stderr; mirror it so CI shows what happened on failure.
  final stderrBuffer = StringBuffer();
  process.stderr.transform(utf8.decoder).listen((chunk) {
    stderrBuffer.write(chunk);
    stderr.write(chunk);
  });

  // MCP stdio transport is newline-delimited JSON-RPC. Complete on the first
  // line that is a JSON-RPC response to our initialize request (id == 1).
  final handshake = Completer<String>();
  final stdoutSub = process.stdout
      .transform(utf8.decoder)
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
  process.stdin.writeln(jsonEncode(initializeRequest));
  await process.stdin.flush();

  // Race the handshake against the process dying, so a server that crashes on
  // startup fails fast with a clear message instead of hanging until timeout.
  // The exit branch resolves to a sentinel (rather than calling _fail directly)
  // so it stays side-effect-free if the handshake wins — otherwise it would
  // still fire later, during the normal EOF shutdown below.
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

  // Closing stdin sends EOF — the disconnect signal an MCP client uses. The
  // server must exit cleanly instead of blocking and orphaning its process
  // subtree (#3122). This is the shutdown regression guard.
  await process.stdin.close();

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
