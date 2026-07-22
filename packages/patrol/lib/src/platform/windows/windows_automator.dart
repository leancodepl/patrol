import 'package:flutter/painting.dart';
import 'package:patrol/src/platform/windows/windows_automator_config.dart';

/// Windows-specific OS automation (experimental).
///
/// Currently supports coordinate taps on the primary display via the Windows
/// native test host. Selector-based actions are planned.
abstract interface class WindowsAutomator {
  /// Configuration used by this automator.
  WindowsAutomatorConfig get config;

  /// Tells the Windows runner that PatrolAppService is ready.
  Future<void> markPatrolAppServiceReady();

  /// Taps at normalized primary-screen coordinates in the range `[0, 1]`.
  ///
  /// `(0, 0)` is the top-left of the primary display; `(1, 1)` is the
  /// bottom-right.
  Future<void> tapAt(Offset point);
}
