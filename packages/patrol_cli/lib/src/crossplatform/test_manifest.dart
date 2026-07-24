import 'dart:convert';

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
