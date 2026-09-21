import 'package:meta/meta.dart';
import 'package:patrol/src/constants.dart' as constants;
import 'package:patrol/src/platform/current.dart' as current_platform;

/// A platform Patrol runs tests on.
enum PatrolTargetPlatform {
  /// Android.
  android,

  /// iOS.
  iOS,

  /// macOS.
  macOS,

  /// Web.
  web,
}

/// The platform this test run targets.
///
/// Use it instead of `defaultTargetPlatform` or `dart:io`'s `Platform` whenever
/// the platform decides **whether a test is registered** - most often `skip:`:
///
/// ```dart
/// patrolTest(
///   'shares the invoice',
///   ($) async { ... },
///   skip: patrolTargetPlatform == PatrolTargetPlatform.iOS,
/// );
/// ```
///
/// Build-time test discovery registers your tests twice: once on your computer,
/// to build the manifest, and once on the device. The Flutter and `dart:io`
/// getters answer for the machine they run on, so during discovery they describe
/// the host, and the manifest ends up disagreeing with the device about which
/// tests exist or are skipped. This one answers for the device in both runs.
PatrolTargetPlatform get patrolTargetPlatform {
  if (constants.testDiscoveryEnabled) {
    return parsePatrolTargetPlatform(constants.testDiscoveryPlatform);
  }
  if (current_platform.isWeb) {
    return PatrolTargetPlatform.web;
  }
  if (current_platform.isAndroid) {
    return PatrolTargetPlatform.android;
  }
  if (current_platform.isIOS) {
    return PatrolTargetPlatform.iOS;
  }
  if (current_platform.isMacOS) {
    return PatrolTargetPlatform.macOS;
  }

  throw UnsupportedError('Patrol does not support the current platform');
}

/// Parses the platform name `patrol_cli` passes to a build-time discovery run.
@internal
PatrolTargetPlatform parsePatrolTargetPlatform(String name) {
  return switch (name) {
    'android' => PatrolTargetPlatform.android,
    'ios' => PatrolTargetPlatform.iOS,
    'macos' => PatrolTargetPlatform.macOS,
    'web' => PatrolTargetPlatform.web,
    '' => throw StateError(
      'patrolTargetPlatform was used during build-time test discovery, but the '
      'discovery run did not report which platform it builds for. Update '
      'patrol_cli.',
    ),
    _ => throw StateError(
      'Build-time test discovery reported an unknown target platform "$name". '
      'Your patrol_cli and patrol versions are probably incompatible.',
    ),
  };
}
