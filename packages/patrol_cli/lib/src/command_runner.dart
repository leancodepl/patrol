import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dispose_scope/dispose_scope.dart';
import 'package:logging/logging.dart';
import 'package:mason_logger/mason_logger.dart' show lightCyan, lightYellow;
import 'package:patrol_cli/src/common/artifacts_repository.dart';
import 'package:patrol_cli/src/common/common.dart';
import 'package:patrol_cli/src/common/globals.dart' as globals;
import 'package:patrol_cli/src/common/tool_exit.dart';
import 'package:patrol_cli/src/features/bootstrap/bootstrap_command.dart';
import 'package:patrol_cli/src/features/clean/clean_command.dart';
import 'package:patrol_cli/src/features/devices/device_finder.dart';
import 'package:patrol_cli/src/features/devices/devices_command.dart';
import 'package:patrol_cli/src/features/doctor/doctor_command.dart';
import 'package:patrol_cli/src/features/drive/drive_command.dart';
import 'package:patrol_cli/src/features/drive/test_finder.dart';
import 'package:patrol_cli/src/features/drive/test_runner.dart';
import 'package:patrol_cli/src/features/update/update_command.dart';
import 'package:pub_updater/pub_updater.dart';

Future<int> patrolCommandRunner(List<String> args) async {
  final logger = Logger('');
  await setUpLogger();

  final runner = PatrolCommandRunner(
    logger: logger,
    pubUpdater: PubUpdater(),
    artifactsRepository: ArtifactsRepository(
      fs: globals.fs,
      platform: globals.platform,
    ),
  );
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
    required PubUpdater pubUpdater,
    required ArtifactsRepository artifactsRepository,
  })  : _disposeScope = DisposeScope(),
        _logger = logger,
        _pubUpdater = pubUpdater,
        _artifactsRepository = artifactsRepository,
        super(
          'patrol',
          'Tool for running Flutter-native UI tests with superpowers',
        ) {
    addCommand(BootstrapCommand(logger: _logger));
    addCommand(
      DriveCommand(
        parentDisposeScope: _disposeScope,
        artifactsRepository: _artifactsRepository,
        deviceFinder: DeviceFinder(logger: _logger),
        testFinder: TestFinder(
          integrationTestDir: globals.fs.directory('integration_test'),
          fs: globals.fs,
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
    addCommand(UpdateCommand(pubUpdater: _pubUpdater, logger: _logger));

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
  final Logger _logger;
  final ArtifactsRepository _artifactsRepository;
  final PubUpdater _pubUpdater;

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
    //_debugPrintResults(topLevelResults);

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
  void printUsage() => _logger.info('$usage');

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
    if (debug) {
      if (_artifactsRepository.areDebugArtifactsPresent()) {
        return;
      } else {
        throw Exception('Debug artifacts are not present.');
      }
    } else if (_artifactsRepository.areArtifactsPresent()) {
      return;
    }

    final progress =
        _logger.progress('Artifacts are not present, downloading...');
    try {
      await _artifactsRepository.downloadArtifacts();
    } catch (_) {
      progress.fail('Failed to download artifacts');
      rethrow;
    }

    progress.complete('Downloaded artifacts');
  }

  void _debugPrintResults(ArgResults topLevelResults) {
    _logger
      ..info('Argument information:')
      ..info('\tTop level options:');

    for (final option in topLevelResults.options) {
      if (topLevelResults.wasParsed(option)) {
        _logger.info('\t- $option: ${topLevelResults[option]}');
      }
    }

    if (topLevelResults.command != null) {
      final commandResults = topLevelResults.command!;
      _logger
        ..info('\tCommand: ${commandResults.name}')
        ..info('\t\tCommand options:');
      for (final option in commandResults.options) {
        if (commandResults.wasParsed(option)) {
          _logger.info('\t\t- $option: ${commandResults[option]}');
        }
      }
    }
  }
}
