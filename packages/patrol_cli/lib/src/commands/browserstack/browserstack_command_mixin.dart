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
    this.shards,
  });

  final String credentials;
  final String devices;
  final String? project;
  final String? apiParams;
  final bool skipBuild;
  final bool downloadOutputs;
  final int timeoutMinutes;
  final String outputDir;

  /// Number of shards for test sharding (Android/Espresso only).
  final int? shards;
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
      ..addSeparator('BrowserStack options:\n')
      ..addOption(
        'credentials',
        help: 'BrowserStack credentials in format (username:access_key)',
      )
      ..addOption('project', help: 'Project name in BrowserStack Dashboard')
      ..addOption(
        'devices',
        help:
            'JSON array of devices. Two formats supported:\n'
            '  Specific: \'["Samsung Galaxy S24-14.0"]\'\n'
            '  Regex:    \'[{"device": "Google Pixel.*", "os_version": "14"}]\'\n'
            '(os_version is optional, defaults to latest)\n'
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

    // Parse shards if the option exists (Android-specific)
    int? shards;
    if (results.options.contains('shards')) {
      final shardsStr = results['shards'] as String?;
      if (shardsStr != null) {
        shards = int.tryParse(shardsStr);
        if (shards == null || shards < 2) {
          throwToolExit('--shards must be an integer >= 2, got: $shardsStr');
        }
      }
    }

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
      shards: shards,
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

  /// Validates all inputs before uploading (fail-fast).
  ///
  /// This should be called before any uploads to catch errors early and avoid
  /// wasting time/bandwidth uploading large files only to fail on validation.
  ///
  /// Returns validated devices list and API params for use in the payload.
  Future<({List<dynamic> devices, Map<String, dynamic>? apiParams})>
  validateBeforeUpload({
    required File appFile,
    required File testFile,
    required BrowserStackRunConfig config,
    required Logger logger,
  }) async {
    logger.detail('Validating inputs before upload...');

    // Validate files exist
    if (!appFile.existsSync()) {
      throwToolExit('App file not found: ${appFile.path}');
    }
    if (!testFile.existsSync()) {
      throwToolExit('Test file not found: ${testFile.path}');
    }
    logger.detail('  Files exist: OK');

    // Validate JSON formats (do this before any network calls)
    final devices = parseDevicesJson(config.devices);
    logger.detail('  Devices JSON: OK');

    final apiParams = parseApiParamsJson(config.apiParams);
    if (apiParams != null) {
      logger.detail('  API params JSON: OK');
    }

    // Validate credentials with a lightweight API call
    logger.detail('  Validating credentials...');
    final client = BrowserStackClient(
      credentials: config.credentials,
      logger: logger,
    );

    try {
      await client.validateCredentials();
      logger.detail('  Credentials: OK');
    } on BrowserStackException catch (e) {
      if (e.message.contains('401')) {
        throwToolExit(
          'Invalid BrowserStack credentials.\n'
          'Verify your username and access key are correct.',
        );
      }
      throwToolExit('Failed to validate credentials: ${e.message}');
    } finally {
      client.close();
    }

    logger.detail('Validation passed');
    return (devices: devices, apiParams: apiParams);
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
    // Validate everything before uploading (fail-fast)
    final validated = await validateBeforeUpload(
      appFile: appFile,
      testFile: testFile,
      config: config,
      logger: logger,
    );

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
        onProgress: (percent) =>
            appProgress.update('Uploading app ($percent%)'),
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
        'devices': validated.devices,
        ...platform.defaultPayload,
      };

      if (config.project != null) {
        payload['project'] = config.project;
      }

      // Add shards configuration if specified (Android/Espresso)
      if (config.shards != null) {
        payload['shards'] = {'numberOfShards': config.shards};
        logger.detail('Sharding enabled: ${config.shards} shards');
      }

      // Merge with custom API params if provided
      if (validated.apiParams != null) {
        payload.addAll(validated.apiParams!);
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
