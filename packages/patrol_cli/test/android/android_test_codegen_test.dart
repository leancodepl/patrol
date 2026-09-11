import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:patrol_cli/src/android/android_test_codegen.dart';
import 'package:test/test.dart';

void main() {
  late MemoryFileSystem fs;

  /// Reads one generated per-file test class out of [result]'s directory.
  String sourceOf(
    FileSystem fs,
    AndroidCodegenResult result, [
    String className = 'PatrolGeneratedTests_example_test',
  ]) => fs
      .file(fs.path.join(result.directoryPath, '$className.java'))
      .readAsStringSync();

  const manifest = r'''
{"group":{"name":"","type":"group","skip":false,"entries":[
  {"name":"example_test","type":"group","skip":false,"entries":[
    {"name":"tap once shows one","type":"test","skip":false},
    {"name":"tap twice \"quoted\" shows two","type":"test","skip":true},
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
    // One class per Dart test file, named after the file.
    expect(result!.fullyQualifiedClassNames, [
      'pl.leancode.patrol.e2e_app.PatrolGeneratedTests_example_test',
    ]);
    expect(result.testCount, 3);

    final source = sourceOf(fs, result);
    expect(source, contains('package pl.leancode.patrol.e2e_app;'));
    // @RunWith is required for AndroidJUnitRunner to enumerate the @Test methods.
    expect(source, contains('@RunWith(AndroidJUnit4.class)'));
    expect(source, contains('import androidx.test.runner.AndroidJUnit4;'));
    expect(
      source,
      contains('public class PatrolGeneratedTests_example_test {'),
    );
    // setUpGenerated: the generated class must not stand down for the host.
    expect(
      source,
      contains('instrumentation.setUpGenerated(MainActivity.class);'),
    );

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
    final source = sourceOf(fs, result!);

    // Two tests both named "tap once shows one" -> two distinct method names.
    final methodDecls = RegExp(
      r'public void (\w+)\(\)',
    ).allMatches(source).map((m) => m.group(1)).toList();
    expect(methodDecls.toSet().length, methodDecls.length);
  });

  test('findGeneratedClassNames returns the FQNs only after generation', () {
    final codegen = AndroidTestCodegen(fs);
    expect(codegen.findGeneratedClassNames(fs.directory('/android')), isEmpty);

    codegen.generate(
      manifestPath: '/manifest.json',
      androidDir: fs.directory('/android'),
    );

    expect(codegen.findGeneratedClassNames(fs.directory('/android')), [
      'pl.leancode.patrol.e2e_app.PatrolGeneratedTests_example_test',
    ]);
  });

  test('method names drop the file prefix the class already carries', () {
    final result = AndroidTestCodegen(fs).generate(
      manifestPath: '/manifest.json',
      androidDir: fs.directory('/android'),
    );

    expect(
      sourceOf(fs, result!),
      contains('public void test_tap_once_shows_one()'),
    );
  });

  test('the marker class holds no tests, so only per-file classes run', () {
    final result = AndroidTestCodegen(fs).generate(
      manifestPath: '/manifest.json',
      androidDir: fs.directory('/android'),
    );
    final marker = sourceOf(fs, result!, 'PatrolGeneratedTests');

    expect(marker, contains('public final class PatrolGeneratedTests {'));
    expect(marker, isNot(contains('@Test')));
    expect(marker, isNot(contains('@RunWith')));
    // It is not reported as a runnable class either.
    expect(result.fullyQualifiedClassNames, [
      'pl.leancode.patrol.e2e_app.PatrolGeneratedTests_example_test',
    ]);
  });

  test('uses a non-default activity from the host and replicates its import', () {
    final customFs = MemoryFileSystem.test();
    customFs.file('/manifest.json')
      ..createSync(recursive: true)
      ..writeAsStringSync(manifest);
    customFs.file(
        '/android/app/src/androidTest/java/pl/leancode/patrol/e2e_app/MainActivityTest.java',
      )
      ..createSync(recursive: true)
      ..writeAsStringSync('''
package pl.leancode.patrol.e2e_app;
import androidx.test.core.app.ActivityScenario;
import io.flutter.embedding.android.FlutterActivity;
import pl.leancode.patrol.PatrolJUnitRunner;
public class MainActivityTest {
  public void setUp() {
    instrumentation.setUp(FlutterActivity.class);
  }
}
''');

    final result = AndroidTestCodegen(customFs).generate(
      manifestPath: '/manifest.json',
      androidDir: customFs.directory('/android'),
    );

    final source = sourceOf(customFs, result!);
    // The generated class references the host's activity, not the default.
    expect(
      source,
      contains('instrumentation.setUpGenerated(FlutterActivity.class);'),
    );
    expect(source, isNot(contains('setUpGenerated(MainActivity.class)')));
    // And replicates the host's import so it compiles.
    expect(
      source,
      contains('import io.flutter.embedding.android.FlutterActivity;'),
    );
  });

  test('ignores a runner subclass sitting next to the host test', () {
    // The documented Allure setup puts AllurePatrolJUnitRunner.kt in the same
    // directory as the host test; it references (and extends) PatrolJUnitRunner
    // but is not the host. Sorted listing puts it FIRST, so a naive locator
    // would pick it and lose the host's activity.
    final fs2 = MemoryFileSystem.test();
    fs2.file('/manifest.json')
      ..createSync(recursive: true)
      ..writeAsStringSync(manifest);
    const dir = '/android/app/src/androidTest/java/pl/leancode/patrol/e2e_app';
    fs2.file('$dir/AllurePatrolJUnitRunner.kt')
      ..createSync(recursive: true)
      ..writeAsStringSync('''
package pl.leancode.patrol.e2e_app
import pl.leancode.patrol.PatrolJUnitRunner
class AllurePatrolJUnitRunner : PatrolJUnitRunner() {}
''');
    fs2.file('$dir/MainActivityTest.java')
      ..createSync(recursive: true)
      ..writeAsStringSync('''
package pl.leancode.patrol.e2e_app;
import io.flutter.embedding.android.FlutterActivity;
import pl.leancode.patrol.PatrolJUnitRunner;
public class MainActivityTest {
  @Parameters
  public static Object[] testCases() {
    PatrolJUnitRunner instrumentation =
        (PatrolJUnitRunner) InstrumentationRegistry.getInstrumentation();
    instrumentation.setUp(FlutterActivity.class);
    return instrumentation.listDartTests();
  }
}
''');

    final result = AndroidTestCodegen(fs2).generate(
      manifestPath: '/manifest.json',
      androidDir: fs2.directory('/android'),
    );

    expect(result, isNotNull);
    final source = sourceOf(fs2, result!);
    // The host's activity was used, i.e. the host (not the runner) was located.
    expect(
      source,
      contains('instrumentation.setUpGenerated(FlutterActivity.class);'),
    );
  });

  test('works on a Windows-style filesystem', () {
    // Regression: paths were joined with the *host* platform separator instead
    // of the filesystem's, so on Windows the generated file landed under a
    // mangled name, the locator then mistook it for the host test, and
    // findGeneratedClassName looked in the wrong directory and returned null.
    final winFs = MemoryFileSystem.test(style: FileSystemStyle.windows);
    winFs.file(r'C:\manifest.json')
      ..createSync(recursive: true)
      ..writeAsStringSync(manifest);
    winFs.file(
        r'C:\android\app\src\androidTest\java\pl\leancode\patrol\e2e_app\MainActivityTest.java',
      )
      ..createSync(recursive: true)
      ..writeAsStringSync('''
package pl.leancode.patrol.e2e_app;
import pl.leancode.patrol.PatrolJUnitRunner;
public class MainActivityTest {}
''');

    final codegen = AndroidTestCodegen(winFs);
    final androidDir = winFs.directory(r'C:\android');

    expect(codegen.findGeneratedClassNames(androidDir), isEmpty);

    final result = codegen.generate(
      manifestPath: r'C:\manifest.json',
      androidDir: androidDir,
    );
    expect(result, isNotNull);
    expect(result!.fullyQualifiedClassNames, [
      'pl.leancode.patrol.e2e_app.PatrolGeneratedTests_example_test',
    ]);

    // The generated files must be found again from the same host directory.
    expect(codegen.findGeneratedClassNames(androidDir), [
      'pl.leancode.patrol.e2e_app.PatrolGeneratedTests_example_test',
    ]);
    expect(codegen.deleteGenerated(androidDir), isTrue);
    expect(codegen.findGeneratedClassNames(androidDir), isEmpty);
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
