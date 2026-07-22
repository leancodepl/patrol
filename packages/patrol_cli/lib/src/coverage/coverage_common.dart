import 'package:coverage/coverage.dart' as coverage;
import 'package:file/file.dart';
import 'package:glob/glob.dart';
import 'package:meta/meta.dart';
import 'package:package_config/package_config.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:yaml/yaml.dart';

/// Writes [hitMap] as LCOV to `coverage/patrol_lcov.info`, resolving sources
/// under [packagePath]. Shared by the VM and web coverage tools.
Future<void> formatAndSaveLcovReport({
  required FileSystem fs,
  required Map<String, coverage.HitMap> hitMap,
  required String packagePath,
  required Set<Glob> ignoreGlobs,
  required Logger logger,
}) async {
  logger.info('All coverage gathered, saving');
  final report = hitMap.formatLcov(
    await coverage.Resolver.create(packagePath: packagePath),
    ignoreGlobs: ignoreGlobs,
  );

  final coverageDirectory = fs.directory('coverage');
  await coverageDirectory.create(recursive: true);
  await coverageDirectory.childFile('patrol_lcov.info').writeAsString(report);
}

/// Returns package names matching [packagesRegExps] in `package_config.json`,
/// optionally plus the Pub workspace members of [rootDirectory].
Future<Set<String>> getCoveragePackages({
  required Directory rootDirectory,
  required Set<RegExp> packagesRegExps,
  required bool includeWorkspacePackages,
  required Logger logger,
}) async {
  final packageConfigFile = findPackageConfigFile(rootDirectory);
  if (packageConfigFile == null) {
    throwToolExit(
      "Couldn't find .dart_tool/package_config.json in "
      '${rootDirectory.path} or any parent directory. '
      'Run `flutter pub get` first.',
    );
  }
  final packageConfig = await loadPackageConfig(packageConfigFile);

  final packagesToInclude = {
    for (final regExp in packagesRegExps)
      ...packageConfig.packages.map((e) => e.name).where(regExp.hasMatch),
  };

  if (includeWorkspacePackages) {
    // package_config.json lives in <workspace-root>/.dart_tool/.
    final workspaceRoot = packageConfigFile.parent.parent;
    final members = findWorkspaceMemberPackages(workspaceRoot);
    if (members.isEmpty) {
      logger.warn(
        'No `workspace:` entries found in ${workspaceRoot.path}/pubspec.yaml; '
        '--coverage-workspace had no effect.',
      );
    } else {
      logger.detail('Workspace member packages: $members');
      packagesToInclude.addAll(members);
    }
  }

  logger.detail('Packages included in coverage: $packagesToInclude');

  return packagesToInclude;
}

/// Returns the package names declared under the `workspace:` key of
/// `<workspaceRoot>/pubspec.yaml`.
///
/// Each entry is a path relative to [workspaceRoot] whose `pubspec.yaml`
/// `name:` is the package name. Members without a readable `pubspec.yaml` are
/// skipped, as pub already reports that during `pub get`. Returns an empty set
/// when the root `pubspec.yaml` is missing, has no `workspace:` key, or isn't
/// a map.
@visibleForTesting
Set<String> findWorkspaceMemberPackages(Directory workspaceRoot) {
  final root = _tryLoadYamlMap(workspaceRoot.childFile('pubspec.yaml'));
  if (root == null) {
    return const {};
  }
  final members = root['workspace'];
  if (members is! Iterable) {
    return const {};
  }

  final names = <String>{};
  for (final entry in members) {
    if (entry is! String) {
      continue;
    }
    // `workspace:` entries are POSIX-style paths; split on `/` to stay
    // platform-agnostic.
    var memberDir = workspaceRoot;
    for (final segment in entry.split('/')) {
      if (segment.isEmpty || segment == '.') {
        continue;
      }
      memberDir = memberDir.childDirectory(segment);
    }
    final memberYaml = _tryLoadYamlMap(memberDir.childFile('pubspec.yaml'));
    if (memberYaml == null) {
      continue;
    }
    final name = memberYaml['name'];
    if (name is String && name.isNotEmpty) {
      names.add(name);
    }
  }
  return names;
}

/// Reads [file] as YAML and returns its top-level map, or `null` if the file
/// is missing, fails to parse, or isn't a map.
///
/// A malformed file is treated as missing so coverage degrades gracefully
/// instead of crashing; pub already surfaces the error during `pub get`.
Map<dynamic, dynamic>? _tryLoadYamlMap(File file) {
  if (!file.existsSync()) {
    return null;
  }
  try {
    final parsed = loadYaml(file.readAsStringSync());
    return parsed is Map ? parsed : null;
  } on YamlException {
    return null;
  }
}

/// Walks up from [directory] looking for `.dart_tool/package_config.json`,
/// which in a Pub workspace lives at the workspace root. Returns `null` if
/// none is found up to the filesystem root.
@visibleForTesting
File? findPackageConfigFile(Directory directory) {
  var current = directory;
  while (true) {
    final candidate = current
        .childDirectory('.dart_tool')
        .childFile('package_config.json');
    if (candidate.existsSync()) {
      return candidate;
    }
    final parent = current.parent;
    if (parent.path == current.path) {
      return null;
    }
    current = parent;
  }
}
