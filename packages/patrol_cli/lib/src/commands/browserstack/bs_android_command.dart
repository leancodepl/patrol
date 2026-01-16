import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:patrol_cli/src/analytics/analytics.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/commands/browserstack/browserstack_client.dart';
import 'package:patrol_cli/src/commands/browserstack/browserstack_config.dart';
import 'package:patrol_cli/src/commands/browserstack/bs_outputs_command.dart';
import 'package:patrol_cli/src/commands/build_android.dart';
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';

/// BrowserStack Android command for patrol CLI.
///
/// Builds Android APKs using `patrol build android` and uploads them to
/// BrowserStack for testing.
///
/// Usage:
///   patrol bs android --target patrol_test/app_test.dart --flavor dev
class BsAndroidCommand extends PatrolCommand {
  BsAndroidCommand({
    required BuildAndroidCommand buildAndroidCommand,
    required BsOutputsCommand bsOutputsCommand,
    required PubspecReader pubspecReader,
    required Analytics analytics,
    required Logger logger,
  }) : _buildAndroidCommand = buildAndroidCommand,
       _bsOutputsCommand = bsOutputsCommand,
       _pubspecReader = pubspecReader,
       _analytics = analytics,
       _logger = logger {
    usesTargetOption();
    usesBuildModeOption();
    usesFlavorOption();
    usesDartDefineOption();
    usesDartDefineFromFileOption();
    usesLabelOption();
    usesPortOptions();
    usesTagsOption();
    usesExcludeTagsOption();
    usesCheckCompatibilityOption();

    usesUninstallOption();
    usesBuildNameOption();
    usesBuildNumberOption();

    usesAndroidOptions();

    // BrowserStack-specific options
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
            "(default: '${BrowserStackConfig.defaultAndroidDevices}')",
      )
      ..addFlag(
        'skip-build',
        help: 'Skip building, only upload existing APKs',
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
        'wait',
        abbr: 'w',
        help: 'Wait for the test run to complete',
        negatable: false,
      )
      ..addOption(
        'wait-timeout',
        help:
            'Timeout in minutes when waiting for test run\n'
            '(default: 60)',
      )
      ..addOption(
        'output-dir',
        help:
            'Directory to save outputs when waiting\n'
            '(default: ".")',
      );
  }

  final BuildAndroidCommand _buildAndroidCommand;
  final BsOutputsCommand _bsOutputsCommand;
  final PubspecReader _pubspecReader;
  final Analytics _analytics;
  final Logger _logger;

  @override
  String get name => 'android';

  @override
  String get description =>
      'Build and upload Android APKs to BrowserStack for testing.';

  @override
  String? get docsName => 'bs';

  @override
  Future<int> run() async {
    unawaited(
      _analytics.sendCommand(
        FlutterVersion.fromCLI(flutterCommand),
        'bs_android',
      ),
    );

    // Parse BS-specific options
    final skipBuild = argResults!['skip-build'] as bool? ?? false;
    final wait = argResults!['wait'] as bool? ?? false;
    final waitTimeoutMinutes =
        int.tryParse(argResults!['wait-timeout'] as String? ?? '60') ?? 60;
    final outputDir = argResults!['output-dir'] as String? ?? '.';

    final credentials =
        argResults!['credentials'] as String? ??
        Platform.environment['PATROL_BS_CREDENTIALS'] ??
        '';
    final devices =
        argResults!['devices'] as String? ??
        Platform.environment['PATROL_BS_ANDROID_DEVICES'] ??
        BrowserStackConfig.defaultAndroidDevices;
    final apiParams =
        argResults!['api-params'] as String? ??
        Platform.environment['PATROL_BS_ANDROID_API_PARAMS'];
    final project =
        argResults!['project'] as String? ??
        Platform.environment['PATROL_BS_PROJECT'];

    if (credentials.isEmpty) {
      throwToolExit(
        'BrowserStack credentials not set.\n'
        'Set via: --credentials or PATROL_BS_CREDENTIALS env var',
      );
    }

    // Build the APKs using patrol build android
    if (!skipBuild) {
      _buildAndroidCommand.argResultsOverride = argResults;
      _buildAndroidCommand.globalResultsOverride = globalResults;
      final exitCode = await _buildAndroidCommand.run();
      if (exitCode != 0) {
        throwToolExit('patrol build android failed with exit code $exitCode');
      }
    } else {
      _logger.info('Skipping build (--skip-build)');
    }

    // Find APK files
    final config = _pubspecReader.read();
    final flavor = stringArg('flavor') ?? config.android.flavor;
    final buildMode = super.buildMode.androidName;

    final appApkPath = BuildAndroidCommand.appApkPath(
      flavor: flavor,
      buildMode: buildMode,
    );
    final testApkPath = BuildAndroidCommand.testApkPath(
      flavor: flavor,
      buildMode: buildMode,
    );

    final appApk = File(appApkPath);
    final testApk = File(testApkPath);

    if (!appApk.existsSync()) {
      throwToolExit('Could not find app APK at: $appApkPath');
    }
    if (!testApk.existsSync()) {
      throwToolExit('Could not find test APK at: $testApkPath');
    }

    // Create BrowserStack client
    final client = BrowserStackClient(
      credentials: credentials,
      logger: _logger,
    );

    // Handle Ctrl+C to cancel uploads
    final sigintSubscription = ProcessSignal.sigint.watch().listen((_) {
      _logger.err('\nUpload cancelled by user');
      client.close();
      exit(130); // Standard exit code for SIGINT
    });

    try {
      // Upload app
      final appProgress = _logger.progress('Uploading app (0%)');
      final appResponse = await client.uploadFile(
        '/app-automate/espresso/v2/app',
        appApk,
        onProgress: (percent) =>
            appProgress.update('Uploading app ($percent%)'),
      );
      final appUrl = appResponse['app_url'] as String;
      appProgress.complete('Uploaded app');
      _logger.detail('App URL: $appUrl');

      // Upload test
      final testProgress = _logger.progress('Uploading test (0%)');
      final testResponse = await client.uploadFile(
        '/app-automate/espresso/v2/test-suite',
        testApk,
        onProgress: (percent) =>
            testProgress.update('Uploading test ($percent%)'),
      );
      final testUrl = testResponse['test_suite_url'] as String;
      testProgress.complete('Uploaded test');
      _logger.detail('Test URL: $testUrl');

      // Schedule test execution
      final scheduleProgress = _logger.progress('Scheduling test execution');

      final payload = <String, dynamic>{
        'app': appUrl,
        'testSuite': testUrl,
        'devices': jsonDecode(devices),
        'singleRunnerInvocation': true,
        'useOrchestrator': true,
        'clearPackageData': true,
        'deviceLogs': true,
        'enableResultBundle': true,
      };
      if (project != null) {
        payload['project'] = project;
      }

      // Merge with custom API params if provided
      if (apiParams != null && apiParams.isNotEmpty) {
        final extra = jsonDecode(apiParams) as Map<String, dynamic>;
        payload.addAll(extra);
      }

      final runResponse = await client.post(
        '/app-automate/espresso/v2/build',
        payload,
      );
      final buildId = runResponse['build_id'] as String;
      scheduleProgress.complete('Test execution scheduled');

      _logger
        ..info(
          'Dashboard: https://app-automate.browserstack.com/dashboard/v2/builds/$buildId',
        )
        ..detail('Build ID:')
        ..detail(buildId);

      if (wait) {
        return _bsOutputsCommand.execute(
          buildId: buildId,
          outputDir: outputDir,
          onlyReport: false,
          retryLimit: 5,
          retryDelay: const Duration(seconds: 30),
          credentials: credentials,
          timeout: Duration(minutes: waitTimeoutMinutes),
        );
      }

      return 0;
    } finally {
      await sigintSubscription.cancel();
      client.close();
    }
  }
}
