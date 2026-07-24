import 'package:file/file.dart';
import 'package:path/path.dart' show join;
import 'package:patrol_cli/src/crossplatform/test_manifest.dart';

/// The result of [AndroidTestCodegen.generate].
class AndroidCodegenResult {
  AndroidCodegenResult({
    required this.fullyQualifiedClassName,
    required this.outputPath,
    required this.testCount,
  });

  /// Fully-qualified name of the generated JUnit class, for example
  /// `pl.leancode.patrol.e2e_app.PatrolGeneratedTests`. Used to select only the
  /// generated class when running the tests (the Android analog of iOS
  /// `-only-testing`).
  final String fullyQualifiedClassName;

  /// Absolute path of the generated `.java` file.
  final String outputPath;

  /// Number of generated `@Test` methods.
  final int testCount;
}

/// Generates a static JUnit4 test class from a build-time test manifest, so each
/// Dart test becomes a real, statically-discoverable native `@Test` method.
///
/// This mirrors the iOS `XcodeTestCodegen`. It replaces the runtime discovery
/// used by the parameterized host class (`@RunWith(Parameterized.class)` +
/// `listDartTests()` over HTTP) with compiled methods that JUnit discovers
/// natively. Two payoffs:
///  * per-test selection for sharding via
///    `-Pandroid.testInstrumentationRunnerArguments.class=<fqcn>#<method>`;
///  * clean report entries - each test shows up under its own method name
///    instead of the parameterized `runDartTest[<name>]` wrapper.
///
/// The generated method name is a sanitized, unique Java identifier (Dart names
/// contain spaces, quotes and unicode); the verbatim Dart name is embedded in
/// the method body and handed to `runDartTest`, so the names the app receives
/// stay byte-identical to runtime discovery. The Android Test Orchestrator
/// 1.5.0 whitespace limitation is sidestepped for free (method names never
/// contain whitespace).
class AndroidTestCodegen {
  AndroidTestCodegen(this._fs);

  final FileSystem _fs;

  /// Reads the manifest JSON at [manifestPath] and writes the generated JUnit
  /// class into the app's `androidTest` source set, next to the existing host
  /// test class (the one referencing `PatrolJUnitRunner`), reusing its package.
  ///
  /// [androidDir] is the app's `android/` directory. Returns `null` when the
  /// androidTest source set / host test class cannot be located (the caller
  /// then falls back to the runtime discovery path).
  AndroidCodegenResult? generate({
    required String manifestPath,
    required Directory androidDir,
    String className = 'PatrolGeneratedTests',
  }) {
    final host = _locateHostTest(androidDir);
    if (host == null) {
      return null;
    }

    final tests = TestManifest.parse(
      _fs.file(manifestPath).readAsStringSync(),
    ).tests;

    final source = _render(host.packageName, className, tests);
    final output = _fs.file(join(host.directory.path, '$className.java'))
      ..createSync(recursive: true)
      ..writeAsStringSync(source);

    return AndroidCodegenResult(
      fullyQualifiedClassName: '${host.packageName}.$className',
      outputPath: output.path,
      testCount: tests.length,
    );
  }

  /// Finds the fully-qualified name of an already-generated class, without
  /// regenerating it. Used at execution time to build the class filter.
  String? findGeneratedClassName(
    Directory androidDir, {
    String className = 'PatrolGeneratedTests',
  }) {
    final host = _locateHostTest(androidDir);
    if (host == null) {
      return null;
    }
    final generated = _fs.file(join(host.directory.path, '$className.java'));
    if (!generated.existsSync()) {
      return null;
    }
    return '${host.packageName}.$className';
  }

  /// Locates the host instrumentation test (the file that references
  /// `PatrolJUnitRunner`) under `android/app/src/androidTest`, returning its
  /// directory and declared package.
  _HostTest? _locateHostTest(Directory androidDir) {
    final testRoot = androidDir
        .childDirectory('app')
        .childDirectory('src')
        .childDirectory('androidTest');
    if (!testRoot.existsSync()) {
      return null;
    }

    for (final entity in testRoot.listSync(recursive: true)) {
      if (entity is! File) {
        continue;
      }
      final path = entity.path;
      if (!path.endsWith('.java') && !path.endsWith('.kt')) {
        continue;
      }
      final content = entity.readAsStringSync();
      if (!content.contains('PatrolJUnitRunner')) {
        continue;
      }
      final packageName = _parsePackage(content);
      if (packageName == null) {
        continue;
      }
      return _HostTest(directory: entity.parent, packageName: packageName);
    }
    return null;
  }

  String? _parsePackage(String content) {
    final match = RegExp(
      r'^\s*package\s+([\w.]+)\s*;?\s*$',
      multiLine: true,
    ).firstMatch(content);
    return match?.group(1);
  }

  String _render(
    String packageName,
    String className,
    List<DiscoveredTest> tests,
  ) {
    final methodNames = generateAndroidMethodNames(tests);
    final buffer = StringBuffer()
      ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
      ..writeln('// Generated by `patrol build android` from the build-time '
          'test manifest.')
      ..writeln()
      ..writeln('package $packageName;')
      ..writeln()
      ..writeln('import androidx.test.platform.app.InstrumentationRegistry;')
      // androidx.test.runner.AndroidJUnit4 (deprecated but present in
      // androidx.test:runner, which the patrol plugin exposes as `api`) is used
      // instead of the ext:junit variant, which isn't on the androidTest
      // classpath. The @RunWith is required for AndroidJUnitRunner to enumerate
      // the class's @Test methods.
      ..writeln('import androidx.test.runner.AndroidJUnit4;')
      ..writeln('import org.junit.BeforeClass;')
      ..writeln('import org.junit.Test;')
      ..writeln('import org.junit.runner.RunWith;')
      ..writeln('import pl.leancode.patrol.PatrolJUnitRunner;')
      ..writeln()
      ..writeln('@RunWith(AndroidJUnit4.class)')
      ..writeln('public class $className {')
      ..writeln('    @BeforeClass')
      ..writeln('    public static void setUpAll() {')
      ..writeln('        PatrolJUnitRunner instrumentation = '
          '(PatrolJUnitRunner) InstrumentationRegistry.getInstrumentation();')
      ..writeln('        instrumentation.setUp(MainActivity.class);')
      ..writeln('        instrumentation.waitForPatrolAppService();')
      ..writeln('    }')
      ..writeln();

    for (var i = 0; i < tests.length; i++) {
      final test = tests[i];
      final methodName = methodNames[i];
      final literal = _javaStringLiteral(test.dartName);
      buffer
        ..writeln('    @Test')
        ..writeln('    public void $methodName() {')
        ..writeln('        runDartTest($literal, ${test.skip});')
        ..writeln('    }')
        ..writeln();
    }

    buffer
      ..writeln('    private void runDartTest(String name, boolean skip) {')
      ..writeln('        PatrolJUnitRunner instrumentation = '
          '(PatrolJUnitRunner) InstrumentationRegistry.getInstrumentation();')
      ..writeln('        instrumentation.runDartTest(name, skip);')
      ..writeln('    }')
      ..writeln('}');

    return buffer.toString();
  }

  String _javaStringLiteral(String value) {
    final escaped = value
        .replaceAll(r'\', r'\\')
        .replaceAll('"', r'\"')
        .replaceAll('\n', r'\n')
        .replaceAll('\r', r'\r')
        .replaceAll('\t', r'\t');
    return '"$escaped"';
  }
}

class _HostTest {
  _HostTest({required this.directory, required this.packageName});
  final Directory directory;
  final String packageName;
}
