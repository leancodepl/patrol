import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:patrol_cli/src/test_bundler.dart';
import 'package:test/test.dart';

Directory _initTestFs(FileSystem fs) {
  final wd = fs.directory('/Users/charlie/awesome_app')
    ..createSync(recursive: true);
  fs.currentDirectory = wd;
  fs.directory('integration_test').createSync();
  return wd;
}

void main() {
  group('TestBundler', () {
    late FileSystem fs;
    late TestBundler testBundler;

    setUp(() {
      fs = MemoryFileSystem.test();
      final projectRootDir = _initTestFs(fs);
      testBundler = TestBundler(projectRoot: projectRootDir);
    });

    test('throws ArgumentError when no tests are given', () {
      expect(() => testBundler.createBundledTest([]), throwsArgumentError);
    });

    test('generates imports from relative paths', () {
      // given
      final tests = [
        'integration_test/example_test.dart',
        'integration_test/example/example_test.dart',
      ];

      // when
      final imports = testBundler.generateImports(tests);

      /// then
      expect(imports, '''
import 'example_test.dart' as example_test;
import 'example/example_test.dart' as example__example_test;
''');
    });

    test('generates imports from absolute paths', () {
      // given
      final tests = [
        '/Users/charlie/awesome_app/integration_test/example_test.dart',
        '/Users/charlie/awesome_app/integration_test/example/example_test.dart',
      ];

      // when
      final imports = testBundler.generateImports(tests);

      /// then
      expect(imports, '''
import 'example_test.dart' as example_test;
import 'example/example_test.dart' as example__example_test;
''');
    });

//     test('generates groups code', () {
//       // given
//       final tests = [
//         'example_test.dart',
//         'login_test.dart',
//         'permissions/permissions_location_test.dart'
//       ];

//       final testFilePaths = tests.map((fileName) {
//         final file = fs.directory('integration_test').childFile(fileName)
//           ..createSync(recursive: true);

//         return file.path;
//       }).toList();

//       // when
//       final groupsCode = testBundler.generateGroupsCode(testFilePaths);

//       /// then
//       expect(groupsCode, '''
// group('example_test', example_test.main);
// group('login_test', login_test.main);
// group('permissions.permissions_location_test.dart);
// ''');
//     });
  });
}
