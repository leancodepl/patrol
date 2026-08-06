import 'package:collection/collection.dart';
import 'package:patrol_cli/src/compatibility_checker/version_compatibility.dart';
import 'package:patrol_cli/src/setup_validator/finding.dart';
import 'package:patrol_cli/src/setup_validator/project_probe.dart';
import 'package:version/version.dart';
import 'package:yaml/yaml.dart';

const docsBaseUrl = 'https://patrol.leancode.co/documentation';
const setupDocsUrl = '$docsBaseUrl#setup';
const compatibilityTableUrl =
    'https://patrol.leancode.co/documentation/compatibility-table';

/// Parsed pubspec state shared by the checks. Absence probes only —
/// presence is a silent pass, so we never validate values. Malformed shapes
/// (scalar root, `patrol: enabled`, non-string values) are treated as absent
/// so they surface as findings instead of crashing the command.
class SharedCheckContext {
  SharedCheckContext({required this.probe}) {
    final contents = probe.readFile('pubspec.yaml');
    Object? root;
    if (contents != null) {
      try {
        root = loadYaml(contents);
      } on YamlException {
        root = null;
      }
    }
    _pubspec = root is Map ? root : null;
  }

  final ProjectProbe probe;
  late final Map<dynamic, dynamic>? _pubspec;

  bool get pubspecExists => _pubspec != null;

  /// Add-to-app Flutter modules (`flutter: module:` in pubspec.yaml) don't
  /// use the standalone-app setup the docs describe at all.
  bool get isAddToAppModule {
    final flutter = _pubspec?['flutter'];
    return flutter is Map && flutter['module'] != null;
  }

  Map<dynamic, dynamic>? get patrolSection {
    final patrol = _pubspec?['patrol'];
    return patrol is Map ? patrol : null;
  }

  bool get patrolDependencyDeclared {
    for (final section in [
      'dependencies',
      'dev_dependencies',
      'dependency_overrides',
    ]) {
      final deps = _pubspec?[section];
      if (deps is Map && deps.containsKey('patrol')) {
        return true;
      }
    }
    return false;
  }

  /// Platforms declared under the `patrol:` section.
  Set<String> get declaredPlatforms => {
    for (final platform in ['android', 'ios', 'macos'])
      if (patrolSection?[platform] is Map) platform,
  };

  String get testDirectory {
    final value = patrolSection?['test_directory'];
    return value is String ? value : 'patrol_test';
  }

  String get testFileSuffix {
    final value = patrolSection?['test_file_suffix'];
    return value is String ? value : '_test.dart';
  }

  bool testFilesIn(String directory) => probe
      .listFilesRecursively(directory)
      .any((path) => path.endsWith(testFileSuffix));
}

/// S1: the `patrol` package is declared in pubspec.yaml (any section, any
/// source — placement is deliberately not checked).
Finding? checkPatrolDependency(SharedCheckContext ctx) {
  if (ctx.patrolDependencyDeclared) {
    return null;
  }
  return const Finding(
    id: 'S1',
    severity: Severity.error,
    summary: 'The `patrol` package is not declared in pubspec.yaml.',
    fix: 'Run `flutter pub add patrol --dev`.',
    docsUrl: '$docsBaseUrl#add-patrol-dependency',
  );
}

/// S2: the `patrol:` section exists and has `app_name` plus an identifier for
/// every declared platform.
Finding? checkPatrolSection(SharedCheckContext ctx) {
  final patrol = ctx.patrolSection;
  if (patrol == null) {
    return const Finding(
      id: 'S2',
      severity: Severity.error,
      summary: 'No `patrol:` section in pubspec.yaml.',
      fix:
          'Add a top-level `patrol:` section with `app_name` and your '
          'platform identifiers (android.package_name, ios.bundle_id, ...).',
      docsUrl: '$docsBaseUrl#configure-pubspec',
    );
  }

  final missing = <String>[];

  final topLevelAppName = patrol['app_name'] is String;
  bool platformHas(String platform, String key) {
    final section = patrol[platform];
    return section is Map && section[key] is String;
  }

  // An empty declared-platform set must not vacuously satisfy app_name.
  if (!topLevelAppName &&
      (ctx.declaredPlatforms.isEmpty ||
          !ctx.declaredPlatforms.every(
            (platform) => platformHas(platform, 'app_name'),
          ))) {
    missing.add('app_name');
  }
  if (ctx.declaredPlatforms.contains('android') &&
      !platformHas('android', 'package_name')) {
    missing.add('android.package_name');
  }
  for (final platform in ['ios', 'macos']) {
    if (ctx.declaredPlatforms.contains(platform) &&
        !platformHas(platform, 'bundle_id')) {
      missing.add('$platform.bundle_id');
    }
  }

  if (missing.isEmpty) {
    return null;
  }
  return Finding(
    id: 'S2',
    severity: Severity.error,
    summary:
        'The `patrol:` section in pubspec.yaml is missing: '
        '${missing.join(', ')}.',
    fix: 'Add the missing keys to the `patrol:` section.',
    docsUrl: '$docsBaseUrl#configure-pubspec',
  );
}

