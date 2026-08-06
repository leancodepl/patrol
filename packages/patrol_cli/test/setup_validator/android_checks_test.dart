import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:patrol_cli/src/setup_validator/checks/android_checks.dart';
import 'package:patrol_cli/src/setup_validator/finding.dart';
import 'package:patrol_cli/src/setup_validator/project_probe.dart';
import 'package:test/test.dart';

const _gradleKts = '''
android {
    namespace = "com.example.myapp"

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
''';

const _gradleGroovy = '''
android {
    namespace "com.example.myapp"

    defaultConfig {
        applicationId "com.example.myapp"
        testInstrumentationRunner "pl.leancode.patrol.PatrolJUnitRunner"
        testInstrumentationRunnerArguments clearPackageData: "true"
    }

    testOptions {
        execution "ANDROIDX_TEST_ORCHESTRATOR"
    }
}

dependencies {
    androidTestUtil "androidx.test:orchestrator:1.5.1"
}
''';

const _mainActivityTest = '''
package com.example.myapp;

import androidx.test.platform.app.InstrumentationRegistry;
import pl.leancode.patrol.PatrolJUnitRunner;

public class MainActivityTest {}
''';

const _testClassPath =
    'android/app/src/androidTest/java/com/example/myapp/MainActivityTest.java';

