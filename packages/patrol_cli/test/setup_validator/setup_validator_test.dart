import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:patrol_cli/src/setup_validator/environment_checks.dart';
import 'package:patrol_cli/src/setup_validator/finding.dart';
import 'package:patrol_cli/src/setup_validator/setup_validator.dart';
import 'package:platform/platform.dart';
import 'package:test/test.dart';

void main() {
  late MemoryFileSystem fs;
  late Directory projectRoot;

  final macosHost = FakePlatform(
    operatingSystem: 'macos',
    environment: {'ANDROID_HOME': '/sdk'},
  );

  SetupValidator validator({bool toolsInstalled = true}) {
    return SetupValidator(
      projectRoot: projectRoot,
      platform: macosHost,
      cliVersion: '4.5.0',
      environmentChecks: EnvironmentChecks(
        platform: macosHost,
        isToolInstalled: (_) => toolsInstalled,
      ),
    );
  }

  setUp(() {
    fs = MemoryFileSystem();
    projectRoot = fs.directory('/project')..createSync();
    fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: example_app
dev_dependencies:
  patrol: ^4.0.0
patrol:
  app_name: My App
  android:
    package_name: com.example.myapp
''');
    fs.file('/project/pubspec.lock').writeAsStringSync('''
packages:
  patrol:
    version: "4.6.0"
''');
    fs
        .file('/project/patrol_test/example_test.dart')
        .createSync(recursive: true);
    fs
        .file('/project/.gitignore')
        .writeAsStringSync('patrol_test/test_bundle.dart\n');
    fs
        .file('/project/android/app/build.gradle.kts')
        .createSync(recursive: true);
    fs.file('/project/android/app/build.gradle.kts').writeAsStringSync('''
android {
    defaultConfig {
        applicationId = "com.example.myapp"
        testInstrumentationRunner = "pl.leancode.patrol.PatrolJUnitRunner"
        testInstrumentationRunnerArguments["clearPackageData"] = "true"
    }
    testOptions {
        execution = "ANDROIDX_TEST_ORCHESTRATOR"
    }
}
dependencies {
    androidTestUtil("androidx.test:orchestrator:1.5.1")
}
''');
    fs
        .file(
          '/project/android/app/src/androidTest/java/com/example/myapp/MainActivityTest.java',
        )
        .createSync(recursive: true);
    fs
        .file(
          '/project/android/app/src/androidTest/java/com/example/myapp/MainActivityTest.java',
        )
        .writeAsStringSync('''
package com.example.myapp;
import pl.leancode.patrol.PatrolJUnitRunner;
public class MainActivityTest {}
''');
  });

  test('add-to-app module gets one notice and no other checks', () {
    fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: my_module
dependencies:
  patrol_finders: ^2.0.0
flutter:
  module:
    androidPackage: com.example.module
''');
    final report = validator().validate();
    expect(report.hasErrors, isFalse);
    expect(report.findings, hasLength(1));
    expect(report.findings.single.id, 'S0');
    expect(report.findings.single.severity, Severity.notice);
  });

  test('complete android project reports no errors', () {
    final report = validator().validate();
    expect(report.hasErrors, isFalse);
    expect(report.countOf(Severity.warning), 0);
  });

  test('broken project reports errors and exit-worthy state', () {
    fs.directory('/project/patrol_test').deleteSync(recursive: true);
    final report = validator().validate();
    expect(report.hasErrors, isTrue);
    expect(report.findings.map((finding) => finding.id), contains('S4'));
  });

  test('missing android tooling is an error for a declared platform', () {
    final report = validator(toolsInstalled: false).validate();
    final environment = report.sections
        .firstWhere((section) => section.title == 'Environment')
        .findings;
    expect(environment.map((finding) => finding.id), contains('E1'));
    expect(report.hasErrors, isTrue);
  });

  test('present but undeclared platform gets a single actionable notice', () {
    fs.directory('/project/macos').createSync();
    final report = validator().validate();
    final macos = report.sections
        .firstWhere((section) => section.title == 'macOS')
        .findings;
    expect(macos, hasLength(1));
    expect(macos.single.severity, Severity.notice);
    expect(macos.single.fix, contains('Add `macos:`'));
    expect(report.hasErrors, isFalse);
  });

  test('--platform filter narrows validated platforms', () {
    final report = validator().validate(platformFilter: {'ios'});
    // android is declared but filtered out: its environment checks are
    // skipped, so a fully-tooled report stays green.
    final environment = report.sections
        .firstWhere((section) => section.title == 'Environment')
        .findings;
    expect(environment, isEmpty);
  });

  test(
    'undeclared platform with a present directory downgrades to a notice',
    () {
      fs.file('/project/pubspec.yaml').writeAsStringSync('''
name: example_app
dev_dependencies:
  patrol: ^4.0.0
patrol:
  app_name: My App
''');
      final report = validator().validate();
      final android = report.sections
          .firstWhere((section) => section.title == 'Android')
          .findings;
      // Strict Android checks are skipped; only the declare-it notice shows.
      expect(android.single.id, 'P1');
      expect(report.hasErrors, isFalse);
    },
  );
}
