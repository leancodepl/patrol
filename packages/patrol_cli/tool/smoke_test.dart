// Smoke test: spawn `patrol mcp`, complete the `initialize` handshake
// over stdio, then close stdin and assert it exits cleanly. Guards startup
// (#3035), shutdown-on-EOF (#3122), and that nothing but JSON-RPC reaches
// stdout. Dart, not shell, so it runs identically on every OS. Run from the
// package root: dart run tool/smoke_test.dart [--force-first-run]

import 'dart:async';
import 'dart:convert';
import 'dart:io';

const _handshakeTimeout = Duration(seconds: 60);
const _shutdownTimeout = Duration(seconds: 15);

Future<void> main(List<String> args) async {
  // The greeting and doctor report only run when no analytics config exists and
  // no CI vendor is detected, so the run that can pollute stdout is invisible
  // under a normal CI environment. --force-first-run recreates it.
  final forceFirstRun = args.contains('--force-first-run');
  final fakeHome = forceFirstRun
      ? Directory.systemTemp.createTempSync('patrol_smoke_home')
      : null;

  stdout.writeln(
    '[smoke] starting patrol mcp'
    '${forceFirstRun ? " (forced first run, HOME=${fakeHome!.path})" : ""}...',
  );

  final process = await Process.start(
    Platform.resolvedExecutable, // the `dart` running this script
    ['run', 'bin/main.dart', 'mcp'],
    workingDirectory: Directory.current.path,
    environment: fakeHome == null ? null : _pristineEnvironment(fakeHome.path),
    // `CI` and the vendor variables cannot be unset from a workflow's `env:`,
    // so the child gets a built-from-scratch environment instead.
    includeParentEnvironment: fakeHome == null,
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
  // Anything non-JSON on stdout is a protocol violation: the CLI's own output
  // (first-run greeting, doctor report, update banner) must go to stderr.
  final pollution = <String>[];
  final stdoutSub = process.stdout
      .transform(const Utf8Decoder(allowMalformed: true))
      .transform(const LineSplitter())
      .listen((line) {
        final message = _tryDecode(line);
        if (message == null) {
          if (line.trim().isNotEmpty) {
            pollution.add(line);
          }
          return;
        }
        if (!handshake.isCompleted &&
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

  if (pollution.isNotEmpty) {
    _fail(
      process,
      'stdout carried ${pollution.length} non-JSON line(s), which corrupts the '
      'JSON-RPC channel: ${pollution.take(5).join(" | ")}',
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

  fakeHome?.deleteSync(recursive: true);

  stdout
    ..writeln('[smoke] shutdown OK — server exited 0 on stdin EOF')
    ..writeln('[smoke] PASS');
}

/// A from-scratch environment with no CI markers, pointing the CLI's analytics
/// config at [home] so it reports a first run. `PlatformX.home` force-unwraps
/// `HOME` (`UserProfile` on Windows) and `dart run` needs the real pub cache, so
/// both have to be supplied explicitly.
Map<String, String> _pristineEnvironment(String home) {
  final parent = Platform.environment;
  return {
    'PATH': ?parent['PATH'],
    'PUB_CACHE': parent['PUB_CACHE'] ?? _defaultPubCache(parent),
    if (Platform.isWindows) ...{
      'UserProfile': home,
      // Dart on Windows cannot start without these.
      'SystemRoot': ?parent['SystemRoot'],
      'TEMP': ?parent['TEMP'],
      'ComSpec': ?parent['ComSpec'],
    } else
      'HOME': home,
  };
}

String _defaultPubCache(Map<String, String> parent) {
  if (Platform.isWindows) {
    final appData = parent['LOCALAPPDATA'] ?? parent['APPDATA'] ?? '';
    return '$appData\\Pub\\Cache';
  }
  return '${parent['HOME'] ?? ''}/.pub-cache';
}

Map<String, dynamic>? _tryDecode(String line) {
  if (line.trim().isEmpty) {
    return null;
  }
  try {
    final decoded = jsonDecode(line);
    return decoded is Map<String, dynamic> ? decoded : null;
  } on FormatException {
    return null; // caller records it as stdout pollution
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
