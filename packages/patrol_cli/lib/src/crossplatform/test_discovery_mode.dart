import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/devices.dart';

/// Decides whether a build for [targetPlatform] uses build-time test discovery:
/// only Android and iOS have it, so any other platform gets `false`. Then the
/// `--[no-]emit-test-manifest` [flag] wins, then `patrol.emit_test_manifest`
/// from pubspec.yaml ([pubspecValue]), then [defaultValue].
///
/// When the project isn't set up for it (tests under `integration_test/`, or
/// [setupProblem], such as an iOS runner without the generated tests), the
/// default falls back to runtime discovery with a warning, and an explicit
/// opt-in fails. A default never breaks a build.
bool resolveEmitTestManifest({
  required TargetPlatform targetPlatform,
  required bool? flag,
  required bool? pubspecValue,
  required String testDirectory,
  required Logger logger,
  bool defaultValue = true,
  String? setupProblem,
}) {
  if (targetPlatform != TargetPlatform.android &&
      targetPlatform != TargetPlatform.iOS) {
    return false;
  }

  final explicit = flag ?? pubspecValue;
  final enabled = explicit ?? defaultValue;
  if (!enabled) {
    return false;
  }

  final problem = isUnderIntegrationTest(testDirectory)
      ? 'tests in "$testDirectory" can\'t be discovered at build time, because '
            'Flutter runs integration_test/ on a device. Move them out of '
            'integration_test/ (to patrol_test/, or set '
            'patrol.test_directory).'
      : setupProblem;
  if (problem == null) {
    return true;
  }

  if (explicit != null) {
    throwToolExit(
      'Build-time test discovery is on, but $problem\n'
      'Or pass --no-emit-test-manifest to use runtime discovery.',
    );
  }
  logger.warn(
    'Using runtime test discovery: $problem\n'
    'Or set patrol.emit_test_manifest: false in pubspec.yaml to hide this '
    'warning.',
  );
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
