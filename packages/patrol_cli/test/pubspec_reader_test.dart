import 'package:file/memory.dart';
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:test/test.dart';

void main() {
  late PubspecReader reader;
  late MemoryFileSystem fs;

  setUp(() {
    fs = MemoryFileSystem();
    final projectRoot = fs.directory('/project');
    projectRoot.createSync();
    reader = PubspecReader(projectRoot: projectRoot);
  });

  group('getPatrolVersion', () {
    test('returns null when pubspec.yaml does not exist', () {
      expect(reader.getPatrolVersion(), isNull);
    });

    test('returns null when dependencies section is missing', () {
      final pubspec = fs.file('/project/pubspec.yaml');
      pubspec.writeAsStringSync('''
name: test_project
''');
      expect(reader.getPatrolVersion(), isNull);
    });

    test('returns null when patrol dependency is missing', () {
      final pubspec = fs.file('/project/pubspec.yaml');
      pubspec.writeAsStringSync('''
name: test_project
dependencies:
  flutter:
    sdk: flutter
''');
      expect(reader.getPatrolVersion(), isNull);
    });

    test('handles direct version string with caret', () {
      final pubspec = fs.file('/project/pubspec.yaml');
      pubspec.writeAsStringSync('''
name: test_project
dependencies:
  patrol: ^3.15.0
''');
      expect(reader.getPatrolVersion(), equals('3.15.0'));
    });

    test('handles direct version string with tilde', () {
      final pubspec = fs.file('/project/pubspec.yaml');
      pubspec.writeAsStringSync('''
name: test_project
dependencies:
  patrol: ~3.15.0
''');
      expect(reader.getPatrolVersion(), equals('3.15.0'));
    });

    test('handles direct version string with dev version', () {
      final pubspec = fs.file('/project/pubspec.yaml');
      pubspec.writeAsStringSync('''
name: test_project
dependencies:
  patrol: 3.15.1-dev.1
''');
      expect(reader.getPatrolVersion(), equals('3.15.1-dev.1'));
    });

    test('handles direct version string with build number', () {
      final pubspec = fs.file('/project/pubspec.yaml');
      pubspec.writeAsStringSync('''
name: test_project
dependencies:
  patrol: 3.15.1+1
''');
      expect(reader.getPatrolVersion(), equals('3.15.1+1'));
    });

    test('handles hosted dependency with version', () {
      final pubspec = fs.file('/project/pubspec.yaml');
      pubspec.writeAsStringSync('''
name: test_project
dependencies:
  patrol:
    version: ^3.15.0
''');
      expect(reader.getPatrolVersion(), equals('3.15.0'));
    });

    test('handles git dependency with ref', () {
      final pubspec = fs.file('/project/pubspec.yaml');
      pubspec.writeAsStringSync('''
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
      final pubspec = fs.file('/project/pubspec.yaml');
      pubspec.writeAsStringSync('''
name: test_project
dependencies:
  patrol:
    git:
      url: https://github.com/leancodepl/patrol.git
      ref: 3.15.1-dev.1
''');
      expect(reader.getPatrolVersion(), equals('3.15.1-dev.1'));
    });
  });
}
