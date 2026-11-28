import 'dart:io' as io;

import 'package:file/memory.dart';
import 'package:path/path.dart' as p;
import 'package:patrol_cli/src/mcp/project_resolver.dart';
import 'package:test/test.dart';

/// The tests below assert on the project; the resolver also answers with the
/// test file as that project sees it, which `patrol_session_test.dart` covers.
extension on Future<ResolvedProject> {
  Future<String> get root => then((resolved) => resolved.root);
}

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

    test('reads the working directory the server started in', () async {
      final started = project('started');
      var cwd = started;
      final r = ProjectResolver(
        readRoots: () async => const [],
        environment: const {},
        currentDirectory: () => cwd,
      );
      // Resolving a project enters it.
      cwd = project('entered');

      expect(await r.resolve(remember: false).root, started);
    });

    /// Writes `<dir>/<relative>` and every directory above it.
    void testFile(String dir, String relative) {
      final file = io.File(p.join(dir, relative));
      file.parent.createSync(recursive: true);
      file.writeAsStringSync('void main() {}');
    }

    test('reaches a project in a subdirectory through the test file', () async {
      final repo = io.Directory(p.join(tmp.path, 'repo'))
        ..createSync(recursive: true);
      final app = project('repo/app');
      testFile(app, 'patrol_test/login_test.dart');

      final root = await resolver(
        roots: [repo.path],
      ).resolve(testFile: 'app/patrol_test/login_test.dart').root;

      expect(root, app);
    });

    test('prefers the test file over a workspace pubspec above it', () async {
      // A repository root can carry its own pubspec.yaml, which walking up
      // would take for the project.
      final workspace = project('ws');
      final app = project('ws/app');
      testFile(app, 'patrol_test/login_test.dart');

      final root = await resolver(
        roots: [workspace],
      ).resolve(testFile: 'app/patrol_test/login_test.dart').root;

      expect(root, app);
    });

    test('falls back to walking up when the test file is elsewhere', () async {
      final app = project('app');

      final root = await resolver(
        roots: [app],
      ).resolve(testFile: 'patrol_test/nope_test.dart').root;

      expect(root, app);
    });

    test('revisits a root that does not own the test file', () async {
      final workspace = project('ws');
      final app = project('ws/app');
      testFile(app, 'patrol_test/login_test.dart');
      final subject = resolver(roots: [workspace]);

      // Something that needs no test file resolves first, e.g. status.
      expect(await subject.resolve().root, workspace);

      expect(
        await subject.resolve(testFile: 'app/patrol_test/login_test.dart').root,
        app,
      );
    });

    test('answers with the test file as the project sees it', () async {
      final workspace = project('ws');
      final app = project('ws/app');
      testFile(app, 'patrol_test/login_test.dart');

      final resolved = await resolver(
        roots: [workspace],
      ).resolve(testFile: 'app/patrol_test/login_test.dart');

      expect(resolved.root, app);
      expect(resolved.testFile, p.join('patrol_test', 'login_test.dart'));
    });

    test('an absolute test file wins over a configured project', () async {
      // A worktree of the same repository is a different project.
      final main = project('main');
      final worktree = project('main-flow');
      testFile(worktree, 'patrol_test/login_test.dart');

      final resolved = await resolver(
        projectRootOverride: '.',
        cwd: main,
      ).resolve(testFile: p.join(worktree, 'patrol_test', 'login_test.dart'));

      expect(resolved.root, worktree);
      expect(resolved.testFile, p.join('patrol_test', 'login_test.dart'));
    });

    test('an absolute test file moves a cached project', () async {
      final main = project('main');
      final worktree = project('main-flow');
      testFile(worktree, 'patrol_test/login_test.dart');
      final subject = resolver(projectRootOverride: main, cwd: main);

      expect(await subject.resolve().root, main);

      expect(
        await subject
            .resolve(
              testFile: p.join(worktree, 'patrol_test', 'login_test.dart'),
            )
            .root,
        worktree,
      );
    });

    test('an absolute test directory moves a cached project', () async {
      final main = project('main');
      final other = project('other');
      testFile(other, 'patrol_test/login_test.dart');
      final subject = resolver(projectRootOverride: main, cwd: main);

      expect(await subject.resolve().root, main);

      final resolved = await subject.resolve(
        testFile: p.join(other, 'patrol_test'),
      );
      expect(resolved.root, other);
      expect(resolved.testFile, 'patrol_test');
    });

    test('a root asked for without remembering leaves the cache', () async {
      final anchored = project('anchored');
      final asked = project('asked');
      final subject = resolver(projectRootOverride: anchored);
      expect(await subject.resolve().root, anchored);

      expect(
        await subject.resolve(requestedRoot: asked, remember: false).root,
        asked,
      );

      expect(await subject.resolve().root, anchored);
    });

    test('a relative --project-root survives entering a project', () async {
      final app = project('app');
      var cwd = tmp.path;
      final subject = ProjectResolver(
        readRoots: () async => const [],
        projectRootOverride: 'app',
        environment: const {},
        currentDirectory: () => cwd,
      );
      expect(await subject.resolve().root, app);

      // Resolving entered the project, so the process now sits inside it.
      cwd = app;

      expect(await subject.resolve(requestedRoot: app).root, app);
    });

    for (final style in [FileSystemStyle.posix, FileSystemStyle.windows]) {
      final name = style == FileSystemStyle.windows ? 'windows' : 'posix';
      test(
        'resolves on a $name filesystem that never touches the disk',
        () async {
          final fs = MemoryFileSystem.test(style: style);
          final repo = fs.currentDirectory.childDirectory('repo').path;
          final app = fs.directory(fs.path.join(repo, 'app'))
            ..createSync(recursive: true);
          app.childFile('pubspec.yaml').writeAsStringSync('name: app');
          fs
              .file(fs.path.join(app.path, 'patrol_test', 'login_test.dart'))
              .createSync(recursive: true);

          final resolved =
              await ProjectResolver(
                readRoots: () async => [repo],
                environment: const {},
                currentDirectory: () => repo,
                fileSystem: fs,
              ).resolve(
                testFile: fs.path.join('app', 'patrol_test', 'login_test.dart'),
              );

          expect(resolved.root, fs.path.canonicalize(app.path));
          expect(
            resolved.testFile,
            fs.path.join('patrol_test', 'login_test.dart'),
          );
        },
      );
    }

    test('fails on a test file outside the requested root', () async {
      final requested = project('requested');
      final other = project('other');
      testFile(other, 'patrol_test/login_test.dart');

      await expectLater(
        resolver().resolve(
          requestedRoot: requested,
          testFile: p.join(other, 'patrol_test', 'login_test.dart'),
        ),
        throwsA(
          isA<ProjectResolutionException>().having(
            (e) => e.toString(),
            'message',
            allOf(contains(other), contains('outside projectRoot')),
          ),
        ),
      );
    });

    test("does not look for a requested root's test file elsewhere", () async {
      final requested = project('requested');
      final started = project('started');
      testFile(started, 'patrol_test/login_test.dart');

      final resolved = await resolver(cwd: started).resolve(
        requestedRoot: requested,
        testFile: p.join('patrol_test', 'login_test.dart'),
      );

      expect(resolved.root, requested);
      expect(resolved.testFile, p.join('patrol_test', 'login_test.dart'));
    });

    test(
      'reaches a package below the requested root by a relative path',
      () async {
        final repo = project('repo');
        final app = project(p.join('repo', 'app'));
        testFile(app, 'patrol_test/login_test.dart');

        final resolved = await resolver().resolve(
          requestedRoot: repo,
          testFile: p.join('app', 'patrol_test', 'login_test.dart'),
        );

        expect(resolved.root, app);
        expect(resolved.testFile, p.join('patrol_test', 'login_test.dart'));
      },
    );

    test(
      'reads a relative requested root from where the server started',
      () async {
        final started = project('started');
        final other = project('other');
        var cwd = started;
        final r = ProjectResolver(
          readRoots: () async => const [],
          environment: const {},
          currentDirectory: () => cwd,
        );
        cwd = other;

        expect(
          await r.resolve(requestedRoot: p.join('..', 'other')).root,
          other,
        );
        expect(await r.resolve(requestedRoot: '.').root, started);
      },
    );

    test(
      'takes a package below the requested root from its test file',
      () async {
        final repo = project('repo');
        final app = project(p.join('repo', 'app'));
        testFile(app, 'patrol_test/login_test.dart');

        final root = await resolver()
            .resolve(
              requestedRoot: repo,
              testFile: p.join(app, 'patrol_test', 'login_test.dart'),
            )
            .root;

        expect(root, app);
      },
    );

    test('a requested root wins over every other signal', () async {
      final requested = project('requested');
      final explicit = project('app');
      final fromEnv = project('from_env');
      final workspace = project('workspace');

      final root = await resolver(
        projectRootOverride: explicit,
        env: {'PROJECT_ROOT': fromEnv, 'CLAUDE_PROJECT_DIR': fromEnv},
        roots: [workspace],
        cwd: workspace,
      ).resolve(requestedRoot: requested).root;

      expect(root, requested);
    });

    test('a requested root replaces a cached one', () async {
      final first = project('first');
      final second = project('second');
      final subject = resolver(projectRootOverride: first);

      expect(await subject.resolve().root, first);
      expect(await subject.resolve(requestedRoot: second).root, second);
      // Later calls that name nothing see the root that was requested last.
      expect(await subject.resolve().root, second);
    });

    test('--project-root wins over every other signal', () async {
      final explicit = project('app');
      final fromEnv = project('from_env');
      final workspace = project('workspace');

      final root = await resolver(
        projectRootOverride: explicit,
        env: {'PROJECT_ROOT': fromEnv, 'CLAUDE_PROJECT_DIR': fromEnv},
        roots: [workspace],
        cwd: workspace,
      ).resolve().root;

      expect(root, explicit);
    });

    test('falls through when --project-root has no pubspec', () async {
      final fromEnv = project('app');
      final empty = io.Directory(p.join(tmp.path, 'not_a_project'))
        ..createSync();

      final root = await resolver(
        projectRootOverride: empty.path,
        env: {'PROJECT_ROOT': fromEnv},
      ).resolve().root;

      expect(root, fromEnv);
    });

    test('PROJECT_ROOT wins over roots', () async {
      final explicit = project('app');
      final workspace = project('other');

      final root = await resolver(
        env: {'PROJECT_ROOT': explicit},
        roots: [workspace],
      ).resolve().root;

      expect(root, explicit);
    });

    test('falls back to roots when PROJECT_ROOT is unset', () async {
      final workspace = project('app');

      final root = await resolver(roots: [workspace]).resolve().root;

      expect(root, workspace);
    });

    test(
      'falls back to CLAUDE_PROJECT_DIR when no PROJECT_ROOT or roots',
      () async {
        final claude = project('app');

        final root = await resolver(
          env: {'CLAUDE_PROJECT_DIR': claude},
        ).resolve().root;

        expect(root, claude);
      },
    );

    test('falls back to cwd last', () async {
      final cwd = project('app');

      final root = await resolver(cwd: cwd).resolve().root;

      expect(root, cwd);
    });

    test('walks up to the nearest pubspec.yaml', () async {
      final appRoot = project('app');
      final nested = io.Directory(p.join(appRoot, 'integration_test'))
        ..createSync(recursive: true);

      final root = await resolver(
        env: {'PROJECT_ROOT': nested.path},
      ).resolve().root;

      expect(root, appRoot);
    });

    test('skips a signal with no pubspec and uses the next one', () async {
      final noPubspec = io.Directory(p.join(tmp.path, 'empty'))
        ..createSync(recursive: true);
      final cwd = project('app');

      final root = await resolver(
        env: {'CLAUDE_PROJECT_DIR': noPubspec.path},
        cwd: cwd,
      ).resolve().root;

      expect(root, cwd);
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
          ).resolve().root,
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
      ).resolve().root;

      expect(root, claude);
    });

    test('caches the result across calls', () async {
      final first = project('app');
      var rootsCalls = 0;

      final r = ProjectResolver(
        readRoots: () async {
          rootsCalls++;
          return [first];
        },
        environment: const {},
        currentDirectory: () => tmp.path,
      );

      expect(await r.resolve().root, first);
      expect(await r.resolve().root, first);
      expect(rootsCalls, 1);
    });

    test('fails on an explicit root that has no project', () async {
      final r = ProjectResolver(
        readRoots: () async => const [],
        environment: {'PROJECT_ROOT': '${tmp.path}/missing'},
        currentDirectory: () => project('app'),
      );

      await expectLater(
        r.resolve(),
        throwsA(isA<ProjectResolutionException>()),
      );
    });
  });
}
