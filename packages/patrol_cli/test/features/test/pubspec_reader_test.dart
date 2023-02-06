import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:patrol_cli/src/features/test/pubspec_reader.dart';
import 'package:test/test.dart';

const _pubspecBase = '''
name: example
description: A new Flutter project.
publish_to: none
version: 1.0.0+1
''';

Directory _initTestFs() {
  final fs = MemoryFileSystem.test();
  final wd = fs.directory('/projects/awesome_app')..createSync(recursive: true);
  fs.currentDirectory = wd;
  return wd;
}

void main() {
  group('PubspecReader', () {
    late PubspecReader reader;
    late FileSystem fs;

    setUp(() {
      final projectRoot = _initTestFs();
      fs = projectRoot.fileSystem;

      reader = PubspecReader(projectRoot: projectRoot);
    });

    group('read()', () {
      test('returns empty config when `patrol` block does not exist', () {
        fs.file('pubspec.yaml').writeAsStringSync(_pubspecBase);

        expect(reader.read(), equals(PatrolPubspecConfig.empty()));
      });

      test('reads top-level arguments', () {
        fs.file('pubspec.yaml').writeAsStringSync('''
$_pubspecBase
patrol:
  app_name: Example
  flavor: dev
''');

        expect(reader.read().android.appName, equals('Example'));
        expect(reader.read().ios.appName, equals('Example'));
        expect(reader.read().android.flavor, equals('dev'));
        expect(reader.read().ios.flavor, equals('dev'));
      });
    });
  });
}
