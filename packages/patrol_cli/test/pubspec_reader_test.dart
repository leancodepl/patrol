import 'package:file/memory.dart';
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:test/test.dart';

void main() {
  late PubspecReader reader;
  late MemoryFileSystem fs;

  setUp(() {
    fs = MemoryFileSystem();
    final projectRoot = fs.directory('/project')..createSync();
    reader = PubspecReader(projectRoot: projectRoot);
  });

  group('getPatrolVersion', () {
    test('returns null when pubspec.yaml does not exist', () {
      expect(reader.getPatrolVersion(), isNull);
    });

    test('returns null when dependencies section is missing', () {
      fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: test_project
''');
      expect(reader.getPatrolVersion(), isNull);
    });

    test('returns null when patrol dependency is missing', () {
      fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: test_project
dependencies:
  flutter:
    sdk: flutter
''');
      expect(reader.getPatrolVersion(), isNull);
    });

    test('handles direct version string with caret', () {
      fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: test_project
dependencies:
  patrol: ^3.15.0
''');
      expect(reader.getPatrolVersion(), equals('3.15.0'));
    });

    test('handles direct version string with tilde', () {
      fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: test_project
dependencies:
  patrol: ~3.15.0
''');
      expect(reader.getPatrolVersion(), equals('3.15.0'));
    });

    test('handles direct version string with dev version', () {
      fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: test_project
dependencies:
  patrol: 3.15.1-dev.1
''');
      expect(reader.getPatrolVersion(), equals('3.15.1-dev.1'));
    });

    test('handles direct version string with build number', () {
      fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: test_project
dependencies:
  patrol: 3.15.1+1
''');
      expect(reader.getPatrolVersion(), equals('3.15.1+1'));
    });

    test('handles hosted dependency with version', () {
      fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: test_project
dependencies:
  patrol:
    version: ^3.15.0
''');
      expect(reader.getPatrolVersion(), equals('3.15.0'));
    });

    test('handles git dependency with ref', () {
      fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: test_project
dependencies:
  patrol:
    git:
      url: https://github.com/leancodepl/patrol.git
      ref: 3.15.1
''');
      expect(reader.getPatrolVersion(), equals('3.15.1'));
    });

    test('handles git dependency with dev ref', () {
      fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: test_project
dependencies:
  patrol:
    git:
      url: https://github.com/leancodepl/patrol.git
      ref: 3.15.1-dev.1
''');
      expect(reader.getPatrolVersion(), equals('3.15.1-dev.1'));
    });

    test('handles git dependency with path', () {
      fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: test_project
dependencies:
  patrol:
    git:
      url: https://github.com/leancodepl/patrol.git
      path: packages/patrol
''');
      expect(reader.getPatrolVersion(), isNull);
    });

    test('handles git dependency with branch', () {
      fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: test_project
dependencies:
  patrol:
    git:
      url: https://github.com/leancodepl/patrol.git
      branch: main
''');
      expect(reader.getPatrolVersion(), isNull);
    });

    test('handles hosted dependency with any', () {
      fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: test_project
dependencies:
  patrol: any
''');
      expect(reader.getPatrolVersion(), equals('any'));
    });

    test('handles hosted dependency with empty version', () {
      fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: test_project
dependencies:
  patrol:
    version: ''
''');
      expect(reader.getPatrolVersion(), equals(''));
    });

    test('handles malformed yaml', () {
      fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: test_project
dependencies:
  patrol: invalid: yaml
''');
      expect(reader.getPatrolVersion(), isNull);
    });

    test('handles empty pubspec.yaml', () {
      fs.file('/project/pubspec.yaml').writeAsStringSync('');
      expect(reader.getPatrolVersion(), isNull);
    });

    test('handles patrol in dev_dependencies', () {
      fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: test_project
dev_dependencies:
  patrol: ^3.15.0
''');
      expect(reader.getPatrolVersion(), equals('3.15.0'));
    });

    test('handles patrol in both dependencies and dev_dependencies', () {
      fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: test_project
dependencies:
  patrol: ^3.14.0
dev_dependencies:
  patrol: ^3.15.0
''');
      expect(reader.getPatrolVersion(), equals('3.14.0'));
    });

    test('handles git dependency with commit hash', () {
      fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: test_project
dependencies:
  patrol:
    git:
      url: https://github.com/leancodepl/patrol.git
      ref: a1b2c3d4
''');
      expect(reader.getPatrolVersion(), equals('a1b2c3d4'));
    });

    test('handles path dependency', () {
      fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: test_project
dependencies:
  patrol:
    path: ../patrol
''');
      expect(reader.getPatrolVersion(), isNull);
    });

    test('handles hosted dependency with complex version constraint', () {
      fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: test_project
dependencies:
  patrol: ">=3.15.0 <4.0.0"
''');
      expect(reader.getPatrolVersion(), equals('>=3.15.0 <4.0.0'));
    });

    test('handles hosted dependency with exact version', () {
      fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: test_project
dependencies:
  patrol: "3.15.0"
''');
      expect(reader.getPatrolVersion(), equals('3.15.0'));
    });

    test('handles git dependency with tag', () {
      fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: test_project
dependencies:
  patrol:
    git:
      url: https://github.com/leancodepl/patrol.git
      ref: v3.15.0
''');
      expect(reader.getPatrolVersion(), equals('v3.15.0'));
    });

    test('handles hosted dependency with sdk constraint', () {
      fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: test_project
dependencies:
  patrol:
    sdk: ">=2.12.0 <3.0.0"
''');
      expect(reader.getPatrolVersion(), isNull);
    });

    test('handles non-string yaml values', () {
      fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: test_project
dependencies:
  patrol: 123
''');
      expect(reader.getPatrolVersion(), equals('123'));
    });
  });
}
