import 'package:patrol/patrol.dart';

import 'axe_automator.dart';

/// Adds `$.axe` to Patrol's `$` — the ENTIRE user-facing API surface of this
/// package. No change to core patrol is required to get this getter.
extension PatrolAxeExtension on PatrolIntegrationTester {
  /// Accessibility (axe DevTools) namespace for this test.
  AxeAutomator get axe => AxeAutomator(this);
}
