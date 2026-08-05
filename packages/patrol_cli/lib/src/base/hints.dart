/// Failure-time pointers to `patrol validate`.
///
/// `patrol test` and `patrol build` never run setup validation themselves —
/// on failure signals they only print these hints. A heuristic validator
/// blocking every build on a false positive would erode trust in the CLI.
library;

/// Printed after a failed build or test run.
const validateHint =
    'Setup problem? Run `patrol validate` to check your project for missing '
    'Patrol configuration.';

/// Printed when a run finishes but no tests were discovered — the classic
/// symptom of incomplete native setup (issue #843).
const zeroTestsHint =
    'No tests were discovered (Total: 0). This usually means the native '
    'setup is incomplete — run `patrol validate` to check your Patrol setup.';

/// Web variant — web has no native setup, so zero tests usually means the
/// test files are not where Patrol looks.
const zeroTestsHintWeb =
    'No tests were discovered (Total: 0). Check that your test files are in '
    'the configured test directory — run `patrol validate` to check your '
    'Patrol setup.';
