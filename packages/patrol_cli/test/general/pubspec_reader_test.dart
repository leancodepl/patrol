import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:patrol_cli/src/base/extensions/platform.dart';
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:platform/platform.dart';
import 'package:test/test.dart';

import '../src/common.dart';

const _pubspecBase = '''
name: example
description: A new Flutter project.
publish_to: none
version: 1.0.0+1
''';

void main() {
  _test(initFakePlatform(Platform.macOS));
  _test(initFakePlatform(Platform.windows));
}

void _test(Platform platform) {
  group('PubspecReader', () {
    late PubspecReader reader;
    late FileSystem fs;

    setUp(() {
      fs = MemoryFileSystem.test(style: platform.fileSystemStyle);
      final wd = fs.directory(fs.path.join('projects', 'awesome_app'))
        ..createSync(recursive: true);
      fs.currentDirectory = wd;

      reader = PubspecReader(projectRoot: fs.currentDirectory);
    });

    group('read()', () {
      test('returns empty config when `patrol` block does not exist', () {
        fs.file('pubspec.yaml').writeAsStringSync(_pubspecBase);

        expect(
          reader.read(),
          equals(PatrolPubspecConfig.empty(flutterPackageName: 'example')),
        );
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

      test('reads `android` block', () {
        fs.file('pubspec.yaml').writeAsStringSync('''
$_pubspecBase
patrol:
  android:
    app_name: Example
    package_name: com.example.app
''');

        expect(reader.read().android.appName, equals('Example'));
        expect(reader.read().android.packageName, equals('com.example.app'));
      });

      test('reads `ios` block', () {
        fs.file('pubspec.yaml').writeAsStringSync('''
$_pubspecBase
patrol:
  ios:
    app_name: The Example
    bundle_id: com.example.ExampleApp
''');

        expect(reader.read().ios.appName, equals('The Example'));
        expect(reader.read().ios.bundleId, equals('com.example.ExampleApp'));
      });

      test('overrides global values with platform-specific ones', () {
        fs.file('pubspec.yaml').writeAsStringSync('''
$_pubspecBase
patrol:
  app_name: Example
  flavor: dev
  android:
    package_name: com.example.app
    flavor: devAndroid
  ios:
    app_name: The Example
    bundle_id: com.example.ExampleApp
    flavor: devApple
''');

        expect(reader.read().android.appName, equals('Example'));
        expect(reader.read().android.packageName, equals('com.example.app'));
        expect(reader.read().android.flavor, equals('devAndroid'));
        expect(reader.read().ios.appName, equals('The Example'));
        expect(reader.read().ios.bundleId, equals('com.example.ExampleApp'));
        expect(reader.read().ios.flavor, equals('devApple'));
      });
    });
  });
}
