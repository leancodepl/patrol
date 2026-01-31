import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/commands/browserstack/browserstack_client.dart';
import 'package:patrol_cli/src/commands/browserstack/bs_outputs_command.dart';

/// Default values for BrowserStack commands.
class BrowserStackDefaults {
  static const timeoutMinutes = 60;
  static const retryLimit = 5;
  static const retryDelay = Duration(seconds: 30);
  static const outputDir = '.';
}

/// Configuration for a BrowserStack test execution.
class BrowserStackRunConfig {
  const BrowserStackRunConfig({
    required this.credentials,
    required this.devices,
    required this.project,
    required this.apiParams,
    required this.skipBuild,
    required this.downloadOutputs,
    required this.timeoutMinutes,
    required this.outputDir,
  });

  final String credentials;
  final String devices;
  final String? project;
  final String? apiParams;
  final bool skipBuild;
  final bool downloadOutputs;
  final int timeoutMinutes;
  final String outputDir;
}

/// Platform-specific configuration for BrowserStack uploads.
class BrowserStackPlatformConfig {
  const BrowserStackPlatformConfig({
    required this.appEndpoint,
    required this.testEndpoint,
    required this.buildEndpoint,
    required this.defaultPayload,
  });

  /// Android/Espresso configuration.
  static const android = BrowserStackPlatformConfig(
    appEndpoint: '/app-automate/espresso/v2/app',
    testEndpoint: '/app-automate/espresso/v2/test-suite',
    buildEndpoint: '/app-automate/espresso/v2/build',
    defaultPayload: {
      'singleRunnerInvocation': true,
      'useOrchestrator': true,
      'clearPackageData': true,
      'deviceLogs': true,
      'enableResultBundle': true,
    },
  );

  /// iOS/XCUITest configuration.
  static const ios = BrowserStackPlatformConfig(
    appEndpoint: '/app-automate/xcuitest/v2/app',
    testEndpoint: '/app-automate/xcuitest/v2/test-suite',
    buildEndpoint: '/app-automate/xcuitest/v2/xctestrun-build',
    defaultPayload: {
      'singleRunnerInvocation': true,
      'deviceLogs': true,
      'enableResultBundle': true,
    },
  );

  final String appEndpoint;
  final String testEndpoint;
  final String buildEndpoint;
  final Map<String, dynamic> defaultPayload;
}

