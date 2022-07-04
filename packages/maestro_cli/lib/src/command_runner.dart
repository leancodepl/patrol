import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:maestro_cli/src/common/common.dart';
import 'package:maestro_cli/src/features/bootstrap/bootstrap_command.dart';
import 'package:maestro_cli/src/features/clean/clean_command.dart';
import 'package:maestro_cli/src/features/doctor/doctor_command.dart';
import 'package:maestro_cli/src/features/drive/drive_command.dart';
import 'package:maestro_cli/src/features/update/update_command.dart';
import 'package:pub_updater/pub_updater.dart';

Future<int> maestroCommandRunner(List<String> args) async {
  final runner = MaestroCommandRunner();

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

  @override
  Future<int?> run(Iterable<String> args) async {
    await setUpLogger(); // argParser.parse() can fail, so we setup logger early
    final results = argParser.parse(args);
    verboseFlag = results['verbose'] as bool;
    final helpFlag = results['help'] as bool;
    final versionFlag = results['version'] as bool;
    debugFlag = results['debug'] as bool;

    await setUpLogger(verbose: verboseFlag);

    if (versionFlag) {
      log.info('maestro_cli v$version');
      return 0;
    }

    if (helpFlag) {
      return super.run(args);
    }

    if (debugFlag) {
      log.info('Debug mode enabled. Non-versioned artifacts will be used.');
    }

    if (!_isUpdateCommand(results.arguments)) {
      await _checkIfUsingLatestVersion();
    }

    if (_commandRequiresArtifacts(results.arguments)) {
      try {
        await _ensureArtifactsArePresent(debugFlag);
      } catch (err, st) {
        log.severe(null, err, st);
        return 1;
      }

      return super.run(args);
    }

    return super.run(args);
  }
}

bool _commandRequiresArtifacts(List<String> arguments) {
  return !arguments.contains('clean') &&
      !arguments.contains('doctor') &&
      !arguments.contains('help');
}

bool _isUpdateCommand(List<String> arguments) {
  return arguments.contains('update');
}

Future<void> _checkIfUsingLatestVersion() async {
  final pubUpdater = PubUpdater();

  final latestVersion = await pubUpdater.getLatestVersion(maestroCliPackage);
  final isLatestVersion = await pubUpdater.isUpToDate(
    packageName: maestroCliPackage,
    currentVersion: version,
  );

  if (!isLatestVersion) {
    log
      ..info(
        'Newer version of $maestroCliPackage is available ($latestVersion)',
      )
      ..info('Run `maestro update` to update');
  }
}

Future<void> _ensureArtifactsArePresent(bool debug) async {
  if (debug) {
    if (areDebugArtifactsPresent()) {
      return;
    } else {
      throw Exception('Debug artifacts are not present.');
    }
  } else {
    if (areArtifactsPresent()) {
      return;
    }
  }

  final progress = log.progress('Downloading artifacts');
  try {
    await downloadArtifacts();
  } catch (_) {
    progress.fail('Failed to download artifacts');
    rethrow;
  }

  progress.complete('Downloaded artifacts');
}
