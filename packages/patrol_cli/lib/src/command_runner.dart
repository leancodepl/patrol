import 'dart:io' show ProcessSignal, exit;

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:logging/logging.dart';
import 'package:mason_logger/mason_logger.dart' show lightCyan, lightYellow;
import 'package:patrol_cli/src/common/artifacts_repository.dart';
import 'package:patrol_cli/src/common/common.dart';
import 'package:patrol_cli/src/common/tool_exit.dart';
import 'package:patrol_cli/src/features/bootstrap/bootstrap_command.dart';
import 'package:patrol_cli/src/features/clean/clean_command.dart';
import 'package:patrol_cli/src/features/devices/device_finder.dart';
import 'package:patrol_cli/src/features/devices/devices_command.dart';
import 'package:patrol_cli/src/features/doctor/doctor_command.dart';
import 'package:patrol_cli/src/features/drive/drive_command.dart';
import 'package:patrol_cli/src/features/drive/flutter_driver.dart';
import 'package:patrol_cli/src/features/drive/platform/android_driver.dart';
import 'package:patrol_cli/src/features/drive/platform/ios_driver.dart';
import 'package:patrol_cli/src/features/drive/test_finder.dart';
import 'package:patrol_cli/src/features/drive/test_runner.dart';
import 'package:patrol_cli/src/features/update/update_command.dart';
import 'package:platform/platform.dart';
import 'package:pub_updater/pub_updater.dart';

Future<int> patrolCommandRunner(List<String> args) async {
  final logger = Logger('');
  await setUpLogger();

  final runner = PatrolCommandRunner(logger: logger);
  int exitCode;

  Future<Never>? interruption;

  ProcessSignal.sigint.watch().listen((signal) async {
    logger.fine('Caught SIGINT, exiting...');
    interruption = runner
        .dispose()
        .onError((err, st) => logger.severe('error while disposing', err, st))
        .then((_) => exit(130));
  });

  exitCode = await runner.run(args) ?? 0;

  if (interruption != null) {
    await interruption; // will never complete
  }

  await runner.dispose();
  return exitCode;
}

class PatrolCommandRunner extends CommandRunner<int> {
  PatrolCommandRunner({
    required Logger logger,
    PubUpdater? pubUpdater,
    ArtifactsRepository? artifactsRepository,
    FileSystem? fs,
  })  : _disposeScope = DisposeScope(),
        _pubUpdater = pubUpdater ?? PubUpdater(),
        _fs = fs ?? const LocalFileSystem(),
        _artifactsRepository = artifactsRepository ??
            ArtifactsRepository(
              fs: const LocalFileSystem(),
              platform: const LocalPlatform(),
            ),
        _logger = logger,
        super(
          'patrol',
          'Tool for running Flutter-native UI tests with superpowers',
        ) {
    addCommand(BootstrapCommand(fs: _fs, logger: _logger));
    addCommand(
      DriveCommand(
        parentDisposeScope: _disposeScope,
        deviceFinder: DeviceFinder(logger: _logger),
        testFinder: TestFinder(
          integrationTestDir: _fs.directory('integration_test'),
          fs: _fs,
        ),
        androidDriver: AndroidDriver(
          parentDisposeScope: _disposeScope,
          artifactsRepository: _artifactsRepository,
          logger: _logger,
        ),
        iosDriver: IOSDriver(
          parentDisposeScope: _disposeScope,
          artifactsRepository: _artifactsRepository,
          logger: _logger,
        ),
        flutterDriver: FlutterDriver(
          parentDisposeScope: _disposeScope,
          logger: _logger,
        ),
        testRunner: TestRunner(),
        logger: _logger,
      ),
    );
    addCommand(
      DevicesCommand(
        deviceFinder: DeviceFinder(logger: _logger),
        logger: _logger,
      ),
    );
    addCommand(
      DoctorCommand(
        logger: _logger,
        artifactsRepository: _artifactsRepository,
      ),
    );
    addCommand(
      CleanCommand(
        artifactsRepository: _artifactsRepository,
        logger: _logger,
      ),
    );
    addCommand(
      UpdateCommand(
        pubUpdater: _pubUpdater,
        artifactsRepository: _artifactsRepository,
        logger: _logger,
      ),
    );

    argParser
      ..addFlag(
        'verbose',
        abbr: 'v',
        help: 'Print more logs.',
        negatable: false,
      )
      ..addFlag(
        'version',
        abbr: 'V',
        help: 'Print version of this program.',
        negatable: false,
      )
      ..addFlag(
        'debug',
        help: 'Use default, non-versioned artifacts.',
        negatable: false,
      );
  }

