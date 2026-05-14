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
}
