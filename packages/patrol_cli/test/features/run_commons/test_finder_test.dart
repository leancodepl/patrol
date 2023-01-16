import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:path/path.dart' show join;
import 'package:patrol_cli/src/common/tool_exit.dart';
import 'package:patrol_cli/src/features/run_commons/test_finder.dart';
import 'package:test/test.dart';

void main() {
  late FileSystem fs;
  late TestFinder testFinder;
  late Directory wd;

  setUp(() {
    fs = MemoryFileSystem.test();
    wd = fs.directory('/projects/awesome_app')..createSync(recursive: true);
    fs.currentDirectory = wd;

    testFinder = TestFinder(
      integrationTestDir: fs.directory('integration_test'),
      fs: fs,
    );
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
        'integration_test/features/login/new_user_test.dart',
        'integration_test/features/login/existing_user_test.dart'
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
          'integration_test/features/login/new_user_test.dart',
          'integration_test/features/login/existing_user_test.dart'
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
        'integration_test/features/some_test.dart',
        'integration_test/features/login/new_user_test.dart',
        'integration_test/features/login/existing_user_test.dart'
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
        'integration_test/features/login/new_user_test.dart',
        'integration_test/features/login/existing_user_test.dart',
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
      'throws FileSystemException when integration_test directory does not exist',
      () {
        expect(testFinder.findAllTests, throwsA(isA<FileSystemException>()));
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

    test('finds tests recursively', () {
      final files = [
        'integration_test/app_test.dart',
        'integration_test/permission_test.dart',
        'integration_test/auth/sign_in_test.dart'
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
