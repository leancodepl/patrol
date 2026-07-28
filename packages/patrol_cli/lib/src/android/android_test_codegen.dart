import 'package:file/file.dart';
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

  /// First line of every generated file, used both when rendering and when
  /// recognizing (and skipping) our own output while locating the host test.
  static const _generatedMarker = '// GENERATED CODE - DO NOT MODIFY BY HAND';

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
    final host = _locateHostTest(androidDir, generatedClassName: className);
    if (host == null) {
      return null;
    }

    final tests = TestManifest.parse(
      _fs.file(manifestPath).readAsStringSync(),
    ).tests;

    final source = _render(
      host.packageName,
      className,
      tests,
      activityClass: host.activityClass,
      activityImport: host.activityImport,
    );
    final output =
        _fs.file(_fs.path.join(host.directory.path, '$className.java'))
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
    final host = _locateHostTest(androidDir, generatedClassName: className);
    if (host == null) {
      return null;
    }
    final generated = _fs.file(
      _fs.path.join(host.directory.path, '$className.java'),
    );
    if (!generated.existsSync()) {
      return null;
    }
    return '${host.packageName}.$className';
  }

  /// Deletes a previously generated class, if present. Returns `true` when a
  /// file was removed. Used to avoid a stale generated class lingering after a
  /// failed discovery or when the user opts out of build-time discovery (which
  /// would otherwise make the runtime host class and the stale generated class
  /// both run, double-running every test).
  bool deleteGenerated(
    Directory androidDir, {
    String className = 'PatrolGeneratedTests',
  }) {
    final host = _locateHostTest(androidDir, generatedClassName: className);
    if (host == null) {
      return false;
    }
    final generated = _fs.file(
      _fs.path.join(host.directory.path, '$className.java'),
    );
    if (!generated.existsSync()) {
      return false;
    }
    generated.deleteSync();
    return true;
  }

  /// Locates the host instrumentation test under `android/app/src/androidTest`,
  /// returning its directory, declared package and the activity it launches.
  ///
  /// Merely referencing `PatrolJUnitRunner` is not enough to identify the host:
  /// a project may also *subclass* the runner next to the host test (the
  /// documented Allure setup puts `AllurePatrolJUnitRunner.kt` in the same
  /// directory), and our own generated class references it too. So runner
  /// declarations and the generated class are skipped, and the host is
  /// recognized by how it *uses* the runner (`getInstrumentation()` plus
  /// `setUp(...)`/`listDartTests()`). Candidates are sorted by path so the
  /// choice never depends on filesystem listing order.
  _HostTest? _locateHostTest(
    Directory androidDir, {
    String generatedClassName = 'PatrolGeneratedTests',
  }) {
    final testRoot = androidDir
        .childDirectory('app')
        .childDirectory('src')
        .childDirectory('androidTest');
    if (!testRoot.existsSync()) {
      return null;
    }

    final sources =
        testRoot
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.java') || f.path.endsWith('.kt'))
            .where(
              (f) =>
                  f.basename != '$generatedClassName.java' &&
                  f.basename != '$generatedClassName.kt',
            )
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));

    _HostTest? weakMatch;
    for (final entity in sources) {
      final content = entity.readAsStringSync();
      if (!content.contains('PatrolJUnitRunner')) {
        continue;
      }
      // Skip our own output regardless of where/how it was named: it drives the
      // runner exactly like the host does, so it would otherwise look like one.
      if (content.startsWith(_generatedMarker)) {
        continue;
      }
      // Skip runner declarations (e.g. `class AllurePatrolJUnitRunner :
      // PatrolJUnitRunner()` / `extends PatrolJUnitRunner`) - they reference the
      // runner but are not the test host.
      if (_declaresRunnerSubclass(content)) {
        continue;
      }
      final packageName = _parsePackage(content);
      if (packageName == null) {
        continue;
      }
      final activity = _parseActivity(content);
      final host = _HostTest(
        directory: entity.parent,
        packageName: packageName,
        activityClass: activity.className,
        activityImport: activity.import,
      );
      // A file that actually drives the runner is the host; anything else that
      // merely mentions it is only a fallback.
      if (content.contains('getInstrumentation()') &&
          (content.contains('setUp(') || content.contains('listDartTests('))) {
        return host;
      }
      weakMatch ??= host;
    }
    return weakMatch;
  }

  /// Whether [content] declares a class extending `PatrolJUnitRunner` (Java
  /// `extends PatrolJUnitRunner` or Kotlin `: PatrolJUnitRunner()`).
  bool _declaresRunnerSubclass(String content) {
    return RegExp(
      r'(extends\s+(\w+\.)*PatrolJUnitRunner\b)'
      r'|(:\s*(\w+\.)*PatrolJUnitRunner\s*\()',
    ).hasMatch(content);
  }

  String? _parsePackage(String content) {
    final match = RegExp(
      r'^\s*package\s+([\w.]+)\s*;?\s*$',
      multiLine: true,
    ).firstMatch(content);
    return match?.group(1);
  }

  /// Parses the activity class the host passes to `instrumentation.setUp(...)`.
  ///
  /// Patrol supports host tests that launch a non-default activity (e.g.
  /// `FlutterActivity.class` instead of `MainActivity.class`), so the generated
  /// class must mirror whatever the host uses or it won't compile. When the host
  /// references the class by its simple (unqualified) name, its matching
  /// `import` is captured too so the generated file can replicate it. Falls back
  /// to `MainActivity` (no import) when nothing matches.
  _HostActivity _parseActivity(String content) {
    final match = RegExp(
      r'setUp\(\s*([A-Za-z_][\w.]*)\.class',
    ).firstMatch(content);
    final token = match?.group(1) ?? 'MainActivity';

    // A fully-qualified reference (e.g. `com.example.FooActivity`) needs no
    // import; emit it verbatim.
    if (token.contains('.')) {
      return _HostActivity(className: token, import: null);
    }

    // Unqualified: replicate the host's import for that class, if any. When the
    // class lives in the host's own package it has no import and none is needed
    // (the generated class shares that package).
    final importMatch = RegExp(
      '^\\s*import\\s+([\\w.]+\\.$token)\\s*;',
      multiLine: true,
    ).firstMatch(content);
    return _HostActivity(className: token, import: importMatch?.group(1));
  }

  String _render(
    String packageName,
    String className,
    List<DiscoveredTest> tests, {
    String activityClass = 'MainActivity',
    String? activityImport,
  }) {
    final methodNames = generateAndroidMethodNames(tests);
    final buffer = StringBuffer()
      ..writeln(_generatedMarker)
      ..writeln(
        '// Generated by `patrol build android` from the build-time '
        'test manifest.',
      )
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
      ..writeln('import pl.leancode.patrol.PatrolJUnitRunner;');
    if (activityImport != null) {
      buffer.writeln('import $activityImport;');
    }
    buffer
      ..writeln()
      ..writeln('@RunWith(AndroidJUnit4.class)')
      ..writeln('public class $className {')
      ..writeln('    @BeforeClass')
      ..writeln('    public static void setUpAll() {')
      ..writeln(
        '        PatrolJUnitRunner instrumentation = '
        '(PatrolJUnitRunner) InstrumentationRegistry.getInstrumentation();',
      )
      ..writeln('        instrumentation.setUp($activityClass.class);')
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
      ..writeln(
        '        PatrolJUnitRunner instrumentation = '
        '(PatrolJUnitRunner) InstrumentationRegistry.getInstrumentation();',
      )
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
  _HostTest({
    required this.directory,
    required this.packageName,
    required this.activityClass,
    required this.activityImport,
  });
  final Directory directory;
  final String packageName;

  /// The activity token the host passes to `instrumentation.setUp(...)`, e.g.
  /// `MainActivity` or a fully-qualified `com.example.FooActivity`.
  final String activityClass;

  /// The `import` to replicate for [activityClass], or `null` when none is
  /// needed (fully-qualified reference, or same-package class).
  final String? activityImport;
}

class _HostActivity {
  _HostActivity({required this.className, required this.import});
  final String className;
  final String? import;
}
