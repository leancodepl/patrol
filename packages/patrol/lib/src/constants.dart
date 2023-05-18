import 'package:meta/meta.dart';

/// An escape hatch if, for any reason, the test reporting has to be
/// disabled.
///
/// Patrol CLI doesn't pass this dart define anywhere.
@internal
const bool shouldReportResultsToNative = bool.fromEnvironment(
  'PATROL_INTEGRATION_TEST_SHOULD_REPORT_RESULTS_TO_NATIVE',
  defaultValue: true,
);

/// Whether Hot Restart is enabled.
@internal
const bool hotRestartEnabled = bool.fromEnvironment('PATROL_HOT_RESTART');
