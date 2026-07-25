import 'package:file/memory.dart';
import 'package:patrol_cli/src/ios/xcode_test_codegen.dart';
import 'package:test/test.dart';

void main() {
  late MemoryFileSystem fs;

  setUp(() {
    fs = MemoryFileSystem.test();
  });

  String generate(String manifest) {
    fs.file('/manifest.json')
      ..createSync(recursive: true)
      ..writeAsStringSync(manifest);
    XcodeTestCodegen(fs).generate(
      manifestPath: '/manifest.json',
      outputPath: '/out/PatrolGeneratedTests.inc',
    );
    return fs.file('/out/PatrolGeneratedTests.inc').readAsStringSync();
  }

  test('emits one method per test with index-suffixed selectors', () {
    const manifest = '''
{"group":{"name":"","type":"group","skip":false,"entries":[
  {"name":"example_test","type":"group","skip":false,"entries":[
    {"name":"tap once shows one","type":"test","skip":false},
    {"name":"tap twice shows two","type":"test","skip":true}
  ]}
]}}
''';
    final count = XcodeTestCodegen(fs).generate(
      manifestPath: (fs.file('/m.json')
            ..createSync(recursive: true)
            ..writeAsStringSync(manifest))
          .path,
      outputPath: '/o.inc',
    );
    final source = fs.file('/o.inc').readAsStringSync();

    expect(count, 2);
    // Selector: test_<sanitized>_<zero-padded index>.
    expect(
      source,
      contains('- (void)test_example_test_tap_once_shows_one_0000 {'),
    );
    expect(
      source,
      contains('- (void)test_example_test_tap_twice_shows_two_0001 {'),
    );
    // The verbatim Dart name is embedded and handed to patrolExecuteDartTest:.
    expect(
      source,
      contains(
        '[self patrolExecuteDartTest:@"example_test tap once shows one" skip:NO];',
      ),
    );
    // Skip flag honored.
    expect(source, contains('skip:YES];'));
  });

  test('escapes quotes, backslashes, newlines, CR and tabs in the literal', () {
    // Raw string: the JSON value literally contains \"quote\", a \\ escape and a
    // \t escape, which jsonDecode turns into a quote, a backslash and a tab.
    const manifest = r'''
{"group":{"name":"","type":"group","skip":false,"entries":[
  {"name":"g","type":"group","skip":false,"entries":[
    {"name":"has \"quote\" and \\ and \t tab","type":"test","skip":false}
  ]}
]}}
''';
    final source = generate(manifest);

    expect(source, contains(r'\"quote\"'));
    expect(source, contains(r'\\'));
    expect(source, contains(r'\t'));
  });

  test('generates unique selectors for duplicate Dart names', () {
    const manifest = '''
{"group":{"name":"","type":"group","skip":false,"entries":[
  {"name":"g","type":"group","skip":false,"entries":[
    {"name":"same","type":"test","skip":false},
    {"name":"same","type":"test","skip":false}
  ]}
]}}
''';
    final source = generate(manifest);

    final selectors = RegExp(r'- \(void\)(\w+) \{')
        .allMatches(source)
        .map((m) => m.group(1))
        .toList();
    expect(selectors, hasLength(2));
    expect(selectors.toSet(), hasLength(2));
  });
}
