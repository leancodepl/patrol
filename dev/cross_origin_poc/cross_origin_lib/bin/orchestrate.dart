/// Multi-app orchestrator for the Patrol cross-origin PoC.
///
/// Run from a controller-app directory (one whose pubspec.yaml has a
/// `patrol.remote.apps` section). Starts each remote app on its declared
/// port, waits for their main.dart.js to compile, then compiles the
/// controller with `--dart-define=PATROL_REMOTE_APPS=<json>` and finally
/// invokes Playwright against the controller.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

const _controllerPort = 8084;

class _AppSpec {
  _AppSpec({required this.name, required this.path, required this.port});
  final String name;
  final String path;
  final int port;
  String get origin => 'http://localhost:$port';
}

Future<int> main(List<String> args) async {
  final cwd = Directory.current;
  final pubspec = File('${cwd.path}/pubspec.yaml');
  if (!pubspec.existsSync()) {
    stderr.writeln('No pubspec.yaml in ${cwd.path}');
    return 2;
  }

  final yaml = loadYaml(pubspec.readAsStringSync()) as YamlMap;
  final apps = _parseApps(yaml);
  if (apps.isEmpty) {
    stderr.writeln('patrol.remote.apps is empty or missing in pubspec.yaml');
    return 2;
  }

  stdout.writeln('Discovered ${apps.length} remote app(s):');
  for (final a in apps) {
    stdout.writeln('  - ${a.name}: ${a.path} -> ${a.origin}');
  }

  final remoteAppsJson = jsonEncode({
    for (final a in apps) a.name: a.origin,
  });
  stdout.writeln('PATROL_REMOTE_APPS=$remoteAppsJson');

  final processes = <Process>[];
  final logFiles = <IOSink>[];

  Future<void> cleanup() async {
    stdout.writeln('\nCleaning up ${processes.length} flutter process(es)...');
    for (final p in processes) {
      p.kill();
    }
    for (final f in logFiles) {
      await f.close();
    }
  }

  ProcessSignal.sigint.watch().listen((_) async {
    await cleanup();
    exit(130);
  });

  try {
    // Start each remote app.
    for (final app in apps) {
      stdout.writeln('Starting ${app.name} on :${app.port} (cwd=${app.path})...');
      final logPath = '${cwd.path}/${app.name}.log';
      final logSink = File(logPath).openWrite();
      logFiles.add(logSink);

      final proc = await Process.start(
        'flutter',
        [
          'run',
          '-d', 'web-server',
          '--web-port=${app.port}',
          '--profile',
        ],
        workingDirectory: app.path,
      );
      proc.stdout.transform(utf8.decoder).listen(logSink.write);
      proc.stderr.transform(utf8.decoder).listen(logSink.write);
      processes.add(proc);
    }

    // Start the controller (current directory).
    stdout.writeln('Starting controller on :$_controllerPort (cwd=${cwd.path})...');
    final ctrlLogSink = File('${cwd.path}/controller.log').openWrite();
    logFiles.add(ctrlLogSink);
    final ctrlProc = await Process.start(
      'flutter',
      [
        'run',
        '-d', 'web-server',
        '--web-port=$_controllerPort',
        '--target=test_bundle.dart',
        '--profile',
        '--dart-define=PATROL_REMOTE_APPS=$remoteAppsJson',
      ],
      workingDirectory: cwd.path,
    );
    ctrlProc.stdout.transform(utf8.decoder).listen(ctrlLogSink.write);
    ctrlProc.stderr.transform(utf8.decoder).listen(ctrlLogSink.write);
    processes.add(ctrlProc);

    // Wait for all main.dart.js to be served as text/javascript.
    for (final app in apps) {
      if (!await _waitForJsReady(app.port, app.name)) {
        stderr.writeln('${app.name} did not become ready');
        await cleanup();
        return 1;
      }
    }
    if (!await _waitForJsReady(_controllerPort, 'controller')) {
      stderr.writeln('controller did not become ready');
      await cleanup();
      return 1;
    }

    // Run Playwright against the controller.
    final webRunner = _findWebRunner(cwd);
    if (webRunner == null) {
      stderr.writeln('Could not locate packages/patrol/web_runner from cwd');
      await cleanup();
      return 2;
    }
    stdout.writeln('\nAll apps ready. Running Playwright in $webRunner...\n');

    final pwExitCode = await _runPlaywright(webRunner);
    await cleanup();
    return pwExitCode;
  } catch (err, st) {
    stderr.writeln('Orchestrator error: $err\n$st');
    await cleanup();
    return 1;
  }
}

List<_AppSpec> _parseApps(YamlMap pubspec) {
  final patrol = pubspec['patrol'];
  if (patrol is! YamlMap) return const [];
  final remote = patrol['remote'];
  if (remote is! YamlMap) return const [];
  final apps = remote['apps'];
  if (apps is! YamlMap) return const [];

  final result = <_AppSpec>[];
  apps.forEach((name, spec) {
    if (spec is! YamlMap) return;
    final path = spec['path'] as String?;
    final port = spec['port'] as int?;
    if (path == null || port == null) return;
    result.add(_AppSpec(name: name as String, path: path, port: port));
  });
  return result;
}

Future<bool> _waitForJsReady(int port, String name, {int maxTries = 180}) async {
  stdout.write('Waiting for $name on :$port (main.dart.js)...');
  final client = HttpClient();
  client.connectionTimeout = const Duration(seconds: 2);

  for (var i = 0; i < maxTries; i++) {
    try {
      final req = await client.getUrl(Uri.parse('http://localhost:$port/main.dart.js'));
      final resp = await req.close();
      final ct = resp.headers.contentType?.mimeType ?? '';
      await resp.drain<void>();
      if (ct.contains('javascript')) {
        stdout.writeln(' ready ($ct)');
        client.close();
        return true;
      }
    } on Exception catch (_) {
      // not ready yet
    }
    await Future<void>.delayed(const Duration(seconds: 2));
  }
  client.close();
  stdout.writeln(' TIMEOUT');
  return false;
}

String? _findWebRunner(Directory startFrom) {
  var dir = startFrom;
  for (var i = 0; i < 10; i++) {
    final candidate = Directory('${dir.path}/packages/patrol/web_runner');
    if (candidate.existsSync()) return candidate.path;
    final parent = dir.parent;
    if (parent.path == dir.path) return null;
    dir = parent;
  }
  return null;
}

Future<int> _runPlaywright(String webRunner) async {
  final env = {
    ...Platform.environment,
    'BASE_URL': 'http://localhost:$_controllerPort',
    'PATROL_WEB_HEADLESS': Platform.environment['PATROL_WEB_HEADLESS'] ?? 'true',
  };

  if (!Directory('$webRunner/node_modules').existsSync()) {
    stdout.writeln('Installing npm deps in $webRunner...');
    final r = await Process.run('npm', ['install', '--silent'],
        workingDirectory: webRunner, runInShell: true);
    if (r.exitCode != 0) {
      stderr.writeln('npm install failed: ${r.stderr}');
      return r.exitCode;
    }
  }

  final proc = await Process.start(
    'npx',
    ['playwright', 'test'],
    workingDirectory: webRunner,
    environment: env,
    runInShell: true,
  );
  proc.stdout.transform(utf8.decoder).listen(stdout.write);
  proc.stderr.transform(utf8.decoder).listen(stderr.write);
  return proc.exitCode;
}
