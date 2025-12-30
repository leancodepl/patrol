import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:patrol_cli/src/analytics/analytics.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/commands/browserstack/browserstack_client.dart';
import 'package:patrol_cli/src/commands/browserstack/browserstack_config.dart';
import 'package:patrol_cli/src/commands/browserstack/bs_outputs_command.dart';
import 'package:patrol_cli/src/commands/build_ios.dart';
import 'package:patrol_cli/src/ios/ios_paths.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';

/// BrowserStack iOS command for patrol CLI.
///
/// Builds iOS apps using `patrol build ios` and uploads them to BrowserStack
/// for testing.
///
/// Usage:
///   patrol bs ios --target patrol_test/app_test.dart --flavor dev
class BsIosCommand extends PatrolCommand {
  BsIosCommand({
    required BuildIOSCommand buildIOSCommand,
    required BsOutputsCommand bsOutputsCommand,
    required Analytics analytics,
    required Logger logger,
  }) : _buildIOSCommand = buildIOSCommand,
       _bsOutputsCommand = bsOutputsCommand,
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
    usesBuildNameOption();
    usesBuildNumberOption();

    usesIOSOptions();

    // Only BrowserStack-specific options - everything else passes to patrol build
    argParser
      ..addOption(
        'credentials',
        help: 'BrowserStack credentials (username:access_key)',
      )
      ..addOption('devices', help: 'JSON array of devices to test on')
      ..addFlag(
        'skip-build',
        help: 'Skip building, only upload existing artifacts',
        negatable: false,
      )
      ..addOption('test-plan', help: 'XCTest plan name', defaultsTo: 'TestPlan')
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

  final BuildIOSCommand _buildIOSCommand;
  final BsOutputsCommand _bsOutputsCommand;
  final Analytics _analytics;
  final Logger _logger;

  @override
  String get name => 'ios';

  @override
  String? get docsName => 'bs';

  @override
  String get description =>
      'Build and upload iOS apps to BrowserStack for testing.';

