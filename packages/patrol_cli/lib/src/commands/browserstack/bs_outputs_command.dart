import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/commands/browserstack/browserstack_client.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';

/// Exit codes for the outputs command.
class BsExitCodes {
  static const passed = 0;
  static const failed = 1;
  static const usageError = 2;
  static const buildError = 3;
  static const timedOut = 4;
  static const skipped = 5;
}

/// BrowserStack outputs command for patrol CLI.
///
/// Gets outputs and artifacts from a BrowserStack build.
class BsOutputsCommand extends PatrolCommand {
  BsOutputsCommand({required Logger logger}) : _logger = logger {
    argParser
      ..addOption(
        'credentials',
        help: 'BrowserStack credentials (username:access_key)',
      )
      ..addOption(
        'output-dir',
        help: 'Directory to save outputs',
        defaultsTo: '.',
      )
      ..addFlag(
        'only-report',
        help: "Only check build status, don't download artifacts",
        negatable: false,
      )
      ..addOption(
        'retry-limit',
        help: 'Max retry attempts for downloads',
        defaultsTo: '5',
      )
      ..addOption(
        'retry-delay',
        help: 'Delay between retries (seconds)',
        defaultsTo: '30',
      );
  }

  final Logger _logger;

  @override
  String get name => 'outputs';

  @override
  String? get docsName => 'bs';

  @override
  String get description =>
      'Get outputs and artifacts from a BrowserStack build.';

  @override
  String get invocation => 'patrol bs outputs <build_id> [options]';

  @override
  Future<int> run() async {
    final rest = argResults!.rest;

    if (rest.isEmpty) {
      _logger
        ..err('Build ID is required')
        ..info('Usage: patrol bs outputs <build_id> [options]');
      return BsExitCodes.usageError;
    }

    return execute(
      buildId: rest.first,
      outputDir: stringArg('output-dir') ?? '.',
      onlyReport: boolArg('only-report'),
      retryLimit: int.tryParse(stringArg('retry-limit') ?? '5') ?? 5,
      retryDelay: Duration(
        seconds: int.tryParse(stringArg('retry-delay') ?? '30') ?? 30,
      ),
      credentials:
          stringArg('credentials') ??
          Platform.environment['PATROL_BS_CREDENTIALS'] ??
          '',
    );
  }