/// Mixin that provides common BrowserStack functionality for commands.
///
/// This mixin should be used with classes that extend `PatrolCommand` and
/// have access to `ArgParser` and `ArgResults`.
mixin BrowserStackCommandMixin {
  /// Must be implemented by the mixing class to access argument results.
  ArgResults? get argResults;

  /// Adds common BrowserStack options to the argument parser.
  ///
  /// [argParser] - The argument parser to add options to.
  /// [defaultDevices] - Platform-specific default devices JSON.
  /// [devicesEnvVar] - Environment variable name for devices (e.g., PATROL_BS_ANDROID_DEVICES).
  /// [apiParamsEnvVar] - Environment variable name for API params (e.g., PATROL_BS_ANDROID_API_PARAMS).
  void usesBrowserStackOptions(
    ArgParser argParser, {
    required String defaultDevices,
    required String devicesEnvVar,
    required String apiParamsEnvVar,
  }) {
    argParser
      ..addSeparator('BrowserStack options:')
      ..addOption(
        'credentials',
        help: 'Access key from BrowserStack Dashboard (username:access_key)',
      )
      ..addOption('project', help: 'Project name in BrowserStack Dashboard')
      ..addOption(
        'devices',
        help:
            'JSON array of devices to test on\n'
            "(default: '$defaultDevices')",
      )
      ..addFlag(
        'skip-build',
        help: 'Skip building, only upload existing artifacts',
        negatable: false,
      )
      ..addOption(
        'api-params',
        help:
            'Parameters for "Execute a build" API (JSON)\n'
            "(e.g. '{\"shards\": {\"numberOfShards\": 2}, \"buildTag\": \"smoke\"}')\n"
            r'(or from file: --api-params "$(cat params.json)")',
      )
      ..addFlag(
        'download-outputs',
        abbr: 'd',
        help: 'Wait for the test run to complete and download outputs',
        negatable: false,
      )
      ..addOption(
        'timeout',
        help:
            'Timeout in minutes when waiting for test run\n'
            '(default: ${BrowserStackDefaults.timeoutMinutes})',
      )
      ..addOption(
        'output-dir',
        help:
            'Directory to save outputs when waiting\n'
            '(default: "${BrowserStackDefaults.outputDir}")',
      );
  }

  /// Parses BrowserStack-specific options from argument results.
  ///
  /// [defaultDevices] - Default devices JSON if not specified.
  /// [devicesEnvVar] - Environment variable name for devices.
  /// [apiParamsEnvVar] - Environment variable name for API params.
  BrowserStackRunConfig parseBrowserStackConfig({
    required String defaultDevices,
    required String devicesEnvVar,
    required String apiParamsEnvVar,
  }) {
    final results = argResults!;

    return BrowserStackRunConfig(
      skipBuild: results['skip-build'] as bool? ?? false,
      downloadOutputs: results['download-outputs'] as bool? ?? false,
      timeoutMinutes:
          int.tryParse(results['timeout'] as String? ?? '') ??
          BrowserStackDefaults.timeoutMinutes,
      outputDir:
          results['output-dir'] as String? ?? BrowserStackDefaults.outputDir,
      credentials:
          results['credentials'] as String? ??
          Platform.environment['PATROL_BS_CREDENTIALS'] ??
          '',
      devices:
          results['devices'] as String? ??
          Platform.environment[devicesEnvVar] ??
          defaultDevices,
      apiParams:
          results['api-params'] as String? ??
          Platform.environment[apiParamsEnvVar],
      project:
          results['project'] as String? ??
          Platform.environment['PATROL_BS_PROJECT'],
    );
  }

  /// Validates that credentials are set, throws if not.
  void validateCredentials(String credentials) {
    if (credentials.isEmpty) {
      throwToolExit(
        'BrowserStack credentials not set.\n'
        'Set via: --credentials or PATROL_BS_CREDENTIALS env var',
      );
    }
  }

  /// Parses and validates the devices JSON.
  ///
  /// Returns the parsed JSON list for the API payload.
  /// Throws a user-friendly error if the JSON is invalid.
  List<dynamic> parseDevicesJson(String devices) {
    try {
      final parsed = jsonDecode(devices);
      if (parsed is! List) {
        throwToolExit(
          '--devices must be a JSON array, got: ${parsed.runtimeType}',
        );
      }
      return parsed;
    } on FormatException catch (e) {
      throwToolExit('Invalid JSON in --devices: ${e.message}');
    }
  }

  /// Parses and validates the API params JSON.
  ///
  /// Returns the parsed JSON map, or null if not provided.
  /// Throws a user-friendly error if the JSON is invalid.
  Map<String, dynamic>? parseApiParamsJson(String? apiParams) {
    if (apiParams == null || apiParams.isEmpty) {
      return null;
    }

    try {
      final parsed = jsonDecode(apiParams);
      if (parsed is! Map<String, dynamic>) {
        throwToolExit(
          '--api-params must be a JSON object, got: ${parsed.runtimeType}',
        );
      }
      return parsed;
    } on FormatException catch (e) {
      throwToolExit('Invalid JSON in --api-params: ${e.message}');
    }
  }

  /// Uploads artifacts and schedules test execution on BrowserStack.
  ///
  /// Returns the exit code (0 for success, or the result of downloading outputs).
  Future<int> uploadAndSchedule({
    required File appFile,
    required File testFile,
    required BrowserStackRunConfig config,
    required BrowserStackPlatformConfig platform,
    required BsOutputsCommand bsOutputsCommand,
    required Logger logger,
  }) async {
    final client = BrowserStackClient(
      credentials: config.credentials,
      logger: logger,
    );

    // Handle Ctrl+C gracefully
    var cancelled = false;
    final sigintSubscription = ProcessSignal.sigint.watch().listen((_) {
      logger.err('\nUpload cancelled by user');
      cancelled = true;
      client.close();
    });

    try {
      // Upload app
      if (cancelled) {
        return 130;
      }
      final appProgress = logger.progress('Uploading app (0%)');
      final appResponse = await client.uploadFile(
        platform.appEndpoint,
        appFile,
        onProgress: (percent) => appProgress.update('Uploading app ($percent%)'),
      );
      final appUrl = appResponse['app_url'] as String;
      appProgress.complete('Uploaded app');
      logger.detail('App URL: $appUrl');

      // Upload test
      if (cancelled) {
        return 130;
      }
      final testProgress = logger.progress('Uploading test suite (0%)');
      final testResponse = await client.uploadFile(
        platform.testEndpoint,
        testFile,
        onProgress: (percent) =>
            testProgress.update('Uploading test suite ($percent%)'),
      );
      final testUrl = testResponse['test_suite_url'] as String;
      testProgress.complete('Uploaded test suite');
      logger.detail('Test URL: $testUrl');

      // Schedule test execution
      if (cancelled) {
        return 130;
      }
      final scheduleProgress = logger.progress('Scheduling test execution');

      final payload = <String, dynamic>{
        'app': appUrl,
        'testSuite': testUrl,
        'devices': parseDevicesJson(config.devices),
        ...platform.defaultPayload,
      };

      if (config.project != null) {
        payload['project'] = config.project;
      }

      // Merge with custom API params if provided
      final extraParams = parseApiParamsJson(config.apiParams);
      if (extraParams != null) {
        payload.addAll(extraParams);
      }

      final runResponse = await client.post(platform.buildEndpoint, payload);
      final buildId = runResponse['build_id'] as String;
      scheduleProgress.complete('Test execution scheduled');

      logger
        ..info(
          'Dashboard: https://app-automate.browserstack.com/dashboard/v2/builds/$buildId',
        )
        ..detail('Build ID:')
        ..detail(buildId);

      if (config.downloadOutputs) {
        return bsOutputsCommand.execute(
          buildId: buildId,
          outputDir: config.outputDir,
          onlyReport: false,
          retryLimit: BrowserStackDefaults.retryLimit,
          retryDelay: BrowserStackDefaults.retryDelay,
          credentials: config.credentials,
          timeout: Duration(minutes: config.timeoutMinutes),
        );
      }

      return 0;
    } finally {
      await sigintSubscription.cancel();
      client.close();
    }
  }
}
