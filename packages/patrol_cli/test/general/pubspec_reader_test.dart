import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:patrol_cli/src/base/extensions/platform.dart';
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:platform/testing.dart';
import 'package:test/test.dart';

import '../src/common.dart';

const _pubspecBase = '''
name: example
description: A new Flutter project.
publish_to: none
version: 1.0.0+1
''';

void main() {
  _test(initFakePlatform(NativePlatform.macOS));
  _test(initFakePlatform(NativePlatform.windows));
}

void _test(NativePlatform platform) {
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

      test('emit_test_manifest is null when unset', () {
        fs.file('pubspec.yaml').writeAsStringSync('''
$_pubspecBase
patrol:
  app_name: Example
''');

        expect(reader.read().emitTestManifest, isNull);
      });

      group('projectTestDirectory', () {
        String read(String testDirectory) {
          fs.file('pubspec.yaml').writeAsStringSync('''
$_pubspecBase
patrol:
  test_directory: $testDirectory
''');
          return reader.read().projectTestDirectory;
        }

        test('keeps a relative path', () {
          expect(read('patrol_test'), 'patrol_test');
        });

        test('makes an absolute path inside the project relative', () {
          final absolute = fs.path.join(
            fs.currentDirectory.path,
            'integration_test',
            'e2e',
          );

          expect(read(absolute), fs.path.join('integration_test', 'e2e'));
        });

        test('resolves .. back into the project', () {
          expect(
            read(fs.path.join('..', 'awesome_app', 'integration_test')),
            'integration_test',
          );
        });

        test('leaves a path outside the project as given', () {
          final outside = fs.path.join('..', 'other_app', 'integration_test');

          expect(read(outside), outside);
        });

        test('equals testDirectory when unset', () {
          fs.file('pubspec.yaml').writeAsStringSync(_pubspecBase);

          expect(reader.read().projectTestDirectory, 'patrol_test');
        });
      });

      test('reads emit_test_manifest', () {
        fs.file('pubspec.yaml').writeAsStringSync('''
$_pubspecBase
patrol:
  emit_test_manifest: true
''');

        expect(reader.read().emitTestManifest, isTrue);
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

      test('defaults `screenshot_on_failure` to false when absent', () {
        fs.file('pubspec.yaml').writeAsStringSync('''
$_pubspecBase
patrol:
  app_name: Example
''');

        expect(reader.read().screenshotOnFailure, isFalse);
      });

      test('reads `screenshot_on_failure`', () {
        fs.file('pubspec.yaml').writeAsStringSync('''
$_pubspecBase
patrol:
  app_name: Example
  screenshot_on_failure: true
''');

        expect(reader.read().screenshotOnFailure, isTrue);
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