  Future<int> execute({
    required String buildId,
    required String outputDir,
    required bool onlyReport,
    required int retryLimit,
    required Duration retryDelay,
    required String credentials,
    Duration? timeout,
  }) async {
    if (credentials.isEmpty) {
      _logger
        ..err('BrowserStack credentials not set')
        ..info('Set via: --credentials or PATROL_BS_CREDENTIALS env var');
      return BsExitCodes.usageError;
    }

    _logger.info('Build ID: $buildId');

    final client = BrowserStackClient(
      credentials: credentials,
      logger: _logger,
    );

    try {
      // Detect platform
      _logger.info('Detecting platform...');

      BsFramework? framework;
      Map<String, dynamic>? buildData;

      for (final f in BsFramework.values) {
        try {
          final response = await client.get(
            '/app-automate/${f.value}/v2/builds/$buildId',
          );
          if (response['error'] == null) {
            framework = f;
            buildData = response;
            break;
          }
        } catch (_) {}
      }

      if (framework == null || buildData == null) {
        _logger.err('Build not found in either XCUITest or Espresso');
        return BsExitCodes.usageError;
      }

      var currentBuildData = buildData;

      _logger.info('Platform: ${framework.platform} (${framework.value})');

      // Wait for build to complete
      var buildStatus = currentBuildData['status'] as String;
      final startTime = DateTime.now();

      while (buildStatus == 'queued' || buildStatus == 'running') {
        // Check timeout
        if (timeout != null) {
          final elapsed = DateTime.now().difference(startTime);
          if (elapsed >= timeout) {
            _logger.err(
              'Timeout reached after ${timeout.inMinutes} minutes. '
              'Build is still $buildStatus.',
            );
            return BsExitCodes.timedOut;
          }
        }

        _logger.info('Build is $buildStatus, waiting...');
        await Future<void>.delayed(retryDelay);

        currentBuildData = await client.get(
          '/app-automate/${framework.value}/v2/builds/$buildId',
        );
        buildStatus = currentBuildData['status'] as String;
      }

      // Get session ID
      final devices = currentBuildData['devices'] as List<dynamic>?;
      if (devices == null || devices.isEmpty) {
        _logger.err('No devices found in build data');
        return BsExitCodes.buildError;
      }

      final sessions =
          (devices.first as Map<String, dynamic>)['sessions'] as List<dynamic>?;
      if (sessions == null || sessions.isEmpty) {
        _logger.err('No sessions found in build data');
        return BsExitCodes.buildError;
      }

      final sessionId =
          (sessions.first as Map<String, dynamic>)['id'] as String?;
      if (sessionId == null) {
        _logger.err('Could not find session ID in build data');
        return BsExitCodes.buildError;
      }

      // If only-report mode, exit now
      if (onlyReport) {
        return _exitWithStatus(buildStatus);
      }

      // Get session details
      _logger.info('Getting session details...');

      final sessionResponse = await client.get(
        '/app-automate/${framework.value}/v2/builds/$buildId/sessions/$sessionId',
      );

      // Create output directory
      final outputDirectory = Directory(outputDir);
      if (!outputDirectory.existsSync()) {
        await outputDirectory.create(recursive: true);
      }

      var downloadErrors = 0;

      // Extract log URLs
      final testcases = sessionResponse['testcases'] as Map<String, dynamic>?;
      final data = testcases?['data'] as List<dynamic>?;
      final firstData = (data?.isNotEmpty ?? false)
          ? data!.first as Map<String, dynamic>?
          : null;
      final testcasesList = firstData?['testcases'] as List<dynamic>?;
      final firstTestcase = (testcasesList?.isNotEmpty ?? false)
          ? testcasesList!.first as Map<String, dynamic>?
          : null;

      final instrumentationLogsUrl =
          firstTestcase?['instrumentation_log'] as String?;
      final deviceLogsUrl = firstTestcase?['device_log'] as String?;

      // Download instrumentation logs
      if (instrumentationLogsUrl != null && instrumentationLogsUrl.isNotEmpty) {
        _logger.info('Downloading instrumentation logs...');
        try {
          await client.downloadFile(
            instrumentationLogsUrl,
            p.join(outputDir, '${framework.platform}_instrumentation_logs.txt'),
            maxRetries: retryLimit,
            retryDelay: retryDelay,
          );
          _logger.success(
            'Saved ${framework.platform}_instrumentation_logs.txt',
          );
        } catch (e) {
          _logger.warn('Failed to download instrumentation logs: $e');
          downloadErrors++;
        }
      }

      // Download device logs
      if (deviceLogsUrl != null && deviceLogsUrl.isNotEmpty) {
        _logger.info('Downloading device logs...');
        try {
          await client.downloadFile(
            deviceLogsUrl,
            p.join(outputDir, '${framework.platform}_device_logs.txt'),
            maxRetries: retryLimit,
            retryDelay: retryDelay,
          );
          _logger.success('Saved ${framework.platform}_device_logs.txt');
        } catch (e) {
          _logger.warn('Failed to download device logs: $e');
          downloadErrors++;
        }
      }

      // Download session video
      _logger.info('Downloading session video...');

      try {
        final videoResponse = await client.get(
          '/app-automate/sessions/$sessionId.json',
        );
        final automationSession =
            videoResponse['automation_session'] as Map<String, dynamic>?;
        final videoUrl = automationSession?['video_url'] as String?;

        if (videoUrl != null && videoUrl.isNotEmpty) {
          await client.downloadFile(
            videoUrl,
            p.join(outputDir, '${framework.platform}_session_video.mp4'),
            maxRetries: retryLimit,
            retryDelay: retryDelay,
          );
          _logger.success('Saved ${framework.platform}_session_video.mp4');
        } else {
          _logger.warn('No video URL available');
        }
      } catch (e) {
        _logger.warn('Failed to download session video: $e');
        downloadErrors++;
      }

      // Download report (platform-specific)
      _logger.info('Downloading test report...');

      if (framework == BsFramework.xcuitest) {
        final reportUrl =
            'https://api-cloud.browserstack.com/app-automate/xcuitest/v2/builds/$buildId/sessions/$sessionId/resultbundle';
        try {
          await client.downloadFile(
            reportUrl,
            p.join(outputDir, 'ios_xcresult_report.zip'),
            maxRetries: retryLimit,
            retryDelay: retryDelay,
            validate: _validateXcresult,
          );
          _logger.success('Saved ios_xcresult_report.zip');
        } catch (e) {
          _logger.warn('Failed to download xcresult report: $e');
          downloadErrors++;
        }
      } else {
        final reportUrl =
            'https://api-cloud.browserstack.com/app-automate/espresso/builds/$buildId/sessions/$sessionId/report';
        try {
          await client.downloadFile(
            reportUrl,
            p.join(outputDir, 'android_xml_report.xml'),
            maxRetries: retryLimit,
            retryDelay: retryDelay,
          );
          _logger.success('Saved android_xml_report.xml');
        } catch (e) {
          _logger.warn('Failed to download XML report: $e');
          downloadErrors++;
        }
      }

      // Check for download errors
      if (downloadErrors > 0) {
        _logger.warn('$downloadErrors download(s) failed');
      }

      if (outputDir == '.') {
        _logger.success('Outputs saved to current directory');
      } else {
        _logger.success('Outputs saved to: $outputDir');
      }

      return _exitWithStatus(buildStatus);
    } finally {
      client.close();
    }
  }

  bool _validateXcresult(File file) {
    if (!file.existsSync() || file.lengthSync() == 0) {
      _logger.warn('xcresult file is missing or empty');
      return false;
    }

    try {
      final bytes = file.readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);

      final hasInfoPlist = archive.files.any(
        (f) => f.name.contains('Info.plist'),
      );
      if (!hasInfoPlist) {
        _logger.warn("xcresult file doesn't contain Info.plist");
        return false;
      }

      return true;
    } catch (e) {
      _logger.warn('xcresult file is corrupted or not a valid zip');
      return false;
    }
  }

  int _exitWithStatus(String buildStatus) {
    _logger.info('');

    switch (buildStatus) {
      case 'passed':
        _logger.success('Build PASSED');
        return BsExitCodes.passed;
      case 'failed':
        _logger.err('Build FAILED (test failures)');
        return BsExitCodes.failed;
      case 'error':
        _logger.err('Build ERROR (infrastructure issue)');
        return BsExitCodes.buildError;
      case 'timedout':
        _logger.warn('Build TIMEOUT');
        return BsExitCodes.timedOut;
      case 'skipped':
        _logger.warn('Build SKIPPED');
        return BsExitCodes.skipped;
      default:
        _logger.warn('Build status: $buildStatus');
        return BsExitCodes.failed;
    }
  }
}
