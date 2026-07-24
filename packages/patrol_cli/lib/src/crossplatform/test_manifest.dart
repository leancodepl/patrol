import 'dart:convert';

import 'package:file/file.dart';

/// A single discovered Dart test, flattened to the exact name the native runner
/// uses to request its execution.
class DiscoveredTest {
  DiscoveredTest({
    required this.dartName,
    required this.skip,
    required this.topLevelGroup,
  });

  /// The flattened test name (group names joined with spaces), byte-identical to
  /// what runtime discovery (`listTestsFlat`) produces. This is what gets baked
  /// into the generated native method body and handed to `runDartTest`.
  final String dartName;

  /// Whether the test is marked `skip`.
  final bool skip;

  /// The first-level group name. The bundler wraps every test file's `main()` in
  /// a top-level `group('<file-derived-name>', ...)` (see
  /// `TestBundler.generateGroupsCode`), so this maps a test back to its source
  /// file, e.g. `permissions.permissions_location_test` ↔
  /// `permissions/permissions_location_test.dart`.
  final String topLevelGroup;
}

/// The parsed build-time test manifest (`patrol_test_manifest.json`).
///
/// The manifest is the serialized `DartGroupEntry` tree written by the bundle's
/// `patrol_test_explorer` in discovery mode. This is the single place that
/// flattens that tree, shared by the per-platform codegens
/// (`XcodeTestCodegen`, `AndroidTestCodegen`) and by the discovery reporter, so
/// the generated native names stay byte-identical everywhere.
class TestManifest {
  TestManifest(this.tests);

  factory TestManifest.fromJson(Map<String, dynamic> json) {
    final tree = json['group'] as Map<String, dynamic>;
    final out = <DiscoveredTest>[];
    _flatten(tree, '', null, out);
    return TestManifest(out);
  }

  factory TestManifest.parse(String jsonString) =>
      TestManifest.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);

  /// Loads the build-time manifest from its conventional path
  /// (`build/patrol/patrol_test_manifest.json`) under [rootDirectory], or
  /// returns `null` when it hasn't been generated yet.
  static TestManifest? loadFromBuild(Directory rootDirectory) {
    final file = rootDirectory
        .childDirectory('build')
        .childDirectory('patrol')
        .childFile('patrol_test_manifest.json');
    if (!file.existsSync()) {
      return null;
    }
    return TestManifest.parse(file.readAsStringSync());
  }

  /// All discovered tests, in manifest (declaration) order.
  final List<DiscoveredTest> tests;

  /// Flattens the group tree the exact same way as the native runners'
  /// `listTestsFlat`: group names joined with spaces, top-level groups not
  /// prefixed. Also threads down the first-level group so each test remembers
  /// which source file it came from.
  static void _flatten(
    Map<String, dynamic> group,
    String parentGroupName,
    String? topLevelGroup,
    List<DiscoveredTest> out,
  ) {
    final entries = (group['entries'] as List).cast<Map<String, dynamic>>();
    for (final entry in entries) {
      final name = entry['name'] as String;
      if (entry['type'] == 'test') {
        out.add(
          DiscoveredTest(
            dartName: '$parentGroupName $name',
            skip: entry['skip'] as bool,
            topLevelGroup: topLevelGroup ?? '',
          ),
        );
      } else {
        final childParent = parentGroupName.isEmpty
            ? name
            : '$parentGroupName $name';
        // At the root, `topLevelGroup` is null and becomes this group's name;
        // deeper groups keep the first-level name.
        _flatten(entry, childParent, topLevelGroup ?? name, out);
      }
    }
  }
}

/// The generated iOS XCTest selectors for [tests], aligned 1:1 with the input
/// order. Each is `test_<sanitized>_<index>` (see [_uniqueIosSelector]).
///
/// This is the single source of truth for iOS selectors, used both by the
/// codegen (`XcodeTestCodegen`) and by test execution (mapping a requested Dart
/// test name back to its `-only-testing` selector). Because the selector embeds
/// the manifest index, it is position-dependent and must be computed from the
/// full ordered [tests] list, not per-name in isolation.
List<String> generateIosSelectors(List<DiscoveredTest> tests) {
  final used = <String>{};
  return [
    for (var i = 0; i < tests.length; i++)
      _uniqueIosSelector(tests[i].dartName, i, used),
  ];
}

/// The generated Android JUnit method names for [tests], aligned 1:1 with the
/// input order (see [_uniqueAndroidMethodName]). Single source of truth for
/// Android method names, used by both codegen (`AndroidTestCodegen`) and
/// execution (mapping a Dart test name to `<fqcn>#<method>`).
List<String> generateAndroidMethodNames(List<DiscoveredTest> tests) {
  final used = <String>{};
  return [
    for (var i = 0; i < tests.length; i++)
      _uniqueAndroidMethodName(tests[i].dartName, i, used),
  ];
}

/// iOS selector: sanitized, unique Objective-C identifier. Dart names contain
/// spaces/quotes/unicode and can't be selectors; the zero-padded manifest index
/// guarantees uniqueness and stable ordering. The verbatim Dart name is what the
/// method body passes to `patrolExecuteDartTest:` - this is only the selector.
String _uniqueIosSelector(String dartName, int index, Set<String> used) {
  var sanitized = dartName
      .replaceAll(RegExp('[^A-Za-z0-9]+'), '_')
      .replaceAll(RegExp('_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  // Keep selectors readable but bounded.
  if (sanitized.length > 80) {
    sanitized = sanitized.substring(0, 80);
  }
  final base = 'test_${sanitized}_${index.toString().padLeft(4, '0')}';
  // The index already makes this unique; the suffix is purely defensive.
  var selector = base;
  var dedup = 0;
  while (used.contains(selector)) {
    dedup++;
    selector = '${base}_$dedup';
  }
  used.add(selector);
  return selector;
}

/// Android method name: sanitized, unique Java identifier. Prefers the clean
/// name and only appends the manifest index on collision, so most method names
/// are name-derivable (also sidesteps the Android Test Orchestrator 1.5.0
/// whitespace limitation - method names never contain whitespace).
String _uniqueAndroidMethodName(String dartName, int index, Set<String> used) {
  var sanitized = dartName
      .replaceAll(RegExp('[^A-Za-z0-9]+'), '_')
      .replaceAll(RegExp('_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  if (sanitized.isEmpty) {
    sanitized = 'test';
  }
  // A Java identifier cannot start with a digit.
  if (RegExp('^[0-9]').hasMatch(sanitized)) {
    sanitized = 't_$sanitized';
  }
  // Keep method names readable but bounded.
  if (sanitized.length > 120) {
    sanitized = sanitized.substring(0, 120);
  }
  // Prefer the clean name; only disambiguate on collision (two Dart names that
  // sanitize to the same identifier) with the stable manifest index.
  var name = sanitized;
  if (used.contains(name)) {
    name = '${sanitized}_$index';
  }
  var dedup = 0;
  while (used.contains(name)) {
    dedup++;
    name = '${sanitized}_${index}_$dedup';
  }
  used.add(name);
  return name;
}
