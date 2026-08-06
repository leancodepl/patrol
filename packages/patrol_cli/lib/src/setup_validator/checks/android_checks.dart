import 'package:collection/collection.dart';
import 'package:patrol_cli/src/setup_validator/checks/shared_checks.dart';
import 'package:patrol_cli/src/setup_validator/finding.dart';
import 'package:patrol_cli/src/setup_validator/project_probe.dart';

const _androidTestDir = 'android/app/src/androidTest';

/// Android project state shared by checks A1-A7. Kotlin DSL and Groovy are
/// both supported — every probe is a DSL-agnostic marker string.
class AndroidCheckContext {
  AndroidCheckContext({required this.probe}) {
    gradlePath = [
      'android/app/build.gradle.kts',
      'android/app/build.gradle',
    ].firstWhereOrNull(probe.fileExists);
    gradleContents = gradlePath == null ? null : probe.readFile(gradlePath!);

    patrolTestClasses = probe
        .listFilesRecursively(_androidTestDir)
        .where((path) => path.endsWith('.java') || path.endsWith('.kt'))
        .where(
          (path) => probe.readFile(path)?.contains('PatrolJUnitRunner') ?? false,
        )
        .toList();
  }

  final ProjectProbe probe;
  late final String? gradlePath;
  late final String? gradleContents;

  /// Instrumentation test classes referencing PatrolJUnitRunner, as paths
  /// relative to the project root.
  late final List<String> patrolTestClasses;

  String? get applicationId {
    final contents = gradleContents;
    if (contents == null) {
      return null;
    }
    return RegExp(r'''applicationId\s*=?\s*["']([A-Za-z0-9_.]+)["']''')
        .firstMatch(contents)
        ?.group(1);
  }
}

/// Runs all Android checks in catalog order.
List<Finding> androidFindings(AndroidCheckContext ctx) {
  final findings = <Finding?>[
    checkInstrumentationTestClass(ctx),
    checkTestClassPackage(ctx),
  ];

  if (ctx.gradleContents == null) {
    findings.add(
      const Finding(
        id: 'A3',
        severity: Severity.error,
        summary:
            'Could not find android/app/build.gradle(.kts), so the Gradle '
            'part of the Android setup was not verified.',
        fix:
            'Make sure the project has an android/app module with a Gradle '
            'build file.',
        docsUrl: '$docsBaseUrl#android-setup-open-build-gradle',
      ),
    );
  } else {
    findings.addAll([
      checkInstrumentationRunner(ctx),
      checkClearPackageData(ctx),
      checkOrchestratorExecution(ctx),
      checkOrchestratorDependency(ctx),
      checkMinificationAdvice(ctx),
    ]);
  }

  return findings.nonNulls.toList();
}

/// A1: a test class referencing PatrolJUnitRunner exists under androidTest/.
Finding? checkInstrumentationTestClass(AndroidCheckContext ctx) {
  if (ctx.patrolTestClasses.isNotEmpty) {
    return null;
  }
  return const Finding(
    id: 'A1',
    severity: Severity.error,
    summary:
        'No test class referencing PatrolJUnitRunner found under '
        '$_androidTestDir/. Without it JUnit discovers no test classes and '
        '`patrol test` reports `Total: 0`.',
    fix:
        'Create MainActivityTest.java in '
        '$_androidTestDir/java/<your package path>/ — copy it from the docs.',
    docsUrl: '$docsBaseUrl#android-setup-create-mainactivitytest',
  );
}

