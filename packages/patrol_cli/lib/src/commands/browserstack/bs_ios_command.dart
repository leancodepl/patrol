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
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:patrol_cli/src/pubspec_reader.dart';
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
    required IOSTestBackend iosTestBackend,
    required PubspecReader pubspecReader,
    required Analytics analytics,
    required Logger logger,
  }) : _buildIOSCommand = buildIOSCommand,
       _bsOutputsCommand = bsOutputsCommand,
       _iosTestBackend = iosTestBackend,
       _pubspecReader = pubspecReader,
       _analytics = analytics,
       _logger = logger {
    usesTargetOption();
    // Build mode flags - release is default for BrowserStack
    argParser
      ..addFlag('debug', help: 'Build a debug version of your app')
      ..addFlag('profile', help: 'Build a profile version of your app')
      ..addFlag(
        'release',
        help: 'Build a release version (default for BrowserStack)',
        defaultsTo: true,
      );
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

    // Simulator flag (always false for BrowserStack - real devices only)
    argParser
      ..addFlag(
        'simulator',
        help: 'Build for simulator (not supported for BrowserStack)',
        hide: true,
      )
      // Only BrowserStack-specific options - everything else passes to patrol build
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
  final IOSTestBackend _iosTestBackend;
  final PubspecReader _pubspecReader;
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

    final config = _pubspecReader.read();
    final flavor = stringArg('flavor') ?? config.ios.flavor;
    final runnerPrefix = flavor ?? 'Runner';

    final productsDir = _iosTestBackend.productsDir;
    final flavorPart = flavor != null ? '-$flavor' : '';
    final releaseDir = p.join(productsDir, 'Release$flavorPart-iphoneos');

    if (!Directory(releaseDir).existsSync()) {
      throwToolExit('Release directory not found: $releaseDir');
    }

    // Create IPA
    final ipaPath = await _createIpa(productsDir, flavor);
    _logger.info('Created IPA: $ipaPath');

    // Find xctestrun file
    final String xctestrunPath;
    try {
      final sdkVersion = await _iosTestBackend.getSdkVersion(real: true);
      xctestrunPath = _iosTestBackend.xcTestRunPath(
        real: true,
        scheme: runnerPrefix,
        sdkVersion: sdkVersion,
      );
    } on FileSystemException catch (e) {
      throwToolExit(e.message);
    }

    // Remove DiagnosticCollectionPolicy (BrowserStack fails if present)
    await _removeUnsupportedKeys(xctestrunPath);

    // Copy xctestrun to release dir
    final xctestrunName = p.basename(xctestrunPath);
    final xctestrunDest = p.join(releaseDir, xctestrunName);
    await File(xctestrunPath).copy(xctestrunDest);

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
        '/app-automate/xcuitest/v2/app',
        appFile,
        onProgress: (percent) =>
            appProgress.update('Uploading app ($percent%)'),
      );
      final appUrl = appResponse['app_url'] as String;
      appProgress.complete('Uploaded app');
      _logger.detail('App URL: $appUrl');

      // Upload test suite
      final testProgress = _logger.progress('Uploading test suite (0%)');
      final testResponse = await client.uploadFile(
        '/app-automate/xcuitest/v2/test-suite',
        testFile,
        onProgress: (percent) =>
            testProgress.update('Uploading test suite ($percent%)'),
      );
      final testUrl = testResponse['test_suite_url'] as String;
      testProgress.complete('Uploaded test suite');
      _logger.detail('Test URL: $testUrl');

      // Schedule test execution
      final scheduleProgress = _logger.progress('Scheduling test execution');

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

  Future<String> _createIpa(String productsDir, String? flavor) async {
    final payloadDir = p.join(productsDir, 'Payload');
    final runnerAppPath = BuildIOSCommand.appPath(
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
    await File(outputPath).writeAsBytes(zipData);
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
    await File(outputPath).writeAsBytes(zipData);
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
