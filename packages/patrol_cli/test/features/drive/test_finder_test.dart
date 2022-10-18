import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:patrol_cli/src/features/drive/test_finder.dart';
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

  test(
    'throws FileSystemException when integration_test directory does not exist',
    () {
      expect(testFinder.findAllTests, throwsA(isA<FileSystemException>()));
    },
  );

  test('finds tests that are directly in the directory', () {
    fs.file('integration_test/app_test.dart').createSync(recursive: true);
    fs.file('integration_test/permission_test.dart').createSync();

    expect(
      testFinder.findAllTests(),
      equals([
        '${wd.path}/integration_test/app_test.dart',
        '${wd.path}/integration_test/permission_test.dart'
      ]),
    );
  });

  test('finds tests recursively', () {
    fs.file('integration_test/app_test.dart').createSync(recursive: true);
    fs.file('integration_test/permission_test.dart').createSync();
    fs.file('integration_test/webview_test.dart').createSync();
    fs
        .file('integration_test/auth/sign_in_test.dart')
        .createSync(recursive: true);

    expect(
      testFinder.findAllTests(),
      equals([
        '${wd.path}/integration_test/app_test.dart',
        '${wd.path}/integration_test/permission_test.dart',
        '${wd.path}/integration_test/webview_test.dart',
        '${wd.path}/integration_test/auth/sign_in_test.dart',
      ]),
    );
  });
}