  @override
  Future<int> run() async {
    unawaited(
      _analytics.sendCommand(FlutterVersion.fromCLI(flutterCommand), 'bs_ios'),
    );

    // Parse BS-specific options
    final skipBuild = argResults!['skip-build'] as bool? ?? false;
    final wait = argResults!['wait'] as bool? ?? false;
    final waitTimeoutMinutes =
        int.tryParse(argResults!['wait-timeout'] as String? ?? '60') ?? 60;
    final outputDir = argResults!['output-dir'] as String? ?? '.';
    final testPlan = argResults!['test-plan'] as String? ?? 'TestPlan';

    final credentials =
        argResults!['credentials'] as String? ??
        Platform.environment['PATROL_BS_CREDENTIALS'] ??
        '';
    final devices =
        argResults!['devices'] as String? ??
        Platform.environment['PATROL_BS_IOS_DEVICES'] ??
        BrowserStackConfig.defaultIosDevices;
    final apiParams =
        argResults!['api-params'] as String? ??
        Platform.environment['PATROL_BS_IOS_API_PARAMS'];

    if (credentials.isEmpty) {
      throwToolExit(
        'BrowserStack credentials not set.\n'
        'Set via: --credentials or PATROL_BS_CREDENTIALS env var',
      );
    }

    // Build the iOS app using patrol build ios (always release for BrowserStack)
    if (!skipBuild) {
      _buildIOSCommand.argResultsOverride = argResults;
      _buildIOSCommand.globalResultsOverride = globalResults;
      final exitCode = await _buildIOSCommand.run();
      if (exitCode != 0) {
        throwToolExit('patrol build ios failed with exit code $exitCode');
      }
    } else {
      _logger.info('Skipping build (--skip-build)');
    }

    // Create archives
    _logger.info('Creating zip archives of test files...');

    final flavor = stringArg('flavor');
    final runnerPrefix = flavor ?? 'Runner';

    final productsDir = IosPaths.productsDir();
    final releaseDir = IosPaths.buildDir(
      buildMode: 'Release',
      simulator: false,
      flavor: flavor,
    );

    if (!Directory(releaseDir).existsSync()) {
      throwToolExit('Release directory not found: $releaseDir');
    }

    // Create IPA
    final ipaPath = await _createIpa(productsDir, flavor);
    _logger.info('Created IPA: $ipaPath');

    // Find xctestrun file
    final File xctestrunFile;
    try {
      xctestrunFile = await IosPaths.findXctestrunFile(
        runnerPrefix: runnerPrefix,
        testPlan: testPlan,
        simulator: false,
      );
    } on FileSystemException catch (e) {
      throwToolExit(e.message);
    }

    // Remove DiagnosticCollectionPolicy (BrowserStack fails if present)
    await _removeUnsupportedKeys(xctestrunFile.path);

    // Copy xctestrun to release dir
    final xctestrunName = p.basename(xctestrunFile.path);
    final xctestrunDest = p.join(releaseDir, xctestrunName);
    await xctestrunFile.copy(xctestrunDest);

    // Create test zip
    final testZipPath = p.join(releaseDir, 'ios_tests.zip');
    await _createTestZip(releaseDir, testZipPath, [
      xctestrunName,
      'RunnerUITests-Runner.app',
    ]);
    _logger.success('Created zip archives');

    // Verify files exist
    final appFile = File(ipaPath);
    final testFile = File(testZipPath);

    if (!appFile.existsSync()) {
      throwToolExit('App IPA not found: $ipaPath');
    }

    if (!testFile.existsSync()) {
      throwToolExit('Test zip not found: $testZipPath');
    }

    // Create BrowserStack client
    final client = BrowserStackClient(
      credentials: credentials,
      logger: _logger,
    );

    try {
      // Upload app
      _logger.info('Uploading app...');
      final appResponse = await client.uploadFile(
        '/app-automate/xcuitest/v2/app',
        appFile,
      );
      final appUrl = appResponse['app_url'] as String;

      _logger
        ..success('Uploaded app: $appUrl')
        ..info('Uploading test suite...');
      final testResponse = await client.uploadFile(
        '/app-automate/xcuitest/v2/test-suite',
        testFile,
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
        'deviceLogs': true,
        'enableResultBundle': true,
        'networkLogs': false,
      };

      // Merge with custom API params if provided
      if (apiParams != null && apiParams.isNotEmpty) {
        final extra = jsonDecode(apiParams) as Map<String, dynamic>;
        payload.addAll(extra);
      }

      final runResponse = await client.post(
        '/app-automate/xcuitest/v2/xctestrun-build',
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

  Future<String> _createIpa(String productsDir, String? flavor) async {
    final payloadDir = p.join(productsDir, 'Payload');
    final runnerAppPath = IosPaths.appPath(
      buildMode: 'Release',
      simulator: false,
      flavor: flavor,
    );
    final ipaPath = p.join(productsDir, 'Runner.ipa');

    // Clean up and create Payload directory
    final payloadDirectory = Directory(payloadDir);
    if (payloadDirectory.existsSync()) {
      await payloadDirectory.delete(recursive: true);
    }
    await payloadDirectory.create(recursive: true);

    // Copy Runner.app to Payload
    await _copyDirectory(
      Directory(runnerAppPath),
      Directory(p.join(payloadDir, 'Runner.app')),
    );

    // Create IPA (zip of Payload)
    await _createZip(payloadDir, ipaPath, 'Payload');

    return ipaPath;
  }

  Future<void> _copyDirectory(Directory source, Directory destination) async {
    await destination.create(recursive: true);

    await for (final entity in source.list()) {
      final destPath = p.join(destination.path, p.basename(entity.path));

      if (entity is File) {
        await entity.copy(destPath);
      } else if (entity is Directory) {
        await _copyDirectory(entity, Directory(destPath));
      } else if (entity is Link) {
        final target = await entity.target();
        await Link(destPath).create(target);
      }
    }
  }

  Future<void> _createZip(
    String sourceDir,
    String outputPath,
    String rootDirName,
  ) async {
    final archive = Archive();
    final sourceDirectory = Directory(sourceDir);

    await for (final entity in sourceDirectory.list(recursive: true)) {
      if (entity is File) {
        final relativePath = p.relative(
          entity.path,
          from: p.dirname(sourceDir),
        );
        final data = await entity.readAsBytes();
        archive.addFile(ArchiveFile(relativePath, data.length, data));
      }
    }

    final zipData = ZipEncoder().encode(archive);
    if (zipData != null) {
      await File(outputPath).writeAsBytes(zipData);
    }
  }

  Future<void> _createTestZip(
    String sourceDir,
    String outputPath,
    List<String> includeItems,
  ) async {
    final archive = Archive();

    for (final item in includeItems) {
      final itemPath = p.join(sourceDir, item);
      final entityType = FileSystemEntity.typeSync(itemPath);

      if (entityType == FileSystemEntityType.file) {
        final file = File(itemPath);
        final data = await file.readAsBytes();
        archive.addFile(ArchiveFile(item, data.length, data));
      } else if (entityType == FileSystemEntityType.directory) {
        final directory = Directory(itemPath);
        await for (final file in directory.list(recursive: true)) {
          if (file is File) {
            final relativePath = p.relative(file.path, from: sourceDir);
            final data = await file.readAsBytes();
            archive.addFile(ArchiveFile(relativePath, data.length, data));
          }
        }
      }
    }

    final zipData = ZipEncoder().encode(archive);
    if (zipData != null) {
      await File(outputPath).writeAsBytes(zipData);
    }
  }

  Future<void> _removeUnsupportedKeys(String plistPath) async {
    final keys = [
      'TestConfigurations.TestTargets.DiagnosticCollectionPolicy',
      'TestConfigurations.0.TestTargets.0.DiagnosticCollectionPolicy',
    ];

    var removed = false;
    for (final key in keys) {
      try {
        final result = await Process.run('plutil', ['-remove', key, plistPath]);
        if (result.exitCode == 0) {
          removed = true;
        }
      } catch (_) {
        // Key might not exist at this path, continue trying other paths
      }
    }

    if (removed) {
      _logger.detail('Removed DiagnosticCollectionPolicy from $plistPath');
    } else {
      _logger.warn(
        'Failed to remove DiagnosticCollectionPolicy from $plistPath',
      );
    }
  }
}
