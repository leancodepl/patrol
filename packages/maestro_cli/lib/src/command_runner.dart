import 'dart:io';

import 'package:args/command_runner.dart';
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

  ProcessSignal.sigint.watch().listen((signal) {
    log.info('Caught SIGINT, exiting...');
    exit(1);
  });

  try {
    final exitCode = await runner.run(args) ?? 0;
    return exitCode;
  } on UsageException catch (err) {
    log.severe(err.message);
    return 1;
  } on FormatException catch (err) {
    log.severe(err.message);
    return 1;
  } on FileSystemException catch (err, st) {
    log.severe('${err.message}: ${err.path}', err, st);
    return 1;
  } catch (err, st) {
    log.severe(null, err, st);
    return 1;
  }
}

bool debugFlag = false;
bool verboseFlag = false;

class MaestroCommandRunner extends CommandRunner<int> {
  MaestroCommandRunner()
      : super(
          'maestro',
          'Tool for running Flutter-native UI tests with superpowers',
        ) {
    addCommand(BootstrapCommand());
    addCommand(DriveCommand());
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

  final artifactsRepository = ArtifactsRepository();

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
      if (artifactsRepository.areDebugArtifactsPresent()) {
        return;
      } else {
        throw Exception('Debug artifacts are not present.');
      }
    } else if (artifactsRepository.areArtifactsPresent()) {
      return;
    }

    final progress = log.progress('Artifacts are not present, downloading...');
    try {
      await artifactsRepository.downloadArtifacts();
    } catch (_) {
      progress.fail('Failed to download artifacts');
      rethrow;
    }

    progress.complete('Downloaded artifacts');
  }
}