/// A2: the test class `package` matches its directory path (a Java
/// requirement) and the applicationId (Warning-grade: flavors with
/// applicationIdSuffix legitimately differ).
Finding? checkTestClassPackage(AndroidCheckContext ctx) {
  for (final path in ctx.patrolTestClasses) {
    final contents = ctx.probe.readFile(path);
    if (contents == null) {
      continue;
    }
    final package = RegExp(
      r'^\s*package\s+([A-Za-z0-9_.]+)',
      multiLine: true,
    ).firstMatch(contents)?.group(1);
    if (package == null) {
      continue;
    }

    final directory = path
        .substring(0, path.lastIndexOf('/'))
        .replaceAll(r'\', '/');
    if (!directory.endsWith(package.replaceAll('.', '/'))) {
      return Finding(
        id: 'A2',
        severity: Severity.warning,
        summary:
            'Test class $path declares `package $package`, which does not '
            'match its directory path — usually a copy-paste slip from the '
            'docs snippet.',
        fix:
            'Move the file so its path mirrors the package, or fix the '
            '`package` declaration.',
        docsUrl: '$docsBaseUrl#android-setup-create-mainactivitytest',
      );
    }

    final applicationId = ctx.applicationId;
    if (applicationId != null && package != applicationId) {
      return Finding(
        id: 'A2',
        severity: Severity.warning,
        summary:
            'Test class $path declares `package $package`, but '
            '`applicationId` is `$applicationId`.',
        fix:
            'This is fine if the difference comes from flavors '
            '(applicationIdSuffix); otherwise align the package with your '
            'applicationId.',
        docsUrl: '$docsBaseUrl#android-setup-create-mainactivitytest',
      );
    }
  }
  return null;
}

/// A3: testInstrumentationRunner points at a Patrol runner. The probe is the
/// package prefix, not the exact class, so device-farm variants
/// (BrowserstackPatrolJUnitRunner, LambdaTestPatrolJUnitRunner — issue #2493)
/// pass too.
Finding? checkInstrumentationRunner(AndroidCheckContext ctx) {
  if (ctx.gradleContents!.contains('pl.leancode.patrol.')) {
    return null;
  }
  return Finding(
    id: 'A3',
    severity: Severity.error,
    summary:
        '`testInstrumentationRunner` is not set to a Patrol runner in '
        '${ctx.gradlePath}.',
    fix:
        'Add `testInstrumentationRunner = '
        '"pl.leancode.patrol.PatrolJUnitRunner"` to the defaultConfig '
        'section.',
    docsUrl: '$docsBaseUrl#android-setup-set-test-runner',
  );
}

/// A4: the clearPackageData runner argument is set.
Finding? checkClearPackageData(AndroidCheckContext ctx) {
  if (ctx.gradleContents!.contains('clearPackageData')) {
    return null;
  }
  return Finding(
    id: 'A4',
    severity: Severity.error,
    summary: 'The `clearPackageData` runner argument is not set in '
        '${ctx.gradlePath}.',
    fix:
        'Add `testInstrumentationRunnerArguments["clearPackageData"] = '
        '"true"` to the defaultConfig section.',
    docsUrl: '$docsBaseUrl#android-setup-set-test-runner',
  );
}

/// A5: test execution uses the AndroidX Test Orchestrator.
Finding? checkOrchestratorExecution(AndroidCheckContext ctx) {
  if (ctx.gradleContents!.contains('ANDROIDX_TEST_ORCHESTRATOR')) {
    return null;
  }
  return Finding(
    id: 'A5',
    severity: Severity.error,
    summary:
        'testOptions does not set `execution = "ANDROIDX_TEST_ORCHESTRATOR"` '
        'in ${ctx.gradlePath}.',
    fix:
        'Add a `testOptions { execution = "ANDROIDX_TEST_ORCHESTRATOR" }` '
        'block to the android section.',
    docsUrl: '$docsBaseUrl#android-setup-enable-test-orchestrator',
  );
}

/// A6: the orchestrator dependency is declared (any version — versions are
/// deliberately not checked).
Finding? checkOrchestratorDependency(AndroidCheckContext ctx) {
  if (ctx.gradleContents!.contains('androidx.test:orchestrator')) {
    return null;
  }
  return Finding(
    id: 'A6',
    severity: Severity.error,
    summary:
        'The `androidx.test:orchestrator` dependency is not declared in '
        '${ctx.gradlePath}.',
    fix:
        'Add `androidTestUtil("androidx.test:orchestrator:1.5.1")` to the '
        'dependencies section. Do not add androidx.test:rules/runner '
        'manually.',
    docsUrl: '$docsBaseUrl#android-setup-add-orchestrator-dependency',
  );
}

/// A7: minification looks enabled and the ProGuard rules don't keep the
/// Patrol packages — release-mode runs (e.g. device farms) then fail with
/// ClassNotFoundException (issue #1542). Silent when no minification marker
/// is found or when a proguard file already keeps `pl.leancode.patrol`.
Finding? checkMinificationAdvice(AndroidCheckContext ctx) {
  final contents = ctx.gradleContents!;
  final minifyEnabled =
      RegExp(r'minifyEnabled\s+true').hasMatch(contents) ||
      RegExp(r'isMinifyEnabled\s*=\s*true').hasMatch(contents);
  if (!minifyEnabled) {
    return null;
  }

  final patrolKept = ctx.probe
      .listFilesRecursively('android/app')
      .where((path) => path.endsWith('.pro') && !path.contains('/build/'))
      .any(
        (path) =>
            ctx.probe.readFile(path)?.contains('pl.leancode.patrol') ?? false,
      );
  if (patrolKept) {
    return null;
  }

  return Finding(
    id: 'A7',
    severity: Severity.notice,
    summary:
        'Minification is enabled in ${ctx.gradlePath} and your ProGuard '
        'rules do not keep the Patrol packages — release-mode test runs can '
        'fail with ClassNotFoundException.',
    fix:
        'Add `-keep class pl.leancode.patrol.** { *; }` to your ProGuard '
        'rules, or disable minification for the build type you test.',
    docsUrl: '$docsBaseUrl#android-setup',
  );
}
