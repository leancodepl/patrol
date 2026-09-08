import 'package:file/file.dart';
import 'package:patrol_cli/src/base/exceptions.dart';

/// Supported Android instrumentation layouts.
enum AndroidTestLayout {
  /// Self-instrumenting `:patrolTest` module. JUnit runs outside the app.
  selfInstrumenting,

  /// `:app` androidTest source set. JUnit runs in the app process.
  inApp,
}

/// Detects which Android instrumentation layout a project uses.
class AndroidTestLayoutDetector {
  const AndroidTestLayoutDetector(this.androidDirectory);

  final Directory androidDirectory;

  AndroidTestLayout detect() {
    final patrolTestDirectory = androidDirectory.childDirectory('patrolTest');
    if (!patrolTestDirectory.existsSync()) {
      return AndroidTestLayout.inApp;
    }

    final settings = [
      androidDirectory.childFile('settings.gradle.kts'),
      androidDirectory.childFile('settings.gradle'),
    ].where((file) => file.existsSync()).map((file) => file.readAsStringSync());

    final includesPatrolTest = settings.any((contents) {
      final withoutBlockComments = contents.replaceAll(
        RegExp(r'/\*.*?\*/', dotAll: true),
        '',
      );
      final withoutComments = withoutBlockComments
          .split('\n')
          .map((line) => line.split('//').first)
          .join('\n');
      return RegExp(
        r'''include\s*\(?[^)]*["']:patrolTest["']''',
      ).hasMatch(withoutComments);
    });
    if (!includesPatrolTest) {
      throwToolExit(
        'Found android/patrolTest, but it is not included in Android settings. '
        'Add `include(":patrolTest")` to android/settings.gradle.kts '
        '(or `include ":patrolTest"` to settings.gradle).',
      );
    }

    final sourceDirectory = patrolTestDirectory
        .childDirectory('src')
        .childDirectory('main');
    final hasHostSource =
        sourceDirectory.existsSync() &&
        sourceDirectory
            .listSync(recursive: true)
            .whereType<File>()
            .any((file) => file.path.endsWith('.java'));
    if (!hasHostSource) {
      throwToolExit(
        'The :patrolTest module is included, but no Java test host was found '
        'under android/patrolTest/src/main.',
      );
    }

    return AndroidTestLayout.selfInstrumenting;
  }
}
