import 'package:file/file.dart';
import 'package:path/path.dart' as path;
import 'package:patrol_cli/src/base/constants.dart' as constants;
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/crossplatform/video_recording_manager.dart';
import 'package:patrol_cli/src/dashboard/dashboard_collector.dart';
import 'package:patrol_cli/src/dashboard/dashboard_config.dart';
import 'package:patrol_cli/src/dashboard/dashboard_html_renderer.dart';
import 'package:patrol_cli/src/dashboard/dashboard_report.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_log/patrol_log.dart';

/// Collects a `patrol test` run and writes the HTML dashboard when it ends.
///
/// Both the Android and the iOS backend use this class the same way: chain
/// [wrapOnLogEntry] into the `PatrolLogReader` callbacks, then call [write]
/// once the run finished.
class DashboardReporter {
  /// Creates a reporter writing into [config]'s output path, resolved against
  /// [rootDirectory] when relative.
  DashboardReporter({
    required Directory rootDirectory,
    required Logger logger,
    required DashboardConfig config,
  }) : _rootDirectory = rootDirectory,
       _logger = logger,
       _config = config,
       _collector = DashboardCollector(testDirectory: config.testDirectory);

  final Directory _rootDirectory;
  final Logger _logger;
  final DashboardConfig _config;
  final DashboardCollector _collector;

  final DateTime _startedAt = DateTime.now();

  /// Returns an `onLogEntry` callback that feeds the report and then delegates
  /// to [next].
  void Function(Entry entry) wrapOnLogEntry(void Function(Entry entry)? next) =>
      _collector.wrapOnLogEntry(next);

  /// Attaches recorded videos to their tests, keyed by test name.
  void registerVideos(Map<String, String> videosByTestName) {
    for (final entry in videosByTestName.entries) {
      _collector.registerVideo(testName: entry.key, videoPath: entry.value);
    }
  }

  /// Writes the report and prints a clickable link to it.
  ///
  /// Videos of [videoRecordingManager], when there is one, are attached to
  /// their tests first.
  void writeAndLog({
    required String platform,
    required Device device,
    required String buildMode,
    VideoRecordingManager? videoRecordingManager,
    String? appDescription,
    String? flavor,
    String? nativeReportPath,
  }) {
    if (videoRecordingManager != null) {
      registerVideos(videoRecordingManager.savedVideosByTest);
    }

    final reportPath = write(
      platform: platform,
      deviceName: device.name,
      deviceId: device.id,
      buildMode: buildMode,
      appDescription: appDescription,
      flavor: flavor,
      nativeReportPath: nativeReportPath,
    );

    if (reportPath != null) {
      _logger.info('📊 HTML report: ${Uri.file(reportPath)}');
    }
  }

  /// Writes the report and returns its absolute path, or `null` when writing
  /// failed.
  ///
  /// A failure here must never fail the run, so problems are only warned about.
  String? write({
    required String platform,
    required String deviceName,
    required String deviceId,
    required String buildMode,
    String? appDescription,
    String? flavor,
    String? nativeReportPath,
  }) {
    final run = _collector.build(
      platform: platform,
      deviceName: deviceName,
      deviceId: deviceId,
      buildMode: buildMode,
      startedAt: _startedAt,
      duration: DateTime.now().difference(_startedAt),
      cliVersion: constants.version,
      appDescription: appDescription,
      flavor: flavor,
      nativeReportPath: nativeReportPath,
    );

    return writeRun(run);
  }

  /// Renders [run] into the configured file. Split out of [write] so it can be
  /// exercised without a real test run.
  String? writeRun(DashboardRun run) {
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
