import 'package:file/memory.dart';
import 'package:patrol_cli/src/android/android_test_codegen.dart';
import 'package:test/test.dart';

void main() {
  late MemoryFileSystem fs;

  const manifest = '''
{"group":{"name":"","type":"group","skip":false,"entries":[
  {"name":"example_test","type":"group","skip":false,"entries":[
    {"name":"tap once shows one","type":"test","skip":false},
    {"name":"tap twice \\"quoted\\" shows two","type":"test","skip":true},
    {"name":"tap once shows one","type":"test","skip":false}
  ]}
]}}
''';

  setUp(() {
    fs = MemoryFileSystem.test();
    fs.file('/manifest.json')
      ..createSync(recursive: true)
      ..writeAsStringSync(manifest);
    fs
        .file(
          '/android/app/src/androidTest/java/pl/leancode/patrol/e2e_app/MainActivityTest.java',
        )
        .createSync(recursive: true);
    fs
        .file(
          '/android/app/src/androidTest/java/pl/leancode/patrol/e2e_app/MainActivityTest.java',
        )
        .writeAsStringSync('''
package pl.leancode.patrol.e2e_app;
import pl.leancode.patrol.PatrolJUnitRunner;
public class MainActivityTest {}
''');
  });

  test('generates a JUnit class next to the host test, in its package', () {
    final result = AndroidTestCodegen(fs).generate(
      manifestPath: '/manifest.json',
      androidDir: fs.directory('/android'),
    );

    expect(result, isNotNull);
    expect(
      result!.fullyQualifiedClassName,
      'pl.leancode.patrol.e2e_app.PatrolGeneratedTests',
    );
    expect(result.testCount, 3);

    final source = fs.file(result.outputPath).readAsStringSync();
    expect(source, contains('package pl.leancode.patrol.e2e_app;'));
    // @RunWith is required for AndroidJUnitRunner to enumerate the @Test methods.
    expect(source, contains('@RunWith(AndroidJUnit4.class)'));
    expect(source, contains('import androidx.test.runner.AndroidJUnit4;'));
    expect(source, contains('public class PatrolGeneratedTests {'));
    expect(source, contains('instrumentation.setUp(MainActivity.class);'));

    // The flattened Dart name (group + test, space-joined) is embedded verbatim.
    expect(
      source,
      contains('runDartTest("example_test tap once shows one", false);'),
    );
    // Skip flag is honored.
    expect(source, contains('shows two", true);'));
    // Quotes in Dart names are escaped in the Java string literal.
    expect(source, contains(r'\"quoted\"'));
  });

  test('disambiguates identical sanitized method names with the index', () {
    final result = AndroidTestCodegen(fs).generate(
      manifestPath: '/manifest.json',
      androidDir: fs.directory('/android'),
    );
    final source = fs.file(result!.outputPath).readAsStringSync();

    // Two tests both named "tap once shows one" -> two distinct method names.
    final methodDecls = RegExp(
      r'public void (\w+)\(\)',
    ).allMatches(source).map((m) => m.group(1)).toList();
    expect(methodDecls.toSet().length, methodDecls.length);
  });

  test('findGeneratedClassName returns the FQN only after generation', () {
    final codegen = AndroidTestCodegen(fs);
    expect(
      codegen.findGeneratedClassName(fs.directory('/android')),
      isNull,
    );

    codegen.generate(
      manifestPath: '/manifest.json',
      androidDir: fs.directory('/android'),
    );

    expect(
      codegen.findGeneratedClassName(fs.directory('/android')),
      'pl.leancode.patrol.e2e_app.PatrolGeneratedTests',
    );
  });

  test('returns null when no androidTest host class is present', () {
    final bare = MemoryFileSystem.test();
    bare.file('/manifest.json')
      ..createSync(recursive: true)
      ..writeAsStringSync(manifest);

    final result = AndroidTestCodegen(bare).generate(
      manifestPath: '/manifest.json',
      androidDir: bare.directory('/android'),
    );
    expect(result, isNull);
  });
}
