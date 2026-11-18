import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/logger.dart';

/// Decides whether a build uses build-time test discovery: the
/// `--[no-]emit-test-manifest` [flag] wins, then `patrol.emit_test_manifest`
/// from pubspec.yaml ([pubspecValue]), then [defaultValue].
///
/// Tests under `integration_test/` can't be discovered on the host, because
/// `flutter test` runs that directory on a device. There the default falls back
/// to runtime discovery with a warning, and an explicit opt-in fails.
bool resolveEmitTestManifest({
  required bool? flag,
  required bool? pubspecValue,
  required String testDirectory,
  required Logger logger,
  bool defaultValue = true,
}) {
  final explicit = flag ?? pubspecValue;
  if (!isUnderIntegrationTest(testDirectory)) {
    return explicit ?? defaultValue;
  }

  if (explicit ?? false) {
    throwToolExit(
      'Build-time test discovery needs the tests outside integration_test/ '
      '(the test directory is "$testDirectory"). Move them to patrol_test/ '
      '(or set patrol.test_directory), or pass --no-emit-test-manifest to use '
      'runtime discovery.',
    );
  }
  if (explicit == null && defaultValue) {
    logger.warn(
      'Using runtime test discovery: tests in "$testDirectory" can\'t be '
      'discovered at build time. Move them out of integration_test/ to use '
      'build-time discovery, or set patrol.emit_test_manifest: false in '
      'pubspec.yaml to hide this warning.',
    );
  }
  return false;
}

/// Whether [testDirectory] is `integration_test` or a directory inside it.
bool isUnderIntegrationTest(String testDirectory) {
  final segments = testDirectory
      .replaceAll(r'\', '/')
      .split('/')
      .where((segment) => segment.isNotEmpty && segment != '.');
  return segments.isNotEmpty && segments.first == 'integration_test';
}
