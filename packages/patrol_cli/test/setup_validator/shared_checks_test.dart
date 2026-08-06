import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:patrol_cli/src/setup_validator/checks/shared_checks.dart';
import 'package:patrol_cli/src/setup_validator/finding.dart';
import 'package:patrol_cli/src/setup_validator/project_probe.dart';
import 'package:test/test.dart';

const _completePubspec = '''
name: example_app

dependencies:
  flutter:
    sdk: flutter

dev_dependencies:
  patrol: ^4.0.0

patrol:
  app_name: My App
  android:
    package_name: com.example.myapp
  ios:
    bundle_id: com.example.MyApp
''';

const _compatibleLock = '''
packages:
  patrol:
    dependency: "direct dev"
    version: "4.6.0"
''';

void main() {
  late MemoryFileSystem fs;
  late Directory projectRoot;

  setUp(() {
    fs = MemoryFileSystem();
    projectRoot = fs.directory('/project')..createSync();
  });

  /// Creates a project that passes every shared check, then lets [mutate]
  /// remove or change a single aspect.
  SharedCheckContext contextWith({void Function()? mutate}) {
    fs.file('/project/pubspec.yaml').writeAsStringSync(_completePubspec);
    fs.file('/project/pubspec.lock').writeAsStringSync(_compatibleLock);
    fs.file('/project/patrol_test/example_test.dart').createSync(
      recursive: true,
    );
    fs.file('/project/.gitignore').writeAsStringSync(
      'patrol_test/test_bundle.dart\n',
    );
    mutate?.call();
    return SharedCheckContext(probe: ProjectProbe(projectRoot: projectRoot));
  }

  group('complete project', () {
    test('passes all shared checks', () {
      final ctx = contextWith();
      expect(checkPatrolDependency(ctx), isNull);
      expect(checkPatrolSection(ctx), isNull);
      expect(checkAppName(ctx), isNull);
      expect(checkStrayPatrolYaml(ctx), isNull);
      expect(checkTestDirectory(ctx), isNull);
      expect(checkIntegrationTestDirectory(ctx), isNull);
      expect(checkTestBundleGitignored(ctx), isNull);
      expect(checkVersionCompatibility(ctx, cliVersion: '4.4.0'), isNull);
    });
  });

  group('S1 patrol dependency', () {
    test('errors when patrol is not declared anywhere', () {
      final ctx = contextWith(
        mutate: () => fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: example_app
dependencies:
  flutter:
    sdk: flutter
patrol:
  app_name: My App
'''),
      );
      expect(checkPatrolDependency(ctx)?.severity, Severity.error);
    });

    test('passes when patrol is in regular dependencies', () {
      final ctx = contextWith(
        mutate: () => fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: example_app
dependencies:
  patrol: ^4.0.0
patrol:
  app_name: My App
'''),
      );
      expect(checkPatrolDependency(ctx), isNull);
    });

    test('passes when patrol is a path dependency', () {
      final ctx = contextWith(
        mutate: () => fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: example_app
dev_dependencies:
  patrol:
    path: ../patrol
patrol:
  app_name: My App
'''),
      );
      expect(checkPatrolDependency(ctx), isNull);
    });
  });

  group('S2 patrol section', () {
    test('errors when the patrol section is missing', () {
      final ctx = contextWith(
        mutate: () => fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: example_app
dev_dependencies:
  patrol: ^4.0.0
'''),
      );
      final finding = checkPatrolSection(ctx);
      expect(finding?.severity, Severity.error);
      expect(finding?.summary, contains('No `patrol:` section'));
    });

    test('errors listing missing platform identifiers', () {
      final ctx = contextWith(
        mutate: () => fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: example_app
dev_dependencies:
  patrol: ^4.0.0
patrol:
  app_name: My App
  android: {}
  macos: {}
'''),
      );
      final finding = checkPatrolSection(ctx);
      expect(finding?.severity, Severity.error);
      expect(finding?.summary, contains('android.package_name'));
      expect(finding?.summary, contains('macos.bundle_id'));
    });

    test('warns when app_name is missing everywhere', () {
      final ctx = contextWith(
        mutate: () => fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: example_app
dev_dependencies:
  patrol: ^4.0.0
patrol:
  android:
    package_name: com.example.myapp
'''),
      );
      final finding = checkAppName(ctx);
      expect(finding?.severity, Severity.warning);
      expect(finding?.fix, contains('--app-name'));
      expect(checkPatrolSection(ctx), isNull);
    });

    test('passes when app_name is set per platform', () {
      final ctx = contextWith(
        mutate: () => fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: example_app
dev_dependencies:
  patrol: ^4.0.0
patrol:
  android:
    package_name: com.example.myapp
    app_name: My App
'''),
      );
      expect(checkPatrolSection(ctx), isNull);
    });
  });

  group('malformed pubspec shapes', () {
    test('scalar patrol section does not crash and reports S2', () {
      final ctx = contextWith(
        mutate: () => fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: example_app
dev_dependencies:
  patrol: ^4.0.0
patrol: enabled
'''),
      );
      expect(checkPatrolSection(ctx)?.severity, Severity.error);
      expect(checkPatrolDependency(ctx), isNull);
    });

    test('non-string test_directory falls back to the default', () {
      final ctx = contextWith(
        mutate: () => fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: example_app
dev_dependencies:
  patrol: ^4.0.0
patrol:
  app_name: My App
  test_directory: 123
'''),
      );
      expect(ctx.testDirectory, 'patrol_test');
      expect(checkTestDirectory(ctx), isNull);
    });

    test('scalar YAML root does not crash', () {
      final ctx = contextWith(
        mutate: () =>
            fs.file('/project/pubspec.yaml').writeAsStringSync('just a string'),
      );
      expect(checkPatrolDependency(ctx)?.severity, Severity.error);
    });

    test('empty patrol section warns about missing app_name', () {
      final ctx = contextWith(
        mutate: () => fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: example_app
dev_dependencies:
  patrol: ^4.0.0
patrol: {}
'''),
      );
      expect(checkPatrolSection(ctx), isNull);
      expect(checkAppName(ctx)?.severity, Severity.warning);
    });
  });

  group('S3 stray patrol.yaml', () {
    test('warns when patrol.yaml exists', () {
      final ctx = contextWith(
        mutate: () => fs.file('/project/patrol.yaml').createSync(),
      );
      final finding = checkStrayPatrolYaml(ctx);
      expect(finding?.severity, Severity.warning);
      expect(finding?.summary, contains('does not read'));
    });
  });

  group('S4 test directory', () {
    test('errors when the test directory does not exist', () {
      final ctx = contextWith(
        mutate: () =>
            fs.directory('/project/patrol_test').deleteSync(recursive: true),
      );
      final finding = checkTestDirectory(ctx);
      expect(finding?.severity, Severity.error);
      expect(finding?.summary, contains('does not exist'));
    });

    test('errors when the test directory has no test files', () {
      final ctx = contextWith(
        mutate: () =>
            fs.file('/project/patrol_test/example_test.dart').deleteSync(),
      );
      final finding = checkTestDirectory(ctx);
      expect(finding?.severity, Severity.error);
      expect(finding?.summary, contains('no'));
    });

    test('respects a custom test_directory and suffix', () {
      final ctx = contextWith(
        mutate: () {
          fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: example_app
dev_dependencies:
  patrol: ^4.0.0
patrol:
  app_name: My App
  test_directory: integration_test
  test_file_suffix: _patrol.dart
''');
          fs
              .file('/project/integration_test/login_patrol.dart')
              .createSync(recursive: true);
        },
      );
      expect(checkTestDirectory(ctx), isNull);
    });
  });

  group('S5 integration_test fallback', () {
    test('warns when tests are only in integration_test/', () {
      final ctx = contextWith(
        mutate: () {
          fs.file('/project/patrol_test/example_test.dart').deleteSync();
          fs
              .file('/project/integration_test/app_test.dart')
              .createSync(recursive: true);
        },
      );
      final finding = checkIntegrationTestDirectory(ctx);
      expect(finding?.severity, Severity.warning);
      expect(finding?.summary, contains('integration_test'));
    });

    test('does not warn when the configured directory has tests', () {
      final ctx = contextWith(
        mutate: () => fs
            .file('/project/integration_test/app_test.dart')
            .createSync(recursive: true),
      );
      expect(checkIntegrationTestDirectory(ctx), isNull);
    });
  });

  group('S6 test_bundle.dart gitignored', () {
    test('notices when .gitignore does not mention test_bundle.dart', () {
      final ctx = contextWith(
        mutate: () =>
            fs.file('/project/.gitignore').writeAsStringSync('build/\n'),
      );
      expect(checkTestBundleGitignored(ctx)?.severity, Severity.notice);
    });

    test('notices when .gitignore is missing', () {
      final ctx = contextWith(
        mutate: () => fs.file('/project/.gitignore').deleteSync(),
      );
      expect(checkTestBundleGitignored(ctx)?.severity, Severity.notice);
    });
  });

  group('pub workspace layout', () {
    SharedCheckContext workspaceContext() {
      final appRoot = fs.directory('/workspace/app')..createSync(recursive: true);
      fs.file('/workspace/app/pubspec.yaml').writeAsStringSync(
        _completePubspec,
      );
      fs.file('/workspace/pubspec.lock').writeAsStringSync(_compatibleLock);
      fs.file('/workspace/.gitignore').writeAsStringSync(
        'app/patrol_test/test_bundle.dart\n',
      );
      fs
          .file('/workspace/app/patrol_test/example_test.dart')
          .createSync(recursive: true);
      return SharedCheckContext(probe: ProjectProbe(projectRoot: appRoot));
    }

    test('S6 finds the pattern in an ancestor .gitignore', () {
      expect(checkTestBundleGitignored(workspaceContext()), isNull);
    });

    test('S7 finds pubspec.lock at the workspace root', () {
      expect(
        checkVersionCompatibility(workspaceContext(), cliVersion: '4.4.0'),
        isNull,
      );
    });
  });

  group('S7 version compatibility', () {
    test('errors on an incompatible patrol version', () {
      final ctx = contextWith(
        mutate: () => fs.file('/project/pubspec.lock').writeAsStringSync('''
packages:
  patrol:
    version: "2.0.0"
'''),
      );
      final finding = checkVersionCompatibility(ctx, cliVersion: '4.4.0');
      expect(finding?.severity, Severity.error);
      expect(finding?.summary, contains('not compatible'));
    });

    test('notices when pubspec.lock is missing', () {
      final ctx = contextWith(
        mutate: () => fs.file('/project/pubspec.lock').deleteSync(),
      );
      final finding = checkVersionCompatibility(ctx, cliVersion: '4.4.0');
      expect(finding?.severity, Severity.notice);
    });

    test('is silent when patrol is not declared (S1 covers it)', () {
      final ctx = contextWith(
        mutate: () => fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: example_app
dependencies:
  flutter:
    sdk: flutter
'''),
      );
      expect(checkVersionCompatibility(ctx, cliVersion: '4.4.0'), isNull);
    });
  });
}
