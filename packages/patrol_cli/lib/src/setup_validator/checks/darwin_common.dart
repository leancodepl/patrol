import 'package:collection/collection.dart';
import 'package:patrol_cli/src/setup_validator/project_probe.dart';

/// Shared Xcode-project state for the iOS and macOS checks. The project name
/// is discovered (#1878); CocoaPods and SPM are detected independently.
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
    // The pbxproj marker is necessary and sufficient; a stale
    // swiftpm/Package.resolved must not count (real-world false positive).
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

  /// Deployment targets grouped by owner: configs with TEST_TARGET_NAME are
  /// RunnerUITests'. Apps legitimately vary the value across flavors.
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

  /// Blocks referenced from the RunnerUITests target (one hop). Scoping
  /// matters: the Runner target has its own phases and package linkage.
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

  /// True when the build script phase runs before the embed one — the only
  /// load-bearing order; the docs' full layout is style. Null if unidentified.
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
      if (referenced == null ||
          !referenced.contains('PBXShellScriptBuildPhase')) {
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

  /// Whether FlutterGeneratedPluginSwiftPackage is linked to RunnerUITests —
  /// Xcode may record it in a referenced PBXFrameworksBuildPhase (one hop).
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
