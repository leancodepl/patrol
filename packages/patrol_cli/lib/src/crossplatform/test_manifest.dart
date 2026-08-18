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

/// A generated native test name, split into the class (derived from the Dart
/// test file) and the method (the test's name within that file). Identical on
/// both platforms: an Objective-C class with `test_` methods on iOS, a JUnit
/// class with `test_` methods on Android.
class GeneratedTestName {
  const GeneratedTestName({required this.className, required this.methodName});

  /// Simple class name, e.g. `PatrolGeneratedTests_permissions_location_test`.
  final String className;

  /// Method name, e.g. `test_grants_the_location_permission`.
  final String methodName;

  /// `<class>#<method>`, the shape `am instrument -e class` expects.
  String get qualified => '$className#$methodName';

  /// `<class>/<method>`, the shape `xcodebuild -only-testing` expects below the
  /// target.
  String get selector => '$className/$methodName';
}

/// Per-file native names for [tests], aligned 1:1 with the input order: one
/// class per Dart test file, and a method named after the test within that file.
///
/// Moving the file out of the method name gives reports a real hierarchy (class
/// = file, method = test), makes a whole file selectable with a single
/// `-e class` / `-only-testing` value, and scopes name collisions to one file
/// instead of the whole suite. Single source of truth for both codegens
/// (`XcodeTestCodegen`, `AndroidTestCodegen`) and both backends, which is what
/// keeps the class and method names identical on the two platforms.
List<GeneratedTestName> generatePerFileTestNames(
  List<DiscoveredTest> tests, {
  String classPrefix = 'PatrolGeneratedTests',
}) {
  final usedPerClass = <String, Set<String>>{};
  final out = <GeneratedTestName>[];
  for (var i = 0; i < tests.length; i++) {
    final test = tests[i];
    final className =
        '${classPrefix}_${_sanitizeIdentifier(test.topLevelGroup)}';
    final used = usedPerClass.putIfAbsent(className, () => <String>{});
    out.add(
      GeneratedTestName(
        className: className,
        methodName: _uniqueMethodName(_withinFileName(test), i, used),
      ),
    );
  }
  return out;
}

/// The test's name with its file-derived group stripped, e.g.
/// `example_test tap once` -> `tap once`. Falls back to the full name when the
/// group prefix isn't there (a test declared outside any file group).
String _withinFileName(DiscoveredTest test) {
  final prefix = '${test.topLevelGroup} ';
  final name = test.dartName;
  return name.startsWith(prefix) ? name.substring(prefix.length) : name;
}

/// `test_<sanitized>`, unique within its class. The `test_` prefix keeps the
/// method name identical to the iOS selector for the same test, and the manifest
/// index disambiguates two names that sanitize to the same identifier.
String _uniqueMethodName(String name, int index, Set<String> used) {
  var sanitized = _sanitizeIdentifier(name);
  if (sanitized.length > 120) {
    sanitized = sanitized.substring(0, 120);
  }
  var methodName = 'test_$sanitized';
  if (used.contains(methodName)) {
    methodName = '${methodName}_$index';
  }
  var dedup = 0;
  while (used.contains(methodName)) {
    dedup++;
    methodName = 'test_${sanitized}_${index}_$dedup';
  }
  used.add(methodName);
  return methodName;
}

/// The result of resolving `--only` entries against the manifest: whole classes
/// (a test file was requested) plus individual tests, and whatever matched
/// nothing so the caller can explain itself.
class OnlySelection {
  const OnlySelection({
    required this.classNames,
    required this.tests,
    required this.unmatched,
  });

  /// Generated classes to run in full, e.g. `PatrolGeneratedTests_example_test`.
  final List<String> classNames;

  /// Individually selected tests.
  final List<GeneratedTestName> tests;

  /// `--only` entries that matched neither a Dart test name nor a test file.
  final List<String> unmatched;

  bool get isEmpty => classNames.isEmpty && tests.isEmpty;
}

/// Resolves `--only` entries against [tests]. An entry is either the exact Dart
/// test name (as printed during discovery) or the path of a test file, which
/// selects that whole file - one class selector instead of one per test.
///
/// A file always wins over its own tests: requesting both the file and one of
/// its tests runs the file once, not the test twice.
OnlySelection resolveOnlySelection(
  List<DiscoveredTest> tests,
  List<String> only, {
  String classPrefix = 'PatrolGeneratedTests',
}) {
  final names = generatePerFileTestNames(tests, classPrefix: classPrefix);
  final classNames = <String>{};
  final selected = <int>{};
  final unmatched = <String>[];

  for (final entry in only) {
    final file = _asTestFilePath(entry);
    var matched = false;

    for (var i = 0; i < tests.length; i++) {
      final matchesFile =
          file != null && _isFileOf(file, tests[i].topLevelGroup);
      if (matchesFile) {
        classNames.add(names[i].className);
        matched = true;
      } else if (tests[i].dartName == entry) {
        selected.add(i);
        matched = true;
      }
    }

    if (!matched) {
      unmatched.add(entry);
    }
  }

  return OnlySelection(
    classNames: classNames.toList(),
    tests: [
      for (final i in selected)
        if (!classNames.contains(names[i].className)) names[i],
    ],
    unmatched: unmatched,
  );
}

/// The entry as a normalized, extension-less test file path, or `null` when it
/// isn't a `.dart` file reference at all (then it can only be a test name).
String? _asTestFilePath(String entry) {
  if (!entry.endsWith('.dart')) {
    return null;
  }
  final normalized = entry
      .replaceAll(r'\', '/')
      .replaceAll(RegExp(r'^\./'), '');
  return normalized.substring(0, normalized.length - '.dart'.length);
}

/// Whether [filePath] points at the file [topLevelGroup] was derived from. The
/// bundler turns `permissions/location_test.dart` into
/// `permissions.location_test`, so the group is compared as a path suffix and
/// any leading test directory in the input is ignored.
bool _isFileOf(String filePath, String topLevelGroup) {
  if (topLevelGroup.isEmpty) {
    return false;
  }
  final groupAsPath = topLevelGroup.replaceAll('.', '/');
  return filePath == groupAsPath || filePath.endsWith('/$groupAsPath');
}

/// Collapses everything that can't appear in an identifier into single
/// underscores.
String _sanitizeIdentifier(String value) => value
    .replaceAll(RegExp('[^A-Za-z0-9]+'), '_')
    .replaceAll(RegExp('_+'), '_')
    .replaceAll(RegExp(r'^_|_$'), '');
