import 'dart:io' show ProcessSignal, exit;

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:patrol_cli/src/common/artifacts_repository.dart';
import 'package:patrol_cli/src/common/common.dart';
import 'package:patrol_cli/src/common/logger.dart';
import 'package:patrol_cli/src/common/logging_local_process_manager.dart';
import 'package:patrol_cli/src/common/tool_exit.dart';
import 'package:patrol_cli/src/features/bootstrap/bootstrap_command.dart';
import 'package:patrol_cli/src/features/clean/clean_command.dart';
import 'package:patrol_cli/src/features/devices/device_finder.dart';
import 'package:patrol_cli/src/features/devices/devices_command.dart';
import 'package:patrol_cli/src/features/doctor/doctor_command.dart';
import 'package:patrol_cli/src/features/drive/dart_defines_reader.dart';
import 'package:patrol_cli/src/features/drive/drive_command.dart';
import 'package:patrol_cli/src/features/drive/flutter_tool.dart';
import 'package:patrol_cli/src/features/drive/platform/android_driver.dart';
import 'package:patrol_cli/src/features/drive/platform/ios_driver.dart';
import 'package:patrol_cli/src/features/drive/test_finder.dart';
import 'package:patrol_cli/src/features/drive/test_runner.dart';
import 'package:patrol_cli/src/features/test/android_test_runner.dart';
import 'package:patrol_cli/src/features/test/ios_test_runner.dart';
import 'package:patrol_cli/src/features/test/test_command.dart';
import 'package:patrol_cli/src/features/update/update_command.dart';
import 'package:platform/platform.dart';
import 'package:process/process.dart';
import 'package:pub_updater/pub_updater.dart';

Future<int> patrolCommandRunner(List<String> args) async {
  final logger = Logger();

  final runner = PatrolCommandRunner(logger: logger);
  int exitCode;

  Future<Never>? interruption;

  ProcessSignal.sigint.watch().listen((signal) async {
    logger.detail('Caught SIGINT, exiting...');
    interruption = runner.dispose().onError((err, st) {
      logger
        ..err('error while disposing')
        ..err('$err')
        ..err('$st');
    }).then((_) => exit(130));
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
    driveCommand = DriveCommand(
      deviceFinder: DeviceFinder(logger: _logger),
      testFinder: TestFinder(
        integrationTestDir: _fs.directory('integration_test'),
        fs: _fs,
      ),
      testRunner: TestRunner(),
      androidDriver: AndroidDriver(
        artifactsRepository: _artifactsRepository,
        parentDisposeScope: _disposeScope,
        logger: _logger,
      ),
      iosDriver: IOSDriver(
        processManager: const LocalProcessManager(),
        platform: const LocalPlatform(),
        artifactsRepository: _artifactsRepository,
        parentDisposeScope: _disposeScope,
        logger: _logger,
      ),
      flutterTool: FlutterTool(
        processManager: const LocalProcessManager(),
        fs: _fs,
        parentDisposeScope: _disposeScope,
        logger: _logger,
      ),
      dartDefinesReader: DartDefinesReader(
        projectRoot: _fs.currentDirectory,
        fs: _fs,
      ),
      parentDisposeScope: _disposeScope,
      logger: _logger,
    );
    addCommand(driveCommand);

    addCommand(
      TestCommand(
        deviceFinder: DeviceFinder(logger: _logger),
        testFinder: TestFinder(
          integrationTestDir: _fs.directory('integration_test'),
          fs: _fs,
        ),
        androidTestDriver: AndroidTestRunner(
          processManager: LoggingLocalProcessManager(logger: _logger),
          fs: _fs,
          parentDisposeScope: _disposeScope,
          logger: _logger,
        ),
        iosTestDriver: IOSTestRunner(),
        dartDefinesReader: DartDefinesReader(
          projectRoot: _fs.currentDirectory,
          fs: _fs,
        ),
        parentDisposeScope: _disposeScope,
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
        platform: const LocalPlatform(),
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

  late DriveCommand driveCommand;

  Future<void> dispose() async {
    try {
      await _disposeScope.dispose();
    } catch (err, st) {
      _logger
        ..err('error while disposing')
        ..err('$err')
        ..err('$st');
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

      driveCommand.verbose = verbose;

      if (verbose) {
        _logger
          ..level = Level.verbose
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
        _logger
          ..err('$err')
          ..err('$st');
      } else {
        _logger.err('$err');
      }
      exitCode = 1;
    } on FormatException catch (err, st) {
      _logger
        ..err(err.message)
        ..err('$st')
        ..info('')
        ..info(usage);
      exitCode = 1;
    } on UsageException catch (err) {
      _logger
        ..err(err.message)
        ..info('')
        ..info(err.usage);
      exitCode = 1;
    } on FileSystemException catch (err, st) {
      _logger
        ..err('${err.message}: ${err.path}')
        ..err('$err')
        ..err('$st');
      exitCode = 1;
    } catch (err, st) {
      _logger
        ..err('$err')
        ..err('$st');
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
      _logger.info('patrol_cli v$globalVersion');
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
    final isUpToDate = globalVersion == latestVersion;

    if (isUpToDate) {
      return;
    }

    _logger
      ..info('')
      ..info(
        '''
${lightYellow.wrap('Update available!')} ${lightCyan.wrap(globalVersion)} \u2192 ${lightCyan.wrap(latestVersion)}
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