/// S3: a stray patrol.yaml exists — Patrol never reads it.
Finding? checkStrayPatrolYaml(SharedCheckContext ctx) {
  if (!ctx.probe.fileExists('patrol.yaml')) {
    return null;
  }
  return const Finding(
    id: 'S3',
    severity: Severity.warning,
    summary: 'Found patrol.yaml — Patrol does not read this file.',
    fix:
        'Move the configuration to pubspec.yaml under the `patrol:` key. '
        'Config lives in pubspec.yaml by design; see '
        'https://github.com/leancodepl/patrol/issues/2065.',
    docsUrl: '$docsBaseUrl#configure-pubspec',
  );
}

/// S4: the test directory exists and contains at least one test file.
Finding? checkTestDirectory(SharedCheckContext ctx) {
  final directory = ctx.testDirectory;
  if (!ctx.probe.dirExists(directory)) {
    return Finding(
      id: 'S4',
      severity: Severity.error,
      summary: 'Test directory `$directory/` does not exist.',
      fix:
          'Create `$directory/example_test.dart`, or point Patrol at your '
          'tests with `test_directory:` in the `patrol:` section.',
      docsUrl: '$docsBaseUrl#create-integration-test',
    );
  }
  if (!ctx.testFilesIn(directory)) {
    return Finding(
      id: 'S4',
      severity: Severity.error,
      summary:
          'Test directory `$directory/` contains no '
          '`*${ctx.testFileSuffix}` files.',
      fix: 'Add at least one test file, e.g. `$directory/example_test.dart`.',
      docsUrl: '$docsBaseUrl#create-integration-test',
    );
  }
  return null;
}

/// S5: tests live in integration_test/ while the configured directory has
/// none — the classic wrong-directory mistake. Only fires when S4 failed.
Finding? checkIntegrationTestDirectory(SharedCheckContext ctx) {
  if (ctx.testDirectory == 'integration_test') {
    return null;
  }
  if (ctx.testFilesIn(ctx.testDirectory)) {
    return null;
  }
  if (!ctx.testFilesIn('integration_test')) {
    return null;
  }
  return Finding(
    id: 'S5',
    severity: Severity.warning,
    summary:
        'Found test files in `integration_test/`, but Patrol reads '
        '`${ctx.testDirectory}/`.',
    fix:
        'Move the tests to `${ctx.testDirectory}/`, or set '
        '`test_directory: integration_test` in the `patrol:` section.',
    docsUrl: '$docsBaseUrl#configure-pubspec',
  );
}

/// S6: the generated test_bundle.dart is gitignored. The pattern may live in
/// any ancestor .gitignore (monorepos, pub workspaces).
Finding? checkTestBundleGitignored(SharedCheckContext ctx) {
  final gitignores = ctx.probe.readFilesHereAndAbove('.gitignore');
  if (gitignores.any((contents) => contents.contains('test_bundle.dart'))) {
    return null;
  }
  return Finding(
    id: 'S6',
    severity: Severity.notice,
    summary:
        '`${ctx.testDirectory}/test_bundle.dart` is not gitignored. Patrol '
        'generates this file; it should not be committed.',
    fix: 'Add `${ctx.testDirectory}/test_bundle.dart` to .gitignore.',
    docsUrl: setupDocsUrl,
  );
}

/// S7: resolved patrol version is compatible with this patrol_cli version.
Finding? checkVersionCompatibility(
  SharedCheckContext ctx, {
  required String cliVersion,
}) {
  if (!ctx.patrolDependencyDeclared) {
    // S1 already reports the root cause.
    return null;
  }

  // Nearest lock wins; pub workspaces keep it at the workspace root.
  final lockContents = ctx.probe
      .readFilesHereAndAbove('pubspec.lock')
      .firstOrNull;
  String? patrolVersion;
  if (lockContents != null) {
    try {
      final lock = loadYaml(lockContents) as Map?;
      final patrol = (lock?['packages'] as Map?)?['patrol'] as Map?;
      patrolVersion = patrol?['version']?.toString();
    } on YamlException {
      patrolVersion = null;
    }
  }

  if (patrolVersion == null) {
    return const Finding(
      id: 'S7',
      severity: Severity.notice,
      summary:
          'Could not resolve the `patrol` version from pubspec.lock, so '
          'patrol ↔ patrol_cli compatibility was not verified.',
      fix: 'Run `flutter pub get` and re-run `patrol validate`.',
      docsUrl: compatibilityTableUrl,
    );
  }

  final Version cli;
  final Version patrol;
  try {
    cli = Version.parse(cliVersion);
    patrol = Version.parse(patrolVersion);
  } on FormatException {
    return null;
  }

  if (areVersionsCompatible(cli, patrol)) {
    return null;
  }

  final maxCliVersion = getMaxCompatibleCliVersion(patrol);
  return Finding(
    id: 'S7',
    severity: Severity.error,
    summary:
        'patrol $patrolVersion is not compatible with patrol_cli $cliVersion.',
    fix: maxCliVersion != null
        ? 'Run `dart pub global activate patrol_cli $maxCliVersion`, or '
              'upgrade both packages to the latest versions.'
        : 'Upgrade both `patrol` and `patrol_cli` to the latest versions.',
    docsUrl: compatibilityTableUrl,
  );
}
