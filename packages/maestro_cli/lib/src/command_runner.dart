import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:maestro_cli/src/commands/bootstrap_command.dart';
import 'package:maestro_cli/src/commands/clean_command.dart';
import 'package:maestro_cli/src/commands/drive_command.dart';
import 'package:maestro_cli/src/common/common.dart';

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
  } on FileSystemException catch (err) {
    log.severe('${err.message} ${err.path}');
    return 1;
  }
}

class MaestroCommandRunner extends CommandRunner<int> {
  MaestroCommandRunner()
      : super(
          'maestro',
          'Tool for running Flutter-native UI tests with superpowers',
        ) {
    addCommand(BootstrapCommand());
    addCommand(DriveCommand());
    addCommand(CleanCommand());

    argParser
      ..addFlag(
        'verbose',
        abbr: 'v',
        help: 'Increase logging.',
        negatable: false,
      )
      ..addFlag('version', help: 'Show version.', negatable: false);
  }

  @override
  Future<int?> run(Iterable<String> args) async {
    await setUpLogger(); // argParser.parse() can fail, so we setup logger early
    final results = argParser.parse(args);
    final verboseFlag = results['verbose'] as bool;
    final helpFlag = results['help'] as bool;
    final versionFlag = results['version'] as bool;
    await setUpLogger(verbose: verboseFlag);

    if (versionFlag) {
      log.info('maestro v$version');
      return 0;
    }

    if (helpFlag) {
      return super.run(args);
    }

    if (!results.arguments.contains('clean')) {
      try {
        await _ensureArtifactsArePresent();
      } catch (err, st) {
        log.severe(null, err, st);
        return 1;
      }

      return super.run(args);
    }

    return null;
  }

  Future<void> _ensureArtifactsArePresent() async {
    if (areArtifactsPresent()) {
      return;
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
}
