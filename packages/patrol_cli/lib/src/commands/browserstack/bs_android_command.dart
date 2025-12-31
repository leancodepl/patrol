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

    // Only BrowserStack-specific options - everything else passes to patrol build
    argParser
      ..addOption(
        'credentials',
        help: 'BrowserStack credentials (username:access_key)',
      )
      ..addOption('devices', help: 'JSON array of devices to test on')
      ..addFlag(
        'skip-build',
        help: 'Skip building, only upload existing APKs',
        negatable: false,
      )
      ..addOption(
        'api-params',
        help: 'Parameters for "Execute a build" API (JSON)',
      )
      ..addFlag(
        'wait',
        abbr: 'w',
        help: 'Wait for the test run to complete',
        negatable: false,
      )
      ..addOption(
        'wait-timeout',
        help: 'Timeout in minutes when waiting for test run',
        defaultsTo: '60',
      )
      ..addOption(
        'output-dir',
        help: 'Directory to save outputs when waiting',
        defaultsTo: '.',
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
  String? get docsName => 'bs';

  @override
  String get description =>
      'Build and upload Android APKs to BrowserStack for testing.';

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
    _logger.info('Locating APK files...');

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

    _logger
      ..info('Found app APK: ${appApk.path}')
      ..info('Found test APK: ${testApk.path}');

    // Create BrowserStack client
    final client = BrowserStackClient(
      credentials: credentials,
      logger: _logger,
    );

    try {
      // Upload app APK
      _logger.info('Uploading app APK...');
      final appResponse = await client.uploadFile(
        '/app-automate/espresso/v2/app',
        appApk,
      );
      final appUrl = appResponse['app_url'] as String;

      _logger
        ..success('Uploaded app: $appUrl')
        ..info('Uploading test APK...');
      final testResponse = await client.uploadFile(
        '/app-automate/espresso/v2/test-suite',
        testApk,
      );
      final testUrl = testResponse['test_suite_url'] as String;

      _logger
        ..success('Uploaded test: $testUrl')
        ..info('Scheduling test execution...');

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

      _logger
        ..success('Test execution scheduled')
        ..info('')
        ..info(
          '  Dashboard: https://app-automate.browserstack.com/dashboard/v2/builds/$buildId',
        )
        ..info('  Build ID: $buildId');

      // Output build ID to stdout for scripting
      stdout.writeln(buildId);

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
      client.close();
    }
  }
}
