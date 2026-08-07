import 'package:collection/collection.dart';
import 'package:patrol_cli/src/setup_validator/project_probe.dart';

/// Shared Xcode-project state for the iOS and macOS checks.
///
/// The project name is discovered, never assumed to be `Runner`
/// (issue #1878). CocoaPods and SPM are detected independently by evidence,
/// because hybrid projects exist (SPM enabled while a Podfile remains for
/// not-yet-migrated plugins).
class DarwinCheckContext {
  DarwinCheckContext({required this.probe, required this.platformDir}) {
    files = probe
        .listFilesRecursively(platformDir)
        .map((path) => path.replaceAll(r'\', '/'))
        .whereNot(
          (path) =>
              path.contains('/Pods/') ||
              path.contains('/ephemeral/') ||
              path.contains('/.symlinks/') ||
              path.contains('/build/'),
        )
        .toList();

    final pbxprojPath = files.firstWhereOrNull(
      (path) => RegExp(
        '^$platformDir/[^/]+\\.xcodeproj/project\\.pbxproj\$',
      ).hasMatch(path),
    );
    xcodeprojDir = pbxprojPath?.substring(
      0,
      pbxprojPath.length - '/project.pbxproj'.length,
    );
    pbxproj = pbxprojPath == null ? null : probe.readFile(pbxprojPath);

    podfileExists = probe.fileExists('$platformDir/Podfile');
    // Flutter's SPM integration consists of adding
    // FlutterGeneratedPluginSwiftPackage to the Xcode project, so the pbxproj
    // marker is both necessary and sufficient. A Package.resolved under
    // xcshareddata/swiftpm is deliberately NOT a signal: stale leftovers of
    // it exist in real CocoaPods projects and would mis-detect SPM.
    spmDetected =
        pbxproj?.contains('FlutterGeneratedPluginSwiftPackage') ?? false;
  }

  final ProjectProbe probe;

  /// `ios` or `macos`.
  final String platformDir;

  /// Platform files, project-relative, with Pods/ephemeral/symlinks noise
  /// cut out.
  late final List<String> files;

  /// Discovered `<platformDir>/<name>.xcodeproj` directory, or null when
  /// none exists.
  late final String? xcodeprojDir;
  late final String? pbxproj;
  late final bool podfileExists;
  late final bool spmDetected;

  bool get hybrid => podfileExists && spmDetected;

  /// The `PBXNativeTarget` block of [name], or null when it cannot be
  /// isolated (missing target or unexpected pbxproj formatting).
  String? nativeTargetBlock(String name) {
    final contents = pbxproj;
    if (contents == null) {
      return null;
    }
    return RegExp(
      '/\\* ${RegExp.escape(name)} \\*/ = \\{\\s*isa = PBXNativeTarget;'
      r'.*?\n\t\t\};',
      dotAll: true,
    ).firstMatch(contents)?.group(0);
  }

  String? get runnerUITestsTargetBlock => nativeTargetBlock('RunnerUITests');

  /// Build-configuration names of the [targetName] target, resolved through
  /// its XCConfigurationList. Null when they cannot be isolated.
  Set<String>? configurationNames(String targetName) {
    final target = nativeTargetBlock(targetName);
    if (target == null) {
      return null;
    }
    final listId = RegExp(
      'buildConfigurationList = ([A-F0-9]{24})',
    ).firstMatch(target)?.group(1);
    if (listId == null) {
      return null;
    }
    final list = blockFor(listId);
    if (list == null || !list.contains('XCConfigurationList')) {
      return null;
    }

    final names = <String>{};
    final ids = RegExp(
      r'\b[A-F0-9]{24}\b',
    ).allMatches(list).map((match) => match.group(0)!).toSet()..remove(listId);
    for (final id in ids) {
      final config = blockFor(id);
      if (config == null || !config.contains('XCBuildConfiguration')) {
        continue;
      }
      final name = RegExp(
        r'\n\t\t\tname = "?([^";\n]+)"?;',
      ).firstMatch(config)?.group(1);
      if (name != null) {
        names.add(name);
      }
    }
    return names.isEmpty ? null : names;
  }

  /// Deployment-target values grouped by owner: build configurations with
  /// TEST_TARGET_NAME belong to RunnerUITests, the rest to the app targets.
  ///
  /// Apps legitimately vary the target across flavors (observed in the
  /// field: dev 14.0, prod 15.0), so a mismatch is only suspicious when the
  /// UITests configs use a value the app never uses.
  ({Set<String> uiTests, Set<String> app}) deploymentTargets(String variable) {
    final uiTests = <String>{};
    final app = <String>{};
    final blocks = RegExp(
      r'= \{\s*isa = XCBuildConfiguration;.*?\n\t\t\};',
      dotAll: true,
    ).allMatches(pbxproj ?? '').map((match) => match.group(0)!);
    for (final block in blocks) {
      final version = RegExp(
        '$variable = ([\\d.]+);',
      ).firstMatch(block)?.group(1);
      if (version == null) {
        continue;
      }
      (block.contains('TEST_TARGET_NAME') ? uiTests : app).add(version);
    }
    return (uiTests: uiTests, app: app);
  }

  /// The object block that [id] points at, or null when it cannot be
  /// isolated.
  String? blockFor(String id) {
    final contents = pbxproj;
    if (contents == null) {
      return null;
    }
    return RegExp(
      '$id /\\*[^*]*\\*/ = \\{.*?\\n\\t\\t\\};',
      dotAll: true,
    ).firstMatch(contents)?.group(0);
  }

  /// Object blocks referenced from the RunnerUITests target block (one hop),
  /// e.g. its build phases. Null when the target block cannot be isolated.
  ///
  /// Scoping probes to these blocks matters: the standard Runner target has
  /// its own xcode_backend phases and package linkage, so a whole-pbxproj
  /// probe would pass even when RunnerUITests is missing them.
  List<String>? get runnerUITestsReferencedBlocks {
    final block = runnerUITestsTargetBlock;
    if (block == null) {
      return null;
    }
    return RegExp(r'\b[A-F0-9]{24}\b')
        .allMatches(block)
        .map((match) => match.group(0)!)
        .toSet()
        .map(blockFor)
        .nonNulls
        .toList();
  }

  /// Whether the two Flutter script phases on RunnerUITests satisfy the one
  /// load-bearing ordering constraint: the build script must run before the
  /// embed script, because embedding needs the artifacts build produces.
  /// The buildPhases array order is the phase order.
  ///
  /// The docs screenshot additionally places build before Compile Sources,
  /// but that part is style, not mechanics — the test bundle's own sources
  /// don't depend on the Flutter artifacts, and projects deviating from the
  /// screenshot demonstrably work.
  ///
  /// Null when either script phase cannot be identified — callers should
  /// then fall back to the manual-verify notice.
  bool? scriptPhasesOrdered({
    required RegExp buildScript,
    required RegExp embedScript,
  }) {
    final block = runnerUITestsTargetBlock;
    if (block == null) {
      return null;
    }
    final list = RegExp(
      r'buildPhases = \((.*?)\);',
      dotAll: true,
    ).firstMatch(block)?.group(1);
    if (list == null) {
      return null;
    }

    int? buildIndex;
    int? embedIndex;
    final ids = RegExp(
      r'\b[A-F0-9]{24}\b',
    ).allMatches(list).map((match) => match.group(0)!).toList();
    for (final (index, id) in ids.indexed) {
      final referenced = blockFor(id);
      if (referenced == null || !referenced.contains('PBXShellScriptBuildPhase')) {
        continue;
      }
      if (buildScript.hasMatch(referenced)) {
        buildIndex = index;
      } else if (embedScript.hasMatch(referenced)) {
        embedIndex = index;
      }
    }

    if (buildIndex == null || embedIndex == null) {
      return null;
    }
    return buildIndex < embedIndex;
  }

  /// Whether FlutterGeneratedPluginSwiftPackage is linked to RunnerUITests.
  /// Null when the target block cannot be isolated.
  ///
  /// Xcode records the linkage either directly in the target block
  /// (packageProductDependencies) or in a referenced PBXFrameworksBuildPhase
  /// object — the layout leancode_flutter_template uses — so referenced
  /// blocks are followed one hop.
  bool? get spmLinkedToRunnerUITests {
    final block = runnerUITestsTargetBlock;
    if (block == null) {
      return null;
    }
    if (block.contains('FlutterGeneratedPluginSwiftPackage')) {
      return true;
    }
    return runnerUITestsReferencedBlocks!.any(
      (referenced) =>
          referenced.contains('PBXFrameworksBuildPhase') &&
          referenced.contains('FlutterGeneratedPluginSwiftPackage'),
    );
  }

  /// The PBXShellScriptBuildPhase blocks of the RunnerUITests target, or
  /// null when the target block cannot be isolated.
  List<String>? get runnerUITestsScriptPhases => runnerUITestsReferencedBlocks
      ?.where((block) => block.contains('PBXShellScriptBuildPhase'))
      .toList();
}