void main() {
  late MemoryFileSystem fs;
  late Directory projectRoot;

  setUp(() {
    fs = MemoryFileSystem();
    projectRoot = fs.directory('/project')..createSync();
  });

  AndroidCheckContext contextWith({
    String? gradleKts = _gradleKts,
    String? gradleGroovy,
    String? testClass = _mainActivityTest,
    String testClassPath = _testClassPath,
  }) {
    if (gradleKts != null) {
      fs
          .file('/project/android/app/build.gradle.kts')
          .createSync(recursive: true);
      fs
          .file('/project/android/app/build.gradle.kts')
          .writeAsStringSync(gradleKts);
    }
    if (gradleGroovy != null) {
      fs
          .file('/project/android/app/build.gradle')
          .createSync(recursive: true);
      fs
          .file('/project/android/app/build.gradle')
          .writeAsStringSync(gradleGroovy);
    }
    if (testClass != null) {
      fs.file('/project/$testClassPath').createSync(recursive: true);
      fs.file('/project/$testClassPath').writeAsStringSync(testClass);
    }
    return AndroidCheckContext(probe: ProjectProbe(projectRoot: projectRoot));
  }

  group('complete setup', () {
    test('Kotlin DSL project passes all checks', () {
      expect(androidFindings(contextWith()), isEmpty);
    });

    test('Groovy project passes all checks', () {
      expect(
        androidFindings(contextWith(gradleKts: null, gradleGroovy: _gradleGroovy)),
        isEmpty,
      );
    });

    test('Kotlin test class passes A1', () {
      final ctx = contextWith(
        testClass: '''
package com.example.myapp

import pl.leancode.patrol.PatrolJUnitRunner

class MainActivityTest
''',
        testClassPath:
            'android/app/src/androidTest/kotlin/com/example/myapp/MainActivityTest.kt',
      );
      expect(checkInstrumentationTestClass(ctx), isNull);
    });
  });

  group('A1 instrumentation test class', () {
    test('errors when no test class exists', () {
      final ctx = contextWith(testClass: null);
      final finding = checkInstrumentationTestClass(ctx);
      expect(finding?.severity, Severity.error);
      expect(finding?.summary, contains('Total: 0'));
    });

    test('errors when androidTest classes lack the Patrol runner', () {
      final ctx = contextWith(
        testClass: 'package com.example.myapp;\npublic class OtherTest {}',
      );
      expect(checkInstrumentationTestClass(ctx)?.severity, Severity.error);
    });
  });

  group('A2 test class package', () {
    test('warns when package does not match the directory path', () {
      final ctx = contextWith(
        testClassPath:
            'android/app/src/androidTest/java/com/example/other/MainActivityTest.java',
      );
      final finding = checkTestClassPackage(ctx);
      expect(finding?.severity, Severity.warning);
      expect(finding?.summary, contains('does not match its directory path'));
    });

    test('warns when package differs from applicationId', () {
      final ctx = contextWith(
        gradleKts: _gradleKts.replaceAll(
          'applicationId = "com.example.myapp"',
          'applicationId = "com.example.different"',
        ),
      );
      final finding = checkTestClassPackage(ctx);
      expect(finding?.severity, Severity.warning);
      expect(finding?.fix, contains('applicationIdSuffix'));
    });

    test('is silent when no test class exists (A1 covers it)', () {
      expect(checkTestClassPackage(contextWith(testClass: null)), isNull);
    });
  });

  group('A3 instrumentation runner', () {
    test('errors when the Patrol runner is not configured', () {
      final ctx = contextWith(
        gradleKts: _gradleKts.replaceAll(
          'testInstrumentationRunner = "pl.leancode.patrol.PatrolJUnitRunner"',
          '',
        ),
      );
      expect(checkInstrumentationRunner(ctx)?.severity, Severity.error);
    });

    test('accepts device-farm runner variants', () {
      for (final runner in [
        'pl.leancode.patrol.BrowserstackPatrolJUnitRunner',
        'pl.leancode.patrol.LambdaTestPatrolJUnitRunner',
      ]) {
        final ctx = contextWith(
          gradleKts: _gradleKts.replaceAll(
            'pl.leancode.patrol.PatrolJUnitRunner',
            runner,
          ),
        );
        expect(checkInstrumentationRunner(ctx), isNull);
      }
    });
  });

  group('A4-A6 gradle markers', () {
    test('A4 errors when clearPackageData is missing', () {
      final ctx = contextWith(
        gradleKts: _gradleKts.replaceAll(
          'testInstrumentationRunnerArguments["clearPackageData"] = "true"',
          '',
        ),
      );
      expect(checkClearPackageData(ctx)?.severity, Severity.error);
    });

    test('A5 errors when orchestrator execution is missing', () {
      final ctx = contextWith(
        gradleKts: _gradleKts.replaceAll('ANDROIDX_TEST_ORCHESTRATOR', ''),
      );
      expect(checkOrchestratorExecution(ctx)?.severity, Severity.error);
    });

    test('A6 errors when the orchestrator dependency is missing', () {
      final ctx = contextWith(
        gradleKts: _gradleKts.replaceAll(
          'androidTestUtil("androidx.test:orchestrator:1.5.1")',
          '',
        ),
      );
      expect(checkOrchestratorDependency(ctx)?.severity, Severity.error);
    });

    test('A6 accepts any orchestrator version', () {
      final ctx = contextWith(
        gradleKts: _gradleKts.replaceAll('1.5.1', '1.6.1'),
      );
      expect(checkOrchestratorDependency(ctx), isNull);
    });
  });

  group('A7 minification advice', () {
    test('notices when minification is enabled (Kotlin DSL)', () {
      final ctx = contextWith(
        gradleKts: '$_gradleKts\nandroid { buildTypes { debug { isMinifyEnabled = true } } }',
      );
      expect(checkMinificationAdvice(ctx)?.severity, Severity.notice);
    });

    test('notices when minification is enabled (Groovy)', () {
      final ctx = contextWith(
        gradleKts: null,
        gradleGroovy: '$_gradleGroovy\nandroid { buildTypes { debug { minifyEnabled true } } }',
      );
      expect(checkMinificationAdvice(ctx)?.severity, Severity.notice);
    });

    test('is silent when minification is not mentioned', () {
      expect(checkMinificationAdvice(contextWith()), isNull);
    });

    test('is silent when proguard rules already keep Patrol', () {
      fs.file('/project/android/app/proguard-rules.pro')
        ..createSync(recursive: true)
        ..writeAsStringSync('-keep class pl.leancode.patrol.** { *; }\n');
      final ctx = contextWith(
        gradleKts:
            '$_gradleKts\nandroid { buildTypes { release { isMinifyEnabled = true } } }',
      );
      expect(checkMinificationAdvice(ctx), isNull);
    });

    test('mentions the keep rule when proguard rules lack Patrol', () {
      fs.file('/project/android/app/proguard-rules.pro')
        ..createSync(recursive: true)
        ..writeAsStringSync('-keep class io.flutter.** { *; }\n');
      final ctx = contextWith(
        gradleKts:
            '$_gradleKts\nandroid { buildTypes { release { isMinifyEnabled = true } } }',
      );
      final finding = checkMinificationAdvice(ctx);
      expect(finding?.severity, Severity.notice);
      expect(finding?.fix, contains('pl.leancode.patrol.**'));
    });
  });

  group('missing gradle file', () {
    test('reports a single error instead of A3-A6 noise', () {
      final findings = androidFindings(contextWith(gradleKts: null));
      final gradleErrors = findings.where(
        (finding) => finding.summary.contains('build.gradle'),
      );
      expect(gradleErrors, hasLength(1));
      expect(gradleErrors.single.severity, Severity.error);
      expect(
        findings.map((finding) => finding.id),
        isNot(containsAll(['A4', 'A5', 'A6'])),
      );
    });
  });
}
