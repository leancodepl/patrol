import 'dart:async';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:patrol_cli/src/analytics/analytics.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/commands/browserstack/browserstack_command_mixin.dart';
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
class BsIosCommand extends PatrolCommand with BrowserStackCommandMixin {
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
    // Build mode flags - only release is supported for real iOS devices
    // These flags are hidden but accepted for compatibility with build commands
    argParser
      ..addFlag('debug', hide: true)
      ..addFlag('profile', hide: true)
      ..addFlag('release', hide: true, defaultsTo: true);
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

    // Only add bundle-id from iOS options (skip simulator-only options)
    argParser
      ..addOption(
        'bundle-id',
        help: 'Bundle identifier of the iOS app under test.',
        valueHelp: 'pl.leancode.AwesomeApp',
      )
      // Hidden flags for compatibility with BuildIOSCommand
      ..addFlag('simulator', hide: true)
      ..addFlag('full-isolation', hide: true)
      ..addFlag(
        'clear-permissions',
        help:
            'Clear permissions available through XCUIProtectedResource API before running each test.',
        negatable: false,
      )
      ..addOption('ios', hide: true);

    // BrowserStack-specific options
    usesBrowserStackOptions(
      argParser,
      defaultDevices: BrowserStackConfig.defaultIosDevices,
      devicesEnvVar: 'PATROL_BS_IOS_DEVICES',
      apiParamsEnvVar: 'PATROL_BS_IOS_API_PARAMS',
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
  String get description =>
      'Build and upload iOS apps to BrowserStack for testing.';

  @override
  String? get docsName => 'bs';

  @override
  Future<int> run() async {
    unawaited(
      _analytics.sendCommand(FlutterVersion.fromCLI(flutterCommand), 'bs_ios'),
    );

    // Parse BrowserStack options
    final bsConfig = parseBrowserStackConfig(
      defaultDevices: BrowserStackConfig.defaultIosDevices,
      devicesEnvVar: 'PATROL_BS_IOS_DEVICES',
      apiParamsEnvVar: 'PATROL_BS_IOS_API_PARAMS',
    );

    validateCredentials(bsConfig.credentials);

    // Build the iOS app using patrol build ios (always release for BrowserStack)
    if (!bsConfig.skipBuild) {
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
    _logger.detail('Creating zip archives of test files...');

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
    _logger.detail('Created zip archives');

    // Verify files exist
    final appFile = File(ipaPath);
    final testFile = File(testZipPath);

    if (!appFile.existsSync()) {
      throwToolExit('App IPA not found: $ipaPath');
    }

    if (!testFile.existsSync()) {
      throwToolExit('Test zip not found: $testZipPath');
    }

    // Upload and schedule test execution
    return uploadAndSchedule(
      appFile: appFile,
      testFile: testFile,
      config: bsConfig,
      platform: BrowserStackPlatformConfig.ios,
      bsOutputsCommand: _bsOutputsCommand,
      logger: _logger,
    );
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
      // Key not present is OK - only log at detail level
      _logger.detail('DiagnosticCollectionPolicy not present in $plistPath');
    }
  }
}
