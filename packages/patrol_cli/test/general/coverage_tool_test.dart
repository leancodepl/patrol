import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:patrol_cli/src/base/extensions/platform.dart';
import 'package:patrol_cli/src/coverage/coverage_tool.dart';
import 'package:platform/platform.dart';
import 'package:test/test.dart';

import '../src/common.dart';

void main() {
  _test(initFakePlatform(Platform.macOS));
  _test(initFakePlatform(Platform.windows));
}

void _test(Platform platform) {
  group('findPackageConfigFile on ${platform.operatingSystem}', () {
    late FileSystem fs;

    setUp(() {
      fs = MemoryFileSystem.test(style: platform.fileSystemStyle);
    });

    test('finds package_config.json in the project directory', () {
      final projectDir = fs.directory(fs.path.join('projects', 'app'))
        ..createSync(recursive: true);
      projectDir
          .childDirectory('.dart_tool')
          .childFile('package_config.json')
          .createSync(recursive: true);

      final result = findPackageConfigFile(projectDir);

      expect(result, isNotNull);
      expect(
        result!.path,
        projectDir
            .childDirectory('.dart_tool')
            .childFile('package_config.json')
            .path,
      );
    });

    test(
      'walks up to a workspace root when package_config.json is not local '
      '(regression test for https://github.com/leancodepl/patrol/issues/2844)',
      () {
        final workspaceRoot = fs.directory(fs.path.join('projects', 'monorepo'))
          ..createSync(recursive: true);
        final workspaceConfig =
            workspaceRoot
                .childDirectory('.dart_tool')
                .childFile('package_config.json')
              ..createSync(recursive: true);
        final memberApp = workspaceRoot.childDirectory('app')..createSync();

        final result = findPackageConfigFile(memberApp);

        expect(result, isNotNull);
        expect(result!.path, workspaceConfig.path);
      },
    );

    test('returns null when no package_config.json is found', () {
      final projectDir = fs.directory(fs.path.join('projects', 'app'))
        ..createSync(recursive: true);

      expect(findPackageConfigFile(projectDir), isNull);
    });

    test('prefers the closest package_config.json over a parent one', () {
      final workspaceRoot = fs.directory(fs.path.join('projects', 'monorepo'))
        ..createSync(recursive: true);
      workspaceRoot
          .childDirectory('.dart_tool')
          .childFile('package_config.json')
          .createSync(recursive: true);

      final memberApp = workspaceRoot.childDirectory('app')..createSync();
      final memberConfig =
          memberApp
              .childDirectory('.dart_tool')
              .childFile('package_config.json')
            ..createSync(recursive: true);

      final result = findPackageConfigFile(memberApp);

      expect(result, isNotNull);
      expect(result!.path, memberConfig.path);
    });
  });

  group('findWorkspaceMemberPackages on ${platform.operatingSystem}', () {
    late FileSystem fs;
    late Directory workspaceRoot;

    setUp(() {
      fs = MemoryFileSystem.test(style: platform.fileSystemStyle);
      workspaceRoot = fs.directory(fs.path.join('projects', 'monorepo'))
        ..createSync(recursive: true);
    });

    void writeMember(String posixPath, String name) {
      var dir = workspaceRoot;
      for (final segment in posixPath.split('/')) {
        if (segment.isEmpty) {
          continue;
        }
        dir = dir.childDirectory(segment);
      }
      dir.createSync(recursive: true);
      dir.childFile('pubspec.yaml').writeAsStringSync('name: $name\n');
    }

    test('reads every name declared under workspace:', () {
      workspaceRoot.childFile('pubspec.yaml').writeAsStringSync('''
name: _
publish_to: none
workspace:
  - app/
  - packages/feature1
  - packages/shared_ui
''');
      writeMember('app', 'my_app');
      writeMember('packages/feature1', 'feature1');
      writeMember('packages/shared_ui', 'shared_ui');

      expect(findWorkspaceMemberPackages(workspaceRoot), {
        'my_app',
        'feature1',
        'shared_ui',
      });
    });

    test('returns empty when pubspec.yaml is missing', () {
      expect(findWorkspaceMemberPackages(workspaceRoot), isEmpty);
    });

    test('returns empty when workspace: key is absent', () {
      workspaceRoot
          .childFile('pubspec.yaml')
          .writeAsStringSync('name: standalone_app\n');

      expect(findWorkspaceMemberPackages(workspaceRoot), isEmpty);
    });

    test('skips entries whose pubspec.yaml is missing', () {
      workspaceRoot.childFile('pubspec.yaml').writeAsStringSync('''
name: _
workspace:
  - app/
  - packages/ghost
''');
      writeMember('app', 'my_app');

      expect(findWorkspaceMemberPackages(workspaceRoot), {'my_app'});
    });

    test('returns empty when root pubspec.yaml is malformed', () {
      workspaceRoot.childFile('pubspec.yaml').writeAsStringSync('''
name: _
workspace:
  - "unterminated string
''');

      expect(findWorkspaceMemberPackages(workspaceRoot), isEmpty);
    });

    test('skips members whose pubspec.yaml is malformed', () {
      workspaceRoot.childFile('pubspec.yaml').writeAsStringSync('''
name: _
workspace:
  - app/
  - packages/broken
''');
      writeMember('app', 'my_app');
      workspaceRoot
          .childDirectory('packages')
          .childDirectory('broken')
          .childFile('pubspec.yaml')
        ..createSync(recursive: true)
        ..writeAsStringSync('name: : oops\n  bad indent: [');

      expect(findWorkspaceMemberPackages(workspaceRoot), {'my_app'});
    });

    test('tolerates non-string workspace entries', () {
      workspaceRoot.childFile('pubspec.yaml').writeAsStringSync('''
name: _
workspace:
  - app/
  - 42
  - null
''');
      writeMember('app', 'my_app');

      expect(findWorkspaceMemberPackages(workspaceRoot), {'my_app'});
    });
  });
}
