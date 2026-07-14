import 'dart:io' as io;

import 'package:path/path.dart' as p;
import 'package:patrol_mcp/src/flutter_command_resolver.dart';
import 'package:test/test.dart';

void main() {
  group('FlutterCommandResolver', () {
    FlutterCommandResolver resolver({
      Map<String, String> env = const {},
      Set<String> existing = const {},
      bool fvmInstalled = true,
      bool flutterInstalled = true,
    }) => FlutterCommandResolver(
      environment: env,
      pathExists: existing.contains,
      isFvmInstalled: () => fvmInstalled,
      isFlutterInstalled: () => flutterInstalled,
    );

    String join(String dir, String a, [String? b]) =>
        b == null ? p.join(dir, a) : p.join(dir, a, b);

    const root = '/repo/app';

    test('PATROL_FLUTTER_COMMAND takes precedence over FVM detection', () {
      final r = resolver(
        env: {'PATROL_FLUTTER_COMMAND': 'fvm flutter'},
        existing: {join(root, '.fvmrc')}, // pinned, but env should win
      ).resolve(projectRoot: root);

      expect(r.command!.executable, 'fvm');
      expect(r.command!.arguments, ['flutter']);
      expect(r.reason, contains('PATROL_FLUTTER_COMMAND'));
      expect(r.isWarning, isFalse);
    });

    test('empty PATROL_FLUTTER_COMMAND is ignored', () {
      final r = resolver(
        env: {'PATROL_FLUTTER_COMMAND': ''},
      ).resolve(projectRoot: root);

      expect(r.command, isNull); // falls through to default
      expect(r.reason, contains('flutter'));
    });

    test(
      'materialized .fvm/flutter_sdk is used directly, without fvm on PATH',
      () {
        final binName = io.Platform.isWindows ? 'flutter.bat' : 'flutter';
        final sdkFlutter = p.join(root, '.fvm', 'flutter_sdk', 'bin', binName);
        final r = resolver(
          existing: {join(root, '.fvmrc'), sdkFlutter},
          fvmInstalled: false, // proves we don't depend on `fvm` on PATH
        ).resolve(projectRoot: root);

        expect(r.command!.executable, sdkFlutter);
        expect(r.command!.arguments, isEmpty);
        expect(r.reason, contains('.fvm/flutter_sdk'));
        expect(r.isWarning, isFalse);
      },
    );

    test('pin without materialized symlink + fvm on PATH -> fvm flutter', () {
      final r = resolver(
        existing: {join(root, '.fvmrc')},
      ).resolve(projectRoot: root);

      expect(r.command!.executable, 'fvm');
      expect(r.command!.arguments, ['flutter']);
      expect(r.reason, contains('auto-detected FVM pin'));
      expect(r.isWarning, isFalse);
    });

    test('detects .fvm/fvm_config.json pin', () {
      final r = resolver(
        existing: {join(root, '.fvm', 'fvm_config.json')},
      ).resolve(projectRoot: root);

      expect(r.command!.executable, 'fvm');
    });

    test('detects a pin in an ancestor directory', () {
      final r = resolver(
        existing: {join('/repo', '.fvmrc')},
      ).resolve(projectRoot: root);

      expect(r.command!.executable, 'fvm');
      expect(r.reason, contains('/repo'));
    });

    test(
      'pinned but fvm not on PATH -> falls back to flutter with warning',
      () {
        final r = resolver(
          existing: {join(root, '.fvmrc')},
          fvmInstalled: false,
        ).resolve(projectRoot: root);

        expect(r.command, isNull);
        expect(r.isWarning, isTrue);
        expect(r.reason, contains('not on PATH'));
      },
    );

    test('no pin, flutter on PATH -> default flutter, no warning', () {
      final r = resolver().resolve(projectRoot: root);

      expect(r.command, isNull);
      expect(r.isWarning, isFalse);
      expect(r.reason, contains('flutter'));
    });

    test('no pin, flutter not on PATH but fvm is -> fvm flutter', () {
      final r = resolver(flutterInstalled: false).resolve(projectRoot: root);

      expect(r.command!.executable, 'fvm');
      expect(r.command!.arguments, ['flutter']);
      expect(r.reason, contains('not on PATH'));
    });

    test('no pin, neither flutter nor fvm on PATH -> default flutter', () {
      final r = resolver(
        flutterInstalled: false,
        fvmInstalled: false,
      ).resolve(projectRoot: root);

      expect(r.command, isNull);
    });

    test('search stops at a .git boundary (pin above repo is ignored)', () {
      // .git marks /repo/app as the repo root; the pin one level up must not
      // be picked up.
      final r = resolver(
        existing: {join(root, '.git'), join('/repo', '.fvmrc')},
      ).resolve(projectRoot: root);

      expect(r.command, isNull);
      expect(r.reason, contains('flutter'));
    });
  });
}
