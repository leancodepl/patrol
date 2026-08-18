import 'package:file/file.dart';
import 'package:path/path.dart' as path;
import 'package:patrol_cli/src/base/constants.dart' as constants;
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/dashboard/dashboard_collector.dart';
import 'package:patrol_cli/src/dashboard/dashboard_config.dart';
import 'package:patrol_cli/src/dashboard/dashboard_html_renderer.dart';
import 'package:patrol_cli/src/dashboard/dashboard_report.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_log/patrol_log.dart';

/// Collects a `patrol test` run and writes the HTML dashboard when it ends.
///
/// Both the Android and the iOS backend use this class the same way: chain
/// [wrapOnLogEntry] into the `PatrolLogReader` callbacks, then call
/// [writeAndLog] once the run finished.
class DashboardReporter {
  /// Creates a reporter writing into [config]'s output path, resolved against
  /// [rootDirectory] when relative.
  DashboardReporter._({
    required Directory rootDirectory,
    required Logger logger,
    required DashboardConfig config,
  }) : _rootDirectory = rootDirectory,
       _logger = logger,
       _config = config,
       _collector = DashboardCollector(testDirectory: config.testDirectory);

  /// A reporter for [config], or `null` when no report was asked for.
  static DashboardReporter? maybe({
    required Directory rootDirectory,
    required Logger logger,
    required DashboardConfig? config,
  }) => config == null || !config.enabled
      ? null
      : DashboardReporter._(
          rootDirectory: rootDirectory,
          logger: logger,
          config: config,
        );

  final Directory _rootDirectory;
  final Logger _logger;
  final DashboardConfig _config;
  final DashboardCollector _collector;

  final DateTime _startedAt = DateTime.now();

  /// Returns an `onLogEntry` callback that feeds the report and then delegates
  /// to [next].
  void Function(Entry entry) wrapOnLogEntry(void Function(Entry entry)? next) =>
      _collector.wrapOnLogEntry(next);

  /// Attaches a saved recording to its test. Shaped to be passed straight to
  /// the video recording manager's `onVideoSaved` hook.
  void registerVideo({required String testName, required String videoPath}) =>
      _collector.registerVideo(testName: testName, videoPath: videoPath);

  /// Writes the report and prints a clickable link to it.
  void writeAndLog({
    required String platform,
    required Device device,
    required String buildMode,
    String? appDescription,
    String? flavor,
    String? nativeReportPath,
  }) {
    final reportPath = _write(
      _collector.build(
        platform: platform,
        deviceName: device.name,
        deviceId: device.id,
        buildMode: buildMode,
        startedAt: _startedAt,
        duration: DateTime.now().difference(_startedAt),
        cliVersion: constants.version,
        appDescription: appDescription,
        flavor: flavor,
        nativeReportPath: nativeReportPath,
      ),
    );

    if (reportPath != null) {
      _logger.info('📊 HTML report: ${Uri.file(reportPath)}');
    }
  }

  /// Renders [run] into the configured file and returns its absolute path, or
  /// `null` when writing failed.
  ///
  /// A failure here must never fail the run, so problems are only warned about.
  String? _write(DashboardRun run) {
    final outputPath = path.isAbsolute(_config.outputPath)
        ? _config.outputPath
        : path.join(_rootDirectory.path, _config.outputPath);

    try {
      final file = _rootDirectory.fileSystem.file(outputPath);
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(
        const DashboardHtmlRenderer().render(run, reportPath: outputPath),
      );
      return file.absolute.path;
    } catch (err) {
      _logger.warn('Failed to write the Patrol HTML report: $err');
      return null;
    }
  }
}
