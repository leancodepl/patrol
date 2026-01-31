import 'dart:async';
import 'dart:io';

import 'package:patrol_cli/src/analytics/analytics.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/commands/browserstack/browserstack_command_mixin.dart';
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
class BsAndroidCommand extends PatrolCommand with BrowserStackCommandMixin {
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
    usesBrowserStackOptions(
      argParser,
      defaultDevices: BrowserStackConfig.defaultAndroidDevices,
      devicesEnvVar: 'PATROL_BS_ANDROID_DEVICES',
      apiParamsEnvVar: 'PATROL_BS_ANDROID_API_PARAMS',
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

    // Parse BrowserStack options
    final bsConfig = parseBrowserStackConfig(
      defaultDevices: BrowserStackConfig.defaultAndroidDevices,
      devicesEnvVar: 'PATROL_BS_ANDROID_DEVICES',
      apiParamsEnvVar: 'PATROL_BS_ANDROID_API_PARAMS',
    );

    validateCredentials(bsConfig.credentials);

    // Build the APKs using patrol build android
    if (!bsConfig.skipBuild) {
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

    // Upload and schedule test execution
    return uploadAndSchedule(
      appFile: appApk,
      testFile: testApk,
      config: bsConfig,
      platform: BrowserStackPlatformConfig.android,
      bsOutputsCommand: _bsOutputsCommand,
      logger: _logger,
    );
  }
}