  final DisposeScope _disposeScope;
  final ArtifactsRepository _artifactsRepository;
  final PubUpdater _pubUpdater;
  final FileSystem _fs;
  final Logger _logger;

  Future<void> dispose() async {
    try {
      await _disposeScope.dispose();
    } catch (err, st) {
      _logger.severe('error while disposing', err, st);
    }
  }

  @override
  Future<int?> run(Iterable<String> args) async {
    var verbose = false;
    var debug = false;

    int exitCode;
    try {
      final topLevelResults = parse(args);
      verbose = topLevelResults['verbose'] == true;
      debug = topLevelResults['debug'] == true;

      if (verbose) {
        _logger
          ..verbose = true
          ..info('Verbose mode enabled. More logs will be printed.');
      }

      if (debug) {
        _artifactsRepository.debug = true;
        _logger
            .info('Debug mode enabled. Non-versioned artifacts will be used.');
      }
      exitCode = await runCommand(topLevelResults) ?? 0;
    } on ToolExit catch (err, st) {
      if (verbose) {
        _logger.severe(null, err, st);
      } else {
        _logger.severe(err);
      }
      exitCode = 1;
    } on FormatException catch (err, st) {
      _logger
        ..severe(err.message)
        ..severe('$st')
        ..info('')
        ..info(usage);
      exitCode = 1;
    } on UsageException catch (err) {
      _logger
        ..severe(err.message)
        ..info('')
        ..info(err.usage);
      exitCode = 1;
    } on FileSystemException catch (err, st) {
      _logger.severe('${err.message}: ${err.path}', err, st);
      exitCode = 1;
    } catch (err, st) {
      _logger.severe(null, err, st);
      exitCode = 1;
    }

    return exitCode;
  }

  @override
  Future<int?> runCommand(ArgResults topLevelResults) async {
    final commandName = topLevelResults.command?.name;

    if (_wantsArtifacts(commandName)) {
      await _ensureArtifactsArePresent(debug: topLevelResults['debug'] == true);
    }

    if (_wantsUpdateCheck(commandName)) {
      await _checkForUpdate(commandName);
    }

    final int? exitCode;
    if (topLevelResults['version'] == true) {
      _logger.info('patrol_cli v$version');
      exitCode = 0;
    } else {
      exitCode = await super.runCommand(topLevelResults);
    }

    return exitCode;
  }

  @override
  void printUsage() => _logger.info(usage);

  bool _wantsUpdateCheck(String? commandName) {
    if (commandName == 'update' || commandName == 'doctor') {
      return false;
    }

    return true;
  }

  /// Checks if the current version (set by the build runner on the version.dart
  /// file) is the most recent one. If not, shows a prompt to the user.
  Future<void> _checkForUpdate(String? commandName) async {
    if (commandName == 'update' || commandName == 'doctor') {
      return;
    }

    final latestVersion = await _pubUpdater.getLatestVersion(patrolCliPackage);
    final isUpToDate = version == latestVersion;

    if (isUpToDate) {
      return;
    }

    _logger
      ..info('')
      ..info(
        '''
${lightYellow.wrap('Update available!')} ${lightCyan.wrap(version)} \u2192 ${lightCyan.wrap(latestVersion)}
Run ${lightCyan.wrap('patrol update')} to update''',
      )
      ..info('');
  }

  bool _wantsArtifacts(String? commandName) {
    if (commandName == 'clean' ||
        commandName == 'devices' ||
        commandName == 'doctor' ||
        commandName == 'update' ||
        commandName == 'help') {
      return false;
    }

    return true;
  }

  Future<void> _ensureArtifactsArePresent({required bool debug}) async {
    if (_artifactsRepository.areArtifactsPresent()) {
      return;
    }

    if (debug) {
      throw ToolExit('Debug artifacts are not present.');
    }

    final progress = _logger.progress('Artifacts are not present, downloading');
    try {
      await _artifactsRepository.downloadArtifacts();
    } catch (_) {
      progress.fail('Failed to download artifacts');
      rethrow;
    }

    progress.complete('Downloaded artifacts');
  }
}
