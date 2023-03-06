import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:path/path.dart' show join;
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/features/run_commons/test_finder.dart';
import 'package:test/test.dart';

import '../../common.dart';

void main() {
  late FileSystem fs;
  late TestFinder testFinder;
  late Directory wd;

  setUp(() {
    fs = MemoryFileSystem.test();
    wd = fs.directory('/projects/awesome_app')..createSync(recursive: true);
    fs.currentDirectory = wd;

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

    test('finds test when target is file', () {
      const target = 'integration_test/app_test.dart';
      fs.file(target).createSync(recursive: true);

      expect(
        testFinder.findTests([target]),
        equals([join(wd.path, target)]),
      );
    });

    test('finds tests when target is a directory', () {
      final files = [
        'integration_test/features/login/existing_user_test.dart',
        'integration_test/features/login/new_user_test.dart',
      ];
      for (final file in files) {
        fs.file(file).createSync(recursive: true);
      }

      expect(
        testFinder.findTests(['integration_test/features/login']),
        equals(files.map((file) => join(wd.path, file))),
      );
    });

    test(
      'finds tests when target is a directory containing no direct test files',
      () {
        final files = [
          'integration_test/features/login/existing_user_test.dart',
          'integration_test/features/login/new_user_test.dart',
        ];
        for (final file in files) {
          fs.file(file).createSync(recursive: true);
        }

        expect(
          testFinder.findTests(['integration_test/features']),
          equals(files.map((file) => join(wd.path, file))),
        );
      },
    );

    test('finds tests recursively when target is a directory', () {
      final files = [
        'integration_test/features/login/existing_user_test.dart',
        'integration_test/features/login/new_user_test.dart',
        'integration_test/features/some_test.dart',
      ];
      for (final file in files) {
        fs.file(file).createSync(recursive: true);
      }

      expect(
        testFinder.findTests(['integration_test/features']),
        equals(files.map((file) => join(wd.path, file))),
      );

      expect(
        testFinder.findTests(['integration_test/features/']),
        equals(files.map((file) => join(wd.path, file))),
        reason: 'trailing slash',
      );
    });

    test('finds tests when targets are files and directories', () {
      final files = [
        'integration_test/app_test.dart',
        'integration_test/features/login/existing_user_test.dart',
        'integration_test/features/login/new_user_test.dart',
      ];
      for (final file in files) {
        fs.file(file).createSync(recursive: true);
      }

      expect(
        testFinder.findTests([
          'integration_test/app_test.dart',
          'integration_test/features/login',
        ]),
        equals(files.map((file) => join(wd.path, file))),
      );

      expect(
        testFinder.findTests([
          'integration_test/app_test.dart',
          'integration_test/features/login/',
        ]),
        equals(files.map((file) => join(wd.path, file))),
        reason: 'trailing slash',
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

    test('finds tests that are directly in the directory', () {
      final files = [
        'integration_test/app_test.dart',
        'integration_test/permission_test.dart',
      ];
      for (final file in files) {
        fs.file(file).createSync(recursive: true);
      }

      expect(
        testFinder.findAllTests(),
        equals(files.map((file) => join(wd.path, file))),
      );
    });

    test('finds tests recursively in the correct order', () {
      final files = [
        'integration_test/alpha/alpha_test.dart',
        'integration_test/alpha/bravo_test.dart',
        'integration_test/alpha_test.dart',
        'integration_test/bravo/bravo_test.dart',
        'integration_test/charlie/charlie_test.dart',
        'integration_test/zulu_test.dart',
      ];
      for (final file in files) {
        fs.file(file).createSync(recursive: true);
      }

      expect(
        testFinder.findAllTests(),
        equals(files.map((file) => join(wd.path, file))),
      );
    });
  });
}
