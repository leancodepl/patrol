import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:patrol_cli/src/reuse_build/native_fingerprint.dart';
import 'package:platform/testing.dart';
import 'package:test/test.dart';

void main() {
  late MemoryFileSystem fs;
  late Directory root;
  late NativeFingerprinter fingerprinter;

  const android = NativeBuildInputs(
    platform: ReusePlatform.android,
    flavor: null,
    buildName: null,
    buildNumber: null,
    appServerPort: 8082,
    testServerPort: 8081,
  );

  void write(String path, String contents) {
    fs.file('/app/$path')
      ..createSync(recursive: true)
      ..writeAsStringSync(contents);
  }

  String compute([NativeBuildInputs inputs = android]) =>
      fingerprinter.compute(inputs, flutterRevision: 'abc').hash;

  setUp(() {
    fs = MemoryFileSystem.test();
    root = fs.directory('/app')..createSync();
    fingerprinter = NativeFingerprinter(
      rootDirectory: root,
      platform: TestNativePlatform(
        operatingSystem: NativePlatform.macOS,
        environment: {'HOME': '/home/me'},
      ),
    );

    write('pubspec.yaml', '''
name: app
flutter:
  assets:
    - assets/images/
    - path: assets/config.json
  fonts:
    - family: Inter
      fonts:
        - asset: fonts/Inter.ttf
''');
    write('pubspec.lock', 'packages: {}');
    write('android/app/build.gradle.kts', 'android {}');
    write('android/app/src/main/AndroidManifest.xml', '<manifest/>');
    write('ios/Runner/Info.plist', '<plist/>');
    write('assets/images/logo.png', 'png');
    write('assets/config.json', '{}');
    write('fonts/Inter.ttf', 'ttf');
    write('lib/main.dart', 'void main() {}');
  });

  test('is stable', () {
    expect(compute(), compute());
  });

  test('changes when native code changes', () {
    final before = compute();
    write('android/app/src/main/AndroidManifest.xml', '<manifest a=""/>');
    expect(compute(), isNot(before));
  });

  test('ignores Dart code, build outputs and generated files', () {
    final before = compute();
    write('lib/main.dart', 'void main() { print(1); }');
    write('android/app/build/outputs/apk/debug/app-debug.apk', 'apk');
    write('android/.gradle/cache', 'x');
    write('android/local.properties', 'sdk.dir=/sdk');
    write(
      'android/app/src/androidTest/java/PatrolGeneratedTests_a.java',
      'class',
    );
    expect(compute(), before);
  });

  test('ignores the other platform', () {
    final before = compute();
    write('ios/Runner/Info.plist', '<plist a=""/>');
    expect(compute(), before);
  });

  test('changes when a declared asset or font changes', () {
    for (final path in [
      'assets/images/logo.png',
      'assets/config.json',
      'fonts/Inter.ttf',
    ]) {
      final before = compute();
      write(path, 'changed $path');
      expect(compute(), isNot(before), reason: path);
    }
  });

  test('changes when a file is added to an asset directory', () {
    final before = compute();
    write('assets/images/new.png', 'png');
    expect(compute(), isNot(before));
  });

  test('changes when native build options or Flutter change', () {
    final before = compute();
    expect(
      compute(
        const NativeBuildInputs(
          platform: ReusePlatform.android,
          flavor: null,
          buildName: null,
          buildNumber: null,
          appServerPort: 9000,
          testServerPort: 8081,
        ),
      ),
      isNot(before),
    );
    expect(
      fingerprinter.compute(android, flutterRevision: 'def').hash,
      isNot(before),
    );
  });

  test('ignores the plugin list timestamp but not the plugins', () {
    write(
      '.flutter-plugins-dependencies',
      '{"plugins":{"android":[]},"date_created":"1"}',
    );
    final before = compute();
    write(
      '.flutter-plugins-dependencies',
      '{"plugins":{"android":[]},"date_created":"2"}',
    );
    expect(compute(), before);
    write(
      '.flutter-plugins-dependencies',
      '{"plugins":{"android":[{"name":"a","path":"/home/me/.pub-cache/a/"}]},'
          '"date_created":"2"}',
    );
    expect(compute(), isNot(before));
  });

  test('covers native code of path plugins, not of pub cache plugins', () {
    write(
      '.flutter-plugins-dependencies',
      '{"plugins":{"android":['
          '{"name":"local","path":"/plugins/local/"},'
          '{"name":"hosted","path":"/home/me/.pub-cache/hosted/x/"}'
          ']}}',
    );
    fs.file('/plugins/local/android/src/Plugin.kt')
      ..createSync(recursive: true)
      ..writeAsStringSync('a');
    fs.file('/home/me/.pub-cache/hosted/x/android/src/Plugin.kt')
      ..createSync(recursive: true)
      ..writeAsStringSync('a');

    final before = compute();
    fs
        .file('/home/me/.pub-cache/hosted/x/android/src/Plugin.kt')
        .writeAsStringSync('b');
    expect(compute(), before);
    fs.file('/plugins/local/android/src/Plugin.kt').writeAsStringSync('b');
    expect(compute(), isNot(before));
  });
}
