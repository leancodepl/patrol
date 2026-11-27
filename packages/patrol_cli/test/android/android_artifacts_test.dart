import 'dart:convert';

import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:patrol_cli/src/android/android_artifacts.dart';
import 'package:patrol_cli/src/android/android_test_layout.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:test/test.dart';

void main() {
  late FileSystem fs;
  late AndroidArtifactResolver resolver;

  setUp(() {
    fs = MemoryFileSystem.test();
    resolver = AndroidArtifactResolver(fs.currentDirectory);
  });

  void writeArtifact({
    required String directory,
    required String variant,
    required String applicationId,
    required String outputFile,
  }) {
    final dir = fs.directory(directory)..createSync(recursive: true);
    dir.childFile(outputFile).writeAsStringSync('apk');
    dir
        .childFile('output-metadata.json')
        .writeAsStringSync(
          jsonEncode({
            'applicationId': applicationId,
            'variantName': variant,
            'elements': [
              {'filters': <Object>[], 'outputFile': outputFile},
            ],
          }),
        );
  }

  test('resolves matching app variant instead of first debug APK', () {
    writeArtifact(
      directory: 'build/app/outputs/apk/debug',
      variant: 'debug',
      applicationId: 'com.example',
      outputFile: 'app-debug.apk',
    );
    writeArtifact(
      directory: 'build/app/outputs/apk/dev/debug',
      variant: 'devDebug',
      applicationId: 'com.example.dev',
      outputFile: 'app-dev-debug.apk',
    );

    final artifact = resolver.app(buildMode: BuildMode.debug, flavor: null);

    expect(artifact.applicationId, 'com.example');
    expect(artifact.apk.basename, 'app-debug.apk');
  });

  test('resolves self-instrumenting test artifact case-insensitively', () {
    writeArtifact(
      directory: 'build/patrolTest/outputs/apk/dev/debug',
      variant: 'devDebug',
      applicationId: 'com.example.patrol_test',
      outputFile: 'patrolTest-dev-debug.apk',
    );

    final artifact = resolver.test(
      layout: AndroidTestLayout.selfInstrumenting,
      buildMode: BuildMode.debug,
      flavor: 'Dev',
    );

    expect(artifact.apk.basename, 'patrolTest-dev-debug.apk');
  });

  test('resolves in-app androidTest artifact', () {
    writeArtifact(
      directory: 'build/app/outputs/apk/androidTest/debug',
      variant: 'debugAndroidTest',
      applicationId: 'com.example.test',
      outputFile: 'app-debug-androidTest.apk',
    );

    final artifact = resolver.test(
      layout: AndroidTestLayout.inApp,
      buildMode: BuildMode.debug,
      flavor: null,
    );

    expect(artifact.applicationId, 'com.example.test');
    expect(artifact.apk.basename, 'app-debug-androidTest.apk');
  });

  test(
    'resolves applicationId for ABI-split builds without a universal APK',
    () {
      final dir = fs.directory('build/app/outputs/apk/debug')
        ..createSync(recursive: true);
      dir.childFile('app-debug-armeabi-v7a.apk').writeAsStringSync('apk');
      dir.childFile('app-debug-arm64-v8a.apk').writeAsStringSync('apk');
      dir
          .childFile('output-metadata.json')
          .writeAsStringSync(
            jsonEncode({
              'applicationId': 'com.example.split',
              'variantName': 'debug',
              'elements': [
                {
                  'filters': [
                    {'filterType': 'ABI', 'value': 'armeabi-v7a'},
                  ],
                  'outputFile': 'app-debug-armeabi-v7a.apk',
                },
                {
                  'filters': [
                    {'filterType': 'ABI', 'value': 'arm64-v8a'},
                  ],
                  'outputFile': 'app-debug-arm64-v8a.apk',
                },
              ],
            }),
          );

      expect(
        resolver.applicationId(buildMode: BuildMode.debug, flavor: null),
        'com.example.split',
      );
      expect(
        () => resolver.app(buildMode: BuildMode.debug, flavor: null),
        throwsA(isA<ToolExit>()),
      );
    },
  );
}
