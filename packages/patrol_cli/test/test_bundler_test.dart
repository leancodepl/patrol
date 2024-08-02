import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:patrol_cli/src/base/extensions/platform.dart';
import 'package:patrol_cli/src/test_bundler.dart';
import 'package:platform/platform.dart';
import 'package:test/test.dart';

import 'src/common.dart';
import 'src/mocks.dart';

Directory _initFakeFs(FileSystem fs, Platform platform) {
  // Create home directory
  fs.directory(fs.path.join(platform.home)).createSync(recursive: true);
  fs.currentDirectory = platform.home;

  final projectRootDir =
      fs.directory(fs.path.join(platform.home, 'awesome_app'))..createSync();
  fs.currentDirectory = projectRootDir;
  fs.directory('integration_test').createSync();
  return projectRootDir;
}

void main() {
  _test(initFakePlatform(Platform.macOS));
  _test(initFakePlatform(Platform.windows));
}

void _test(Platform platform) {
  group('(${platform.operatingSystem}) TestBundler', () {
    late FileSystem fs;
    late TestBundler testBundler;

    setUp(() {
      fs = MemoryFileSystem.test(style: platform.fileSystemStyle);
      final projectRootDir = _initFakeFs(fs, platform);
      testBundler = TestBundler(
        projectRoot: projectRootDir,
        logger: MockLogger(),
      );
    });

    test('throws ArgumentError when no tests are given', () {
      expect(
        () => testBundler.createTestBundle(
          [],
          null,
          null,
        ),
        throwsArgumentError,
      );
    });

    test('generates imports from relative paths', () {
      // given
      final tests = [
        fs.path.join('integration_test', 'example_test.dart'),
        fs.path.join('integration_test', 'example', 'example_test.dart'),
      ];

      // when
      final imports = testBundler.generateImports(tests);

      /// then
      expect(imports, '''
import 'example_test.dart' as example_test;
import 'example/example_test.dart' as example__example_test;''');
    });

    test('generates imports from absolute paths', () {
      // given
      final tests = [
        fs.path.join(
          platform.home,
          'awesome_app',
          'integration_test',
          'example_test.dart',
        ),
        fs.path.join(
          platform.home,
          'awesome_app',
          'integration_test',
          'example/example_test.dart',
        ),
      ];

      // when
      final imports = testBundler.generateImports(tests);

      /// then
      expect(imports, '''
import 'example_test.dart' as example_test;
import 'example/example_test.dart' as example__example_test;''');
    });

    test('generates groups from relative paths', () {
      // given
      final tests = [
        fs.path.join('integration_test', 'example_test.dart'),
        fs.path.join('integration_test', 'example/example_test.dart'),
      ];

      // when
      final groupsCode = testBundler.generateGroupsCode(tests);

      /// then
      expect(groupsCode, '''
group('example_test', example_test.main);
group('example.example_test', example__example_test.main);''');
    });

    test('generates groups from absolute paths', () {
      // given
      final tests = [
        fs.path.join(
          platform.home,
          'awesome_app',
          'integration_test',
          'example_test.dart',
        ),
        fs.path.join(
          platform.home,
          'awesome_app',
          'integration_test',
          'example/example_test.dart',
        ),
      ];

      // when
      final groupsCode = testBundler.generateGroupsCode(tests);

      /// then
      expect(groupsCode, '''
group('example_test', example_test.main);
group('example.example_test', example__example_test.main);''');
    });
  });
}
