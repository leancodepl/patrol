import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dispose_scope/dispose_scope.dart';
import 'package:mason_logger/mason_logger.dart';
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
  final runner = PatrolCommandRunner();
  int exitCode;

  Future<Never>? interruption;

  ProcessSignal.sigint.watch().listen((signal) async {
    log.fine('Caught SIGINT, exiting...');
    interruption = runner
        .dispose()
        .onError((err, st) => log.severe('error while disposing', err, st))
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
  PatrolCommandRunner()
      : _disposeScope = DisposeScope(),
        _pubUpdater = PubUpdater(),
        super(
          'patrol',
          'Tool for running Flutter-native UI tests with superpowers',
        ) {
    _artifactsRepository = ArtifactsRepository(
      fs: globals.fs,
      platform: globals.platform,
    );

    addCommand(BootstrapCommand());
    addCommand(
      DriveCommand(
        parentDisposeScope: _disposeScope,
        artifactsRepository: _artifactsRepository,
        deviceFinder: DeviceFinder(),
        testFinder: TestFinder(
          integrationTestDir: globals.fs.directory('integration_test'),
          fs: globals.fs,
        ),
        testRunner: TestRunner(),
      ),
    );
    addCommand(DevicesCommand(deviceFinder: DeviceFinder()));
    addCommand(DoctorCommand(artifactsRepository: _artifactsRepository));
    addCommand(CleanCommand(artifactsRepository: _artifactsRepository));
    addCommand(UpdateCommand());

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
  late final ArtifactsRepository _artifactsRepository;
  final PubUpdater _pubUpdater;

  Future<void> dispose() async {
    try {
      await _disposeScope.dispose();
    } catch (err, st) {
      log.severe('error while disposing', err, st);
    }
  }

  @override
  Future<int?> run(Iterable<String> args) async {
    await setUpLogger();

    var verbose = false;
    var debug = false;

    int exitCode;
    try {
      final topLevelResults = parse(args);
      verbose = topLevelResults['verbose'] == true;
      debug = topLevelResults['debug'] == true;

      if (verbose) {
        log
          ..verbose = true
          ..info('Verbose mode enabled. More logs will be printed.');
      }

      if (debug) {
        _artifactsRepository.debug = true;
        log.info('Debug mode enabled. Non-versioned artifacts will be used.');
      }
      exitCode = await runCommand(topLevelResults) ?? ExitCode.success.code;
    } on ToolExit catch (err, st) {
      if (verbose) {
        log.severe(null, err, st);
      } else {
        log.severe(err);
      }
      exitCode = 1;
    } on FormatException catch (err, st) {
      log.severe(null, err, st);
      exitCode = 1;
      return ExitCode.usage.code;
    } on UsageException catch (err) {
      log
        ..severe(err.message)
        ..info('')
        ..info(err.usage);
      return ExitCode.usage.code;
    } on FileSystemException catch (err, st) {
      log.severe('${err.message}: ${err.path}', err, st);
      exitCode = 1;
    } catch (err, st) {
      log.severe(null, err, st);
      exitCode = 1;
    }

    return exitCode;
  }

  @override
  Future<int?> runCommand(ArgResults topLevelResults) async {
    _debugPrintResults(topLevelResults);

    final commandName = topLevelResults.command?.name;

    if (_wantsArtifacts(commandName)) {
      await _ensureArtifactsArePresent(debug: topLevelResults['debug'] == true);
    }

    if (_wantsUpdateCheck(commandName)) {
      await _checkForUpdate(commandName);
    }

    final int? exitCode;
    if (topLevelResults['version'] == true) {
      log.info('patrol_cli v$version');
      exitCode = ExitCode.success.code;
    } else {
      exitCode = await super.runCommand(topLevelResults);
    }

    return exitCode;
  }

  bool _wantsUpdateCheck(String? commandName) {
    if (commandName == 'update' || commandName == 'doctor') {
      return false;
    }

    return true;
  }

  /// Checks if the current version (set by the build runner on the version.dart
  /// file) is the most recent one. If not, show a prompt to the user.
  Future<void> _checkForUpdate(String? commandName) async {
    if (commandName == 'update' || commandName == 'doctor') {
      return;
    }

    final latestVersion = await _pubUpdater.getLatestVersion(patrolCliPackage);
    final isUpToDate = version == latestVersion;

    if (isUpToDate) {
      return;
    }

    log
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

    final progress = log.progress('Artifacts are not present, downloading...');
    try {
      await _artifactsRepository.downloadArtifacts();
    } catch (_) {
      progress.fail('Failed to download artifacts');
      rethrow;
    }

    progress.complete('Downloaded artifacts');
  }

  void _debugPrintResults(ArgResults topLevelResults) {
    log
      ..info('Argument information:')
      ..info('\tTop level options:');

    for (final option in topLevelResults.options) {
      if (topLevelResults.wasParsed(option)) {
        log.info('\t- $option: ${topLevelResults[option]}');
      }
    }

    if (topLevelResults.command != null) {
      final commandResults = topLevelResults.command!;
      log
        ..info('\tCommand: ${commandResults.name}')
        ..info('\t\tCommand options:');
      for (final option in commandResults.options) {
        if (commandResults.wasParsed(option)) {
          log.info('\t\t- $option: ${commandResults[option]}');
        }
      }
    }
  }
}
