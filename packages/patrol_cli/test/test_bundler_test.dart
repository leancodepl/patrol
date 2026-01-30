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

  final projectRootDir = fs.directory(
    fs.path.join(platform.home, 'awesome_app'),
  )..createSync();
  fs.currentDirectory = projectRootDir;
  fs.directory('patrol_test').createSync();
  return projectRootDir;
}

void main() {
  _test(initFakePlatform(Platform.macOS));
  _test(initFakePlatform(Platform.windows));
}

void _test(Platform platform) {
  const testDirectory = 'patrol_test';

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
        () => testBundler.createTestBundle(testDirectory, [], null, null),
        throwsArgumentError,
      );
    });

    test('generates imports from relative paths', () {
      // given
      final tests = [
        fs.path.join('patrol_test', 'example_test.dart'),
        fs.path.join('patrol_test', 'example', 'example_test.dart'),
      ];

      // when
      final imports = testBundler.generateImports(testDirectory, tests);

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
          'patrol_test',
          'example_test.dart',
        ),
        fs.path.join(
          platform.home,
          'awesome_app',
          'patrol_test',
          'example/example_test.dart',
        ),
      ];

      // when
      final imports = testBundler.generateImports(testDirectory, tests);

      /// then
      expect(imports, '''
import 'example_test.dart' as example_test;
import 'example/example_test.dart' as example__example_test;''');
    });

    test('generates groups from relative paths', () {
      // given
      final tests = [
        fs.path.join('patrol_test', 'example_test.dart'),
        fs.path.join('patrol_test', 'example/example_test.dart'),
      ];

      // when
      final groupsCode = testBundler.generateGroupsCode(testDirectory, tests);

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
          'patrol_test',
          'example_test.dart',
        ),
        fs.path.join(
          platform.home,
          'awesome_app',
          'patrol_test',
          'example/example_test.dart',
        ),
      ];

      // when
      final groupsCode = testBundler.generateGroupsCode(testDirectory, tests);

      /// then
      expect(groupsCode, '''
group('example_test', example_test.main);
group('example.example_test', example__example_test.main);''');
    });

    test('uses correct test directory', () {
      // given
      final defaultTestBundler = TestBundler(
        projectRoot: fs.directory(fs.path.join(platform.home, 'awesome_app')),
        logger: MockLogger(),
      );

      // when
      final bundledTestFilePath = defaultTestBundler.getBundledTestFile(
        testDirectory,
      );

      // then
      expect(
        bundledTestFilePath.path,
        contains('$testDirectory${fs.path.separator}test_bundle.dart'),
      );
    });

    test('uses project root for web test bundle', () {
      // given
      final defaultTestBundler = TestBundler(
        projectRoot: fs.directory(fs.path.join(platform.home, 'awesome_app')),
        logger: MockLogger(),
      );

      // when
      final bundledTestFilePath = defaultTestBundler.getBundledTestFile(
        testDirectory,
        web: true,
      );

      // then
      expect(bundledTestFilePath.path, endsWith('test_bundle.dart'));
      expect(
        bundledTestFilePath.path,
        isNot(contains('$testDirectory${fs.path.separator}test_bundle.dart')),
      );
    });

    test('generates web imports with test directory prefix', () {
      // given
      final tests = [
        fs.path.join('patrol_test', 'web', 'my_test.dart'),
        fs.path.join('patrol_test', 'example', 'example_test.dart'),
      ];

      // when
      final imports = testBundler.generateImports(
        testDirectory,
        tests,
        web: true,
      );

      /// then
      expect(imports, '''
import 'patrol_test/web/my_test.dart' as web__my_test;
import 'patrol_test/example/example_test.dart' as example__example_test;''');
    });

    test('generates web groups with test directory prefix', () {
      // given
      final tests = [
        fs.path.join('patrol_test', 'web', 'my_test.dart'),
        fs.path.join('patrol_test', 'example', 'example_test.dart'),
      ];

      // when
      final groupsCode = testBundler.generateGroupsCode(
        testDirectory,
        tests,
        web: true,
      );

      /// then
      expect(groupsCode, '''
group('patrol_test.web.my_test', web__my_test.main);
group('patrol_test.example.example_test', example__example_test.main);''');
    });
  });
}
