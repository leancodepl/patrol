import 'package:patrol/patrol.dart';

import 'axe_automator.dart';

final _axeAutomators = Expando<AxeAutomator>();

/// Adds `$.axe` to Patrol's `$`.
extension PatrolAxeExtension on PatrolIntegrationTester {
  AxeAutomator get axe => _axeAutomators[this] ??= AxeAutomator(this);
}
