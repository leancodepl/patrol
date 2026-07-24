import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

String get markerPath =>
    '${Directory.systemTemp.path}${Platform.pathSeparator}patrol_windows_poc_clicked.txt';

String get textMarkerPath =>
    '${Directory.systemTemp.path}${Platform.pathSeparator}patrol_windows_poc_text.txt';

String get targetPath =>
    '${Directory.systemTemp.path}${Platform.pathSeparator}patrol_windows_poc_target.txt';

String? resolveFixtureExe() {
  final fromEnv = Platform.environment['PATROL_WINDOWS_FIXTURE_EXE'];
  if (fromEnv != null && fromEnv.isNotEmpty) {
    final file = File(fromEnv);
    if (file.existsSync()) {
      return file.absolute.path;
    }
  }

  var dir = Directory.current;
  for (var i = 0; i < 12; i++) {
    final candidates = [
      File(
        '${dir.path}${Platform.pathSeparator}dev'
        '${Platform.pathSeparator}windows_poc'
        '${Platform.pathSeparator}fixture'
        '${Platform.pathSeparator}bin'
        '${Platform.pathSeparator}Release'
        '${Platform.pathSeparator}net8.0-windows'
        '${Platform.pathSeparator}patrol_windows_fixture.exe',
      ),
      File(
        '${dir.path}${Platform.pathSeparator}fixture'
        '${Platform.pathSeparator}bin'
        '${Platform.pathSeparator}Release'
        '${Platform.pathSeparator}net8.0-windows'
        '${Platform.pathSeparator}patrol_windows_fixture.exe',
      ),
    ];
    for (final candidate in candidates) {
      if (candidate.existsSync()) {
        return candidate.absolute.path;
      }
    }
    if (dir.parent.path == dir.path) {
      break;
    }
    dir = dir.parent;
  }
  return null;
}

Future<Process> startFixture() async {
  for (final path in [markerPath, textMarkerPath, targetPath]) {
    final file = File(path);
    if (file.existsSync()) {
      file.deleteSync();
    }
  }

  final exePath = resolveFixtureExe();
  expect(
    exePath,
    isNotNull,
    reason:
        'Fixture exe not found. Build with: '
        'dotnet build dev/windows_poc/fixture -c Release '
        '(or set PATROL_WINDOWS_FIXTURE_EXE).',
  );

  final process = await Process.start(exePath!, []);
  final deadline = DateTime.now().add(const Duration(seconds: 10));
  while (!File(targetPath).existsSync()) {
    if (DateTime.now().isAfter(deadline)) {
      process.kill();
      fail('Timed out waiting for native fixture at $targetPath');
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  return process;
}
