/// How coverage should be collected for a single `patrol test` run.
enum CoverageMode {
  /// Coverage is disabled for this run.
  none,

  /// Coverage collected from the Dart VM service (Android, iOS).
  vm,

  /// Coverage collected from the browser's native JavaScript coverage and
  /// mapped back to Dart through source maps (web).
  web,
}
