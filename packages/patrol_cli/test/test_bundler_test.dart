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
    late TestBundler testBundler;

    setUp(() {
      final fs = MemoryFileSystem.test();
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

    test('generates groups from relative paths', () {
      // given
      final tests = [
        'integration_test/example_test.dart',
        'integration_test/example/example_test.dart',
      ];

      // when
      final groupsCode = testBundler.generateGroupsCode(tests);

      /// then
      expect(groupsCode, '''
group('example_test', example_test.main);
group('example.example_test', example__example_test.main);
''');
    });

    test('generates groups from absolute paths', () {
      // given
      final tests = [
        '/Users/charlie/awesome_app/integration_test/example_test.dart',
        '/Users/charlie/awesome_app/integration_test/example/example_test.dart',
      ];

      // when
      final groupsCode = testBundler.generateGroupsCode(tests);

      /// then
      expect(groupsCode, '''
group('example_test', example_test.main);
group('example.example_test', example__example_test.main);
''');
    });
  });
}
