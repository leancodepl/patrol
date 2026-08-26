/// Where and whether to write the HTML dashboard after a `patrol test` run.
class DashboardConfig {
  /// Creates a dashboard configuration.
  const DashboardConfig({
    required this.enabled,
    required this.outputPath,
    this.testDirectory,
  });

  /// Default location of the report, relative to the project root.
  static String defaultOutputPath(String testDirectory) =>
      '$testDirectory/reports/patrol_report.html';

  /// Whether the report should be generated.
  final bool enabled;

  /// Path of the generated file, absolute or relative to the project root.
  final String outputPath;

  /// Directory the test files live in, used to show each test's file path.
  final String? testDirectory;

  @override
  String toString() =>
      'DashboardConfig(enabled: $enabled, outputPath: $outputPath, '
      'testDirectory: $testDirectory)';
}
