import 'package:patrol_cli/src/crossplatform/test_manifest.dart';
import 'package:test/test.dart';

void main() {
  test('flattens names byte-identically to listTestsFlat', () {
    // Two source files, nested groups. Top-level groups (the file-derived ones)
    // are NOT prefixed; deeper group names are space-joined into the test name.
    const manifest = '''
{"group":{"name":"","type":"group","skip":false,"entries":[
  {"name":"example_test","type":"group","skip":false,"entries":[
    {"name":"tap once shows one","type":"test","skip":false},
    {"name":"nested","type":"group","skip":false,"entries":[
      {"name":"deep test","type":"test","skip":true}
    ]}
  ]},
  {"name":"permissions.location_test","type":"group","skip":false,"entries":[
    {"name":"asks for location","type":"test","skip":false}
  ]}
]}}
''';

    final manifestModel = TestManifest.parse(manifest);
    final names = manifestModel.tests.map((t) => t.dartName).toList();

    expect(names, [
      'example_test tap once shows one',
      'example_test nested deep test',
      'permissions.location_test asks for location',
    ]);
  });

  test('captures skip flag and the top-level (file) group', () {
    const manifest = '''
{"group":{"name":"","type":"group","skip":false,"entries":[
  {"name":"example_test","type":"group","skip":false,"entries":[
    {"name":"a","type":"test","skip":false},
    {"name":"b","type":"test","skip":true}
  ]},
  {"name":"permissions.location_test","type":"group","skip":false,"entries":[
    {"name":"c","type":"test","skip":false}
  ]}
]}}
''';

    final tests = TestManifest.parse(manifest).tests;

    expect(tests.map((t) => t.skip).toList(), [false, true, false]);
    expect(tests.map((t) => t.topLevelGroup).toList(), [
      'example_test',
      'example_test',
      'permissions.location_test',
    ]);
  });

  test('deep tests keep the first-level group as their file', () {
    const manifest = '''
{"group":{"name":"","type":"group","skip":false,"entries":[
  {"name":"example_test","type":"group","skip":false,"entries":[
    {"name":"g1","type":"group","skip":false,"entries":[
      {"name":"g2","type":"group","skip":false,"entries":[
        {"name":"t","type":"test","skip":false}
      ]}
    ]}
  ]}
]}}
''';

    final tests = TestManifest.parse(manifest).tests;

    expect(tests, hasLength(1));
    expect(tests.single.dartName, 'example_test g1 g2 t');
    expect(tests.single.topLevelGroup, 'example_test');
  });

  test('handles an empty manifest', () {
    const manifest =
        '{"group":{"name":"","type":"group","skip":false,"entries":[]}}';
    expect(TestManifest.parse(manifest).tests, isEmpty);
  });

  test('Android method names never collide with Java keywords', () {
    const manifest = '''
{"group":{"name":"","type":"group","skip":false,"entries":[
  {"name":"class","type":"test","skip":false},
  {"name":"null","type":"test","skip":false},
  {"name":"static","type":"test","skip":false}
]}}
''';

    final methods = generateAndroidMethodNames(
      TestManifest.parse(manifest).tests,
    );

    // A method literally named `class` would not compile.
    expect(methods, ['t_class', 't_null', 't_static']);
  });

  group('selector generation', () {
    const manifest = '''
{"group":{"name":"","type":"group","skip":false,"entries":[
  {"name":"example_test","type":"group","skip":false,"entries":[
    {"name":"tap once shows one","type":"test","skip":false},
    {"name":"tap once shows one","type":"test","skip":false}
  ]}
]}}
''';

    test('iOS selectors are unique, index-suffixed and 1:1 with tests', () {
      final tests = TestManifest.parse(manifest).tests;
      final selectors = generateIosSelectors(tests);

      expect(selectors, hasLength(tests.length));
      // Zero-padded manifest index guarantees uniqueness even for duplicate
      // Dart names.
      expect(selectors, [
        'test_example_test_tap_once_shows_one_0000',
        'test_example_test_tap_once_shows_one_0001',
      ]);
      expect(selectors.toSet(), hasLength(selectors.length));
    });

    test(
      'Android method names prefer clean names, disambiguate on collision',
      () {
        final tests = TestManifest.parse(manifest).tests;
        final methods = generateAndroidMethodNames(tests);

        expect(methods, hasLength(tests.length));
        // First occurrence keeps the clean name; the collision gets the index.
        expect(methods, [
          'example_test_tap_once_shows_one',
          'example_test_tap_once_shows_one_1',
        ]);
        expect(methods.toSet(), hasLength(methods.length));
      },
    );
  });

  group('--only resolution', () {
    final tests = [
      DiscoveredTest(
        dartName: 'example_test tap once',
        skip: false,
        topLevelGroup: 'example_test',
      ),
      DiscoveredTest(
        dartName: 'example_test tap twice',
        skip: false,
        topLevelGroup: 'example_test',
      ),
      DiscoveredTest(
        dartName: 'permissions.location_test grants location',
        skip: false,
        topLevelGroup: 'permissions.location_test',
      ),
    ];

    test('an exact Dart name selects that single test', () {
      final selection = resolveOnlySelection(tests, ['example_test tap once']);

      expect(selection.classNames, isEmpty);
      expect(selection.tests.map((t) => t.selector), [
        'PatrolGeneratedTests_example_test/test_tap_once',
      ]);
      expect(selection.unmatched, isEmpty);
    });

    test('a test file selects its whole class, as one entry', () {
      final selection = resolveOnlySelection(tests, [
        'patrol_test/example_test.dart',
      ]);

      expect(selection.classNames, ['PatrolGeneratedTests_example_test']);
      expect(selection.tests, isEmpty);
    });

    test('a file in a subdirectory matches the dotted group name', () {
      final selection = resolveOnlySelection(tests, [
        'patrol_test/permissions/location_test.dart',
      ]);

      expect(selection.classNames, [
        'PatrolGeneratedTests_permissions_location_test',
      ]);
    });

    test('absolute paths, ./ prefixes and backslashes all match', () {
      for (final entry in [
        '/Users/me/app/patrol_test/example_test.dart',
        './patrol_test/example_test.dart',
        r'patrol_test\example_test.dart',
        'example_test.dart',
      ]) {
        expect(resolveOnlySelection(tests, [entry]).classNames, [
          'PatrolGeneratedTests_example_test',
        ], reason: entry);
      }
    });

    test('a file wins over its own tests, so nothing runs twice', () {
      final selection = resolveOnlySelection(tests, [
        'patrol_test/example_test.dart',
        'example_test tap once',
      ]);

      expect(selection.classNames, ['PatrolGeneratedTests_example_test']);
      expect(selection.tests, isEmpty);
    });

    test('files and single tests can be mixed', () {
      final selection = resolveOnlySelection(tests, [
        'patrol_test/example_test.dart',
        'permissions.location_test grants location',
      ]);

      expect(selection.classNames, ['PatrolGeneratedTests_example_test']);
      expect(selection.tests.map((t) => t.qualified), [
        'PatrolGeneratedTests_permissions_location_test#test_grants_location',
      ]);
    });

    test('unknown entries are reported, not silently dropped', () {
      final selection = resolveOnlySelection(tests, [
        'patrol_test/nope_test.dart',
        'example_test tap once',
      ]);

      expect(selection.unmatched, ['patrol_test/nope_test.dart']);
      expect(selection.tests, hasLength(1));
    });
  });
}
