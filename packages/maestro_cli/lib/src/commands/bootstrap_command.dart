import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:maestro_cli/src/common/constants.dart';
import 'package:maestro_cli/src/common/logging.dart';
import 'package:maestro_cli/src/maestro_config.dart';

class BootstrapCommand extends Command<int> {
  @override
  String get name => 'bootstrap';

  @override
  String get description =>
      'Create default config and test files and add maestro as a dev dependency';

  @override
  Future<int> run() async {
    if (!_hasPubspec()) {
      log.severe(
        'No pubspec.yaml found. Maestro must be run from Flutter project root.',
      );
      return 1;
    }

    await _createConfigFile();

    await _createDefaultIntegrationTestFile();

    await _addMaestroToPubspec();

    return 0;
  }
}

bool _hasPubspec() => File('pubspec.yaml').existsSync();

Future<void> _createConfigFile() async {
  final file = File(configFileName);
  if (file.existsSync()) {
    throw const FileSystemException('Already exists', configFileName);
  }

  final progress = log.progress('Creating default $configFileName config file');

  try {
    final contents = MaestroConfig.defaultConfig().toToml();
    await File(configFileName).writeAsString(contents);
  } catch (err, st) {
    progress.fail('Failed to create default $configFileName config file');
    log.severe(null, err, st);
    return;
  }

  progress.complete('Created default $configFileName config file');
}

Future<void> _createDefaultIntegrationTestFile() async {
  final progress = log.progress(
    'Creating default test_driver/integration_test.dart file',
  );

  try {
    final testDriverDir = Directory('test_driver');
    if (!testDriverDir.existsSync()) {
      await testDriverDir.create();
    }

    final testDriverFile = File('test_driver/integration_test.dart');
    if (!testDriverFile.existsSync()) {
      await testDriverFile.writeAsString(
        TestDriverDirectory.defaultTestFileContents,
      );
    }
  } catch (err, st) {
    progress.fail(
      'Failed to create default test_driver/integration_test.dart file,',
    );
    log.severe(null, err, st);
    return;
  }

  progress.complete('Created default test_driver/integration_test.dart file');
}

Future<void> _addMaestroToPubspec() async {
  final progress = log.progress('Adding $maestroPackage to dev_dependencies');

  final result = await Process.run(
    'flutter',
    ['pub', 'add', maestroPackage, '--dev'],
  );

  if (result.exitCode != 0) {
    progress.fail('Failed to add $maestroPackage to dev_dependencies');
    log.severe(result.stderr);
    return;
  }

  progress.complete('Added $maestroPackage to dev_dependencies');
}
