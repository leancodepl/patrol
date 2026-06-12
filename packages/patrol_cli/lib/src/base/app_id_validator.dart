import 'package:patrol_cli/src/base/logger.dart';

/// Logs a warning when the resolved app identifier (after CLI override
/// and `pubspec.yaml` fallback) is empty.
///
/// The identifier may come either from a CLI flag (e.g. `--bundle-id`)
/// or from the `patrol:` block in `pubspec.yaml`. When both are absent,
/// the iOS / macOS native test runner queries the OS with an empty
/// bundle id, producing the opaque error
/// `Failed to resolve query: Application  is not running` (note the
/// two spaces) — invisible without inspecting xcresult logs. The
/// Android side has an analogous failure mode with an empty
/// `package_name`. This helper surfaces a clear hint on stderr so the
/// user does not need to dig into platform-specific logs to find the
/// root cause.
///
/// This is only called from command code paths that actually need the
/// identifier (iOS / Android / macOS test backends). Web-only flows do
/// not call any of these helpers, so they remain silent.
void warnIfIosBundleIdMissing(String? bundleId, Logger logger) {
  if (bundleId == null || bundleId.isEmpty) {
    logger.warn(
      'iOS `bundle_id` is not set. The native test runner will fail '
      'with "Application  is not running" (note two spaces). '
      'Set `patrol: ios: bundle_id: ...` in pubspec.yaml or pass '
      '`--bundle-id` on the command line.',
    );
  }
}

void warnIfMacosBundleIdMissing(String? bundleId, Logger logger) {
  if (bundleId == null || bundleId.isEmpty) {
    logger.warn(
      'macOS `bundle_id` is not set. The native test runner will fail '
      'with an empty application id query. '
      'Set `patrol: macos: bundle_id: ...` in pubspec.yaml or pass '
      '`--bundle-id` on the command line.',
    );
  }
}

void warnIfAndroidPackageNameMissing(String? packageName, Logger logger) {
  if (packageName == null || packageName.isEmpty) {
    logger.warn(
      'Android `package_name` is not set. The native test runner will '
      'fail with an empty application id query. '
      'Set `patrol: android: package_name: ...` in pubspec.yaml or pass '
      '`--package-name` on the command line.',
    );
  }
}
