import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dispose_scope/dispose_scope.dart';
import 'package:maestro_cli/src/common/artifacts_repository.dart';
import 'package:maestro_cli/src/common/common.dart';
import 'package:maestro_cli/src/features/bootstrap/bootstrap_command.dart';
import 'package:maestro_cli/src/features/clean/clean_command.dart';
import 'package:maestro_cli/src/features/devices/devices_command.dart';
import 'package:maestro_cli/src/features/doctor/doctor_command.dart';
import 'package:maestro_cli/src/features/drive/drive_command.dart';
import 'package:maestro_cli/src/features/update/update_command.dart';
import 'package:pub_updater/pub_updater.dart';

Future<int> maestroCommandRunner(List<String> args) async {
  final runner = MaestroCommandRunner();

  ProcessSignal.sigint.watch().listen((signal) async {
    log.fine('Caught SIGINT, exiting...');
    await runner
        .dispose()
        .onError((err, st) => log.severe('error while disposing', err, st));
    exit(1);
  });

  int exitCode;
  try {
    exitCode = await runner.run(args) ?? 0;
  } on UsageException catch (err) {
    log.severe(err.message);
    exitCode = 1;
  } on FormatException catch (err) {
    log.severe(err.message);
    exitCode = 1;
  } on FileSystemException catch (err, st) {
    log.severe('${err.message}: ${err.path}', err, st);
    exitCode = 1;
  } catch (err, st) {
    log.severe(null, err, st);
    exitCode = 1;
  }

  await runner
      .dispose()
      .onError((err, st) => log.severe('error while disposing', err, st));
  return exitCode;
}

bool debugFlag = false;
bool verboseFlag = false;

class MaestroCommandRunner extends CommandRunner<int> {
  MaestroCommandRunner()
      : _disposeScope = DisposeScope(),
        _artifactsRepository = ArtifactsRepository(),
        super(
          'maestro',
          'Tool for running Flutter-native UI tests with superpowers',
        ) {
    addCommand(BootstrapCommand());
    addCommand(DriveCommand(_disposeScope));
    addCommand(DevicesCommand());
    addCommand(DoctorCommand());
    addCommand(CleanCommand());
    addCommand(UpdateCommand());

    argParser
      ..addFlag(
        'verbose',
        abbr: 'v',
        help: 'Increase logging.',
        negatable: false,
      )
      ..addFlag('version', help: 'Show version.', negatable: false)
      ..addFlag('debug', help: 'Use default, non-versioned artifacts.');
  }

  final DisposeScope _disposeScope;
  final ArtifactsRepository _artifactsRepository;

  Future<void> dispose() => _disposeScope.dispose();

  @override
  Future<int?> run(Iterable<String> args) async {
    await setUpLogger(); // argParser.parse() can fail, so we setup logger early
    final results = argParser.parse(args);
    verboseFlag = results['verbose'] as bool;
    final helpFlag = results['help'] as bool;
    final versionFlag = results['version'] as bool;
    debugFlag = results['debug'] as bool;

    await setUpLogger(verbose: verboseFlag);

    if (debugFlag) {
      log.info('Debug mode enabled. Non-versioned artifacts will be used.');
    }

    if (versionFlag) {
      log.info('maestro_cli v$version');
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

    final latestVersion = await pubUpdater.getLatestVersion(maestroCliPackage);
    final isLatestVersion = await pubUpdater.isUpToDate(
      packageName: maestroCliPackage,
      currentVersion: version,
    );

    if (!isLatestVersion && !debugFlag) {
      log
        ..info(
          'Newer version of $maestroCliPackage is available ($latestVersion)',
        )
        ..info('Run `maestro update` to update');
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
    if (debugFlag) {
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
