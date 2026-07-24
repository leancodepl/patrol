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
    expect(
      tests.map((t) => t.topLevelGroup).toList(),
      ['example_test', 'example_test', 'permissions.location_test'],
    );
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
}
