import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dispose_scope/dispose_scope.dart';
import 'package:patrol_cli/src/common/artifacts_repository.dart';
import 'package:patrol_cli/src/common/common.dart';
import 'package:patrol_cli/src/features/bootstrap/bootstrap_command.dart';
import 'package:patrol_cli/src/features/clean/clean_command.dart';
import 'package:patrol_cli/src/features/devices/devices_command.dart';
import 'package:patrol_cli/src/features/doctor/doctor_command.dart';
import 'package:patrol_cli/src/features/drive/drive_command.dart';
import 'package:patrol_cli/src/features/drive/flutter_driver.dart';
import 'package:patrol_cli/src/features/update/update_command.dart';
import 'package:patrol_cli/src/top_level_flags.dart';
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

  try {
    exitCode = await runner.run(args) ?? 0;
  } on UsageException catch (err) {
    log.severe(err.message);
    exitCode = 1;
  } on FlutterDriverFailedException catch (err) {
    log
      ..severe(err)
      ..severe(
        "See the logs above to learn what happened. If the logs above aren't "
        "useful then it's a bug – please report it.",
      );
    exitCode = 1;
  } on FormatException catch (err, st) {
    log.severe(null, err, st);
    exitCode = 1;
  } on FileSystemException catch (err, st) {
    log.severe('${err.message}: ${err.path}', err, st);
    exitCode = 1;
  } catch (err, st) {
    log.severe(null, err, st);
    exitCode = 1;
  }

  if (interruption != null) {
    await interruption; // will never complete
  }

  await runner.dispose();
  return exitCode;
}

class PatrolCommandRunner extends CommandRunner<int> {
  PatrolCommandRunner()
      : _disposeScope = DisposeScope(),
        _topLevelFlags = TopLevelFlags(),
        super(
          'patrol',
          'Tool for running Flutter-native UI tests with superpowers',
        ) {
    _artifactsRepository = ArtifactsRepository(_topLevelFlags);

    addCommand(BootstrapCommand());
    addCommand(
      DriveCommand(_disposeScope, _topLevelFlags, _artifactsRepository),
    );
    addCommand(DevicesCommand());
    addCommand(DoctorCommand());
    addCommand(CleanCommand());
    addCommand(UpdateCommand());

    argParser
      ..addFlag(
        'verbose',
        abbr: 'v',
        help: 'Print more logs.',
        negatable: false,
      )
      ..addFlag('version', abbr: 'V', help: 'Print version.', negatable: false)
      ..addFlag(
        'debug',
        help: 'Use default, non-versioned artifacts.',
        negatable: false,
      );
  }

  final DisposeScope _disposeScope;
  late final ArtifactsRepository _artifactsRepository;

  final TopLevelFlags _topLevelFlags;

  Future<void> dispose() async {
    try {
      await _disposeScope.dispose();
    } catch (err, st) {
      log.severe('error while disposing', err, st);
    }
  }

  @override
  Future<int?> run(Iterable<String> args) async {
    await setUpLogger(); // argParser.parse() can fail, so we setup logger early
    final results = argParser.parse(args);
    _topLevelFlags.verbose = results['verbose'] as bool;
    final helpFlag = results['help'] as bool;
    final versionFlag = results['version'] as bool;
    _topLevelFlags.debug = results['debug'] as bool;

    await setUpLogger(verbose: _topLevelFlags.verbose);

    if (_topLevelFlags.debug) {
      log.info('Debug mode enabled. Non-versioned artifacts will be used.');
    }

    if (versionFlag) {
      log.info('patrol_cli v$version');
      return 0;
    }

    if (helpFlag) {
      return super.run(args);
    }

    final commandName = results.command?.name;

    if (_wantsVersionCheck(commandName)) {
      await _checkIfUsingLatestVersion(commandName);
    }

    if (_wantsArtifacts(commandName)) {
      await _ensureArtifactsArePresent();
    }

    return super.run(args);
  }

  bool _wantsVersionCheck(String? commandName) {
    if (commandName == 'update' || commandName == 'doctor') {
      return false;
    }

    return true;
  }

  Future<void> _checkIfUsingLatestVersion(String? commandName) async {
    if (commandName == 'update' || commandName == 'doctor') {
      return;
    }

    final pubUpdater = PubUpdater();

    final latestVersion = await pubUpdater.getLatestVersion(patrolCliPackage);
    final isLatestVersion = await pubUpdater.isUpToDate(
      packageName: patrolCliPackage,
      currentVersion: version,
    );

    if (!isLatestVersion && !_topLevelFlags.debug) {
      log
        ..info(
          'Newer version of $patrolCliPackage is available ($latestVersion)',
        )
        ..info('Run `patrol update` to update');
    }
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

  Future<void> _ensureArtifactsArePresent() async {
    if (_topLevelFlags.debug) {
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
}
