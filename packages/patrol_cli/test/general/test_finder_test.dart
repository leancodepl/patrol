import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/extensions/platform.dart';
import 'package:patrol_cli/src/test_finder.dart';
import 'package:platform/platform.dart';
import 'package:test/test.dart';

import '../src/common.dart';

void main() {
  _test(initFakePlatform(Platform.macOS));
  _test(initFakePlatform(Platform.windows));
}

void _test(Platform platform) {
  late FileSystem fs;
  late TestFinder testFinder;

  setUp(() {
    fs = MemoryFileSystem.test(style: platform.fileSystemStyle);
    final projectRoot = fs.directory(fs.path.join('projects', 'awesome_app'))
      ..createSync(recursive: true);
    fs.currentDirectory = projectRoot;

    testFinder = TestFinder(testDir: fs.directory('integration_test'));
  });

  group('findTests', () {
    test('throws exception when target file does not exist', () {
      expect(
        () => testFinder.findTests(['integration_test/app_test.dart']),
        throwsA(
          isA<ToolExit>().having(
            (exception) => exception.message,
            'message',
            equals(
              'target file integration_test/app_test.dart does not exist',
            ),
          ),
        ),
      );
    });

    test('throws exception when target directory does not exist', () {
      expect(
        () => testFinder.findTests(['integration_test/features/login']),
        throwsA(
          isA<ToolExit>().having(
            (exception) => exception.message,
            'message',
            equals(
              'target integration_test/features/login is invalid',
            ),
          ),
        ),
      );
    });

    test(
      'throws exception when target directory does not contain any tests',
      () {
        const target = 'integration_test/features/login';
        fs.directory(target).createSync(recursive: true);

        expect(
          () => testFinder.findTests([target]),
          throwsA(
            isA<ToolExit>().having(
              (exception) => exception.message,
              'message',
              equals(
                'target directory $target does not contain any tests',
              ),
            ),
          ),
        );
      },
    );

    test('finds test when target is a file', () {
      // given
      final target = fs.path.join('integration_test', 'app_test.dart');
      fs.file(target).createSync(recursive: true);

      // when
      final found = testFinder.findTests([target]);

      // then
      expect(found, equals([fs.path.join(fs.currentDirectory.path, target)]));
    });

    test('finds tests when target is a directory', () {
      // given
      final dir = fs
          .directory(fs.path.join('integration_test', 'features', 'auth'))
        ..createSync(recursive: true);
      dir.childFile('login_test.dart').createSync();
      dir.childFile('register_test.dart').createSync();
      fs
          .directory(fs.path.join('integration_test', 'another_test.dart'))
          .createSync();

      // when
      final path = fs.path.join('integration_test', 'features', 'auth');
      final found = testFinder.findTests([path]);

      // then
      expect(
        found,
        equals([
          fs.path.join(fs.currentDirectory.path, path, 'login_test.dart'),
          fs.path.join(fs.currentDirectory.path, path, 'register_test.dart'),
        ]),
      );
    });

    test(
      'finds tests when target is a directory containing another directory',
      () {
        // given
        final dir = fs
            .directory(fs.path.join('integration_test', 'features', 'auth'))
          ..createSync(recursive: true);
        dir.childFile('login_test.dart').createSync();
        dir.childFile('register_test.dart').createSync();
        fs
            .directory(fs.path.join('integration_test', 'another_test.dart'))
            .createSync();

        // when
        final path = fs.path.join('integration_test', 'features');
        final found = testFinder.findTests([path]);

        // then
        final wd = fs.currentDirectory.path;
        expect(
          found,
          equals([
            fs.path.join(wd, path, 'auth', 'login_test.dart'),
            fs.path.join(wd, path, 'auth', 'register_test.dart'),
          ]),
        );
      },
    );

    test('finds tests recursively when target is a directory', () {
      // given
      final dir = fs.directory(fs.path.join('integration_test', 'auth'))
        ..createSync(recursive: true);
      dir.childFile('login_test.dart').createSync();
      dir.childFile('register_test.dart').createSync();
      fs
          .directory(fs.path.join('integration_test', 'another_test.dart'))
          .createSync();

      // when+then
      final wd = fs.currentDirectory.absolute.path;
      expect(
        testFinder.findTests([fs.path.join('integration_test', 'auth')]),
        equals([
          fs.path.join(wd, 'integration_test', 'auth', 'login_test.dart'),
          fs.path.join(wd, 'integration_test', 'auth', 'register_test.dart'),
        ]),
      );

      expect(
        testFinder.findTests(
          [fs.path.join('integration_test', 'auth${fs.path.separator}')],
        ),
        equals([
          fs.path.join(wd, 'integration_test', 'auth', 'login_test.dart'),
          fs.path.join(wd, 'integration_test', 'auth', 'register_test.dart'),
        ]),
        reason: 'trailing path separator',
      );
    });

    test('finds tests when targets are files and directories', () {
      // given
      final testRoot = fs.directory('integration_test')..createSync();
      testRoot.file('app_test.dart').createSync();
      testRoot.file('other_test.dart').createSync();
      testRoot.dir('auth').createSync();
      testRoot.dir('auth').file('login_test.dart').createSync();
      testRoot.dir('auth').file('register_test.dart').createSync();

      // when
      final found = testFinder.findTests([
        fs.path.join('integration_test', 'app_test.dart'),
        fs.path.join('integration_test', 'auth'),
      ]);

      // then
      expect(
        found,
        equals([
          fs.path.join(testRoot.absolute.path, 'app_test.dart'),
          fs.path.join(testRoot.absolute.path, 'auth', 'login_test.dart'),
          fs.path.join(testRoot.absolute.path, 'auth', 'register_test.dart'),
        ]),
      );
    });
  });

  group('findAllTests', () {
    test(
      'throws ToolExit when integration_test directory does not exist',
      () {
        expect(testFinder.findAllTests, throwsToolExit);
      },
    );

    test('finds all tests when no target is specified', () {
      // given
      final dir = fs.directory('integration_test')..createSync();
      dir.childFile('app_test.dart').createSync();
      dir.childFile('permission_test.dart').createSync();

      // when
      final found = testFinder.findAllTests();

      // then
      final wd = fs.currentDirectory.path;
      expect(
        found,
        equals(
          [
            fs.path.join(wd, 'integration_test', 'app_test.dart'),
            fs.path.join(wd, 'integration_test', 'permission_test.dart'),
          ],
        ),
      );
    });

    test('finds tests recursively in the correct order', () {
      final files = [
        fs.path.join('integration_test', 'alpha', 'alpha_test.dart'),
        fs.path.join('integration_test', 'alpha', 'bravo_test.dart'),
        fs.path.join('integration_test', 'alpha_test.dart'),
        fs.path.join('integration_test', 'bravo', 'bravo_test.dart'),
        fs.path.join('integration_test', 'charlie', 'charlie_test.dart'),
        fs.path.join('integration_test', 'zulu_test.dart'),
      ];
      for (final file in files) {
        fs.file(file).createSync(recursive: true);
      }

      expect(
        testFinder.findAllTests(),
        equals(
          files.map((file) => fs.path.join(fs.currentDirectory.path, file)),
        ),
      );
    });

    test('filters out excluded tests', () {
      // given
      final files = [
        fs.path.join('integration_test', 'alpha', 'alpha_test.dart'),
        fs.path.join('integration_test', 'alpha', 'bravo_test.dart'),
        fs.path.join('integration_test', 'alpha_test.dart'),
        fs.path.join('integration_test', 'bravo', 'bravo_test.dart'),
        fs.path.join('integration_test', 'charlie', 'charlie_test.dart'),
        fs.path.join('integration_test', 'zulu_test.dart'),
      ];
      for (final file in files) {
        fs.file(file).createSync(recursive: true);
      }

      // when
      final found = testFinder.findAllTests(
        excludes: {
          'other_test.dart', // ignore invalid targets
          fs.path.join('integration_test', 'alpha_test.dart'),
          fs.path.join('integration_test', 'alpha', 'alpha_test.dart'),
        },
      );

      // then
      final wd = fs.currentDirectory.absolute.path;
      final testRoot = fs.path.join(wd, 'integration_test');
      expect(
        found,
        equals([
          fs.path.join(testRoot, 'alpha', 'bravo_test.dart'),
          fs.path.join(testRoot, 'bravo', 'bravo_test.dart'),
          fs.path.join(testRoot, 'charlie', 'charlie_test.dart'),
          fs.path.join(testRoot, 'zulu_test.dart'),
        ]),
      );
    });
  });
}
