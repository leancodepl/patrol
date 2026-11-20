import 'dart:io' as io;

import 'package:path/path.dart' as p;
import 'package:patrol_cli/src/mcp/project_resolver.dart';
import 'package:test/test.dart';

void main() {
  group('ProjectResolver', () {
    late io.Directory tmp;

    setUp(() => tmp = io.Directory.systemTemp.createTempSync('patrol_mcp_res'));
    tearDown(() => tmp.deleteSync(recursive: true));

    /// Creates `<tmp>/<name>/pubspec.yaml` and returns the canonical dir path.
    String project(String name) {
      final dir = io.Directory(p.join(tmp.path, name))
        ..createSync(recursive: true);
      io.File(
        p.join(dir.path, 'pubspec.yaml'),
      ).writeAsStringSync('name: $name');
      return p.canonicalize(dir.path);
    }

    ProjectResolver resolver({
      Map<String, String> env = const {},
      List<String> roots = const [],
      String? cwd,
      String? projectRootOverride,
    }) => ProjectResolver(
      readRoots: () async => roots,
      projectRootOverride: projectRootOverride,
      environment: env,
      currentDirectory: () => cwd ?? tmp.path,
    );

    test('--project-root wins over every other signal', () async {
      final explicit = project('app');
      final fromEnv = project('from_env');
      final workspace = project('workspace');

      final root = await resolver(
        projectRootOverride: explicit,
        env: {'PROJECT_ROOT': fromEnv, 'CLAUDE_PROJECT_DIR': fromEnv},
        roots: [workspace],
        cwd: workspace,
      ).resolve();

      expect(root, explicit);
    });

    test('falls through when --project-root has no pubspec', () async {
      final fromEnv = project('app');
      final empty = io.Directory(p.join(tmp.path, 'not_a_project'))
        ..createSync();

      final root = await resolver(
        projectRootOverride: empty.path,
        env: {'PROJECT_ROOT': fromEnv},
      ).resolve();

      expect(root, fromEnv);
    });

    test('PROJECT_ROOT wins over roots', () async {
      final explicit = project('app');
      final workspace = project('other');

      final root = await resolver(
        env: {'PROJECT_ROOT': explicit},
        roots: [workspace],
      ).resolve();

      expect(root, explicit);
    });

    test('falls back to roots when PROJECT_ROOT is unset', () async {
      final workspace = project('app');

      final root = await resolver(roots: [workspace]).resolve();

      expect(root, workspace);
    });

    test(
      'falls back to CLAUDE_PROJECT_DIR when no PROJECT_ROOT or roots',
      () async {
        final claude = project('app');

        final root = await resolver(
          env: {'CLAUDE_PROJECT_DIR': claude},
        ).resolve();

        expect(root, claude);
      },
    );

    test('falls back to cwd last', () async {
      final cwd = project('app');

      final root = await resolver(cwd: cwd).resolve();

      expect(root, cwd);
    });

    test('walks up to the nearest pubspec.yaml', () async {
      final appRoot = project('app');
      final nested = io.Directory(p.join(appRoot, 'integration_test'))
        ..createSync(recursive: true);

      final root = await resolver(env: {'PROJECT_ROOT': nested.path}).resolve();

      expect(root, appRoot);
    });

    test('skips a signal with no pubspec and uses the next one', () async {
      final noPubspec = io.Directory(p.join(tmp.path, 'empty'))
        ..createSync(recursive: true);
      final workspace = project('app');

      final root = await resolver(
        env: {'PROJECT_ROOT': noPubspec.path},
        roots: [workspace],
      ).resolve();

      expect(root, workspace);
    });

    test(
      'throws a legible error naming each signal when nothing resolves',
      () async {
        final empty = io.Directory(p.join(tmp.path, 'empty'))
          ..createSync(recursive: true);

        await expectLater(
          resolver(
            env: {'PROJECT_ROOT': empty.path},
            cwd: empty.path,
          ).resolve(),
          throwsA(
            isA<ProjectResolutionException>().having(
              (e) => e.toString(),
              'message',
              allOf(contains('PROJECT_ROOT='), contains('no pubspec.yaml')),
            ),
          ),
        );
      },
    );

    test('a failing roots reader does not block other signals', () async {
      final claude = project('app');

      final root = await ProjectResolver(
        readRoots: () async => throw Exception('client refused'),
        environment: {'CLAUDE_PROJECT_DIR': claude},
        currentDirectory: () => tmp.path,
      ).resolve();

      expect(root, claude);
    });

    test('caches the result across calls', () async {
      final first = project('app');
      var rootsCalls = 0;

      final r = ProjectResolver(
        readRoots: () async {
          rootsCalls++;
          return const [];
        },
        environment: {'PROJECT_ROOT': first},
        currentDirectory: () => tmp.path,
      );

      expect(await r.resolve(), first);
      expect(await r.resolve(), first);
      // Cached: the (non-explicit) roots reader is only consulted on the first
      // resolve, and here never, since PROJECT_ROOT hits first.
      expect(rootsCalls, 0);
    });
  });
}
