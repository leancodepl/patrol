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
    if (!File('pubspec.yaml').existsSync()) {
      log.severe(
        'No pubspec.yaml found. Maestro must be run from Flutter project root.',
      );
      return 1;
    }

    await _createConfigFile();

    _createDefaultIntegrationTestFile();

    await _addMaestroToPubspec();

    return 0;
  }
}

Future<void> _createConfigFile() async {
  final progress = log.progress('Creating default maestro.toml config file');

  try {
    final contents = MaestroConfig.defaultConfig().toToml();
    await File('maestro.toml').writeAsString(contents);
  } catch (err, st) {
    progress.fail('Failed to create default maestro.toml config file');
    log.severe(null, err, st);
    return;
  }

  progress.complete('Created default maestro.toml config file');
}

void _createDefaultIntegrationTestFile() {
  final progress = log.progress(
    'Creating default test_driver/integration_test.dart file',
  );

  try {
    final testDriverDir = Directory('test_driver');
    if (!testDriverDir.existsSync()) {
      testDriverDir.createSync();
    }

    final testDriverFile = File('test_driver/integration_test.dart');
    if (!testDriverFile.existsSync()) {
      testDriverFile.writeAsStringSync(
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

  await Future<void>.delayed(const Duration(seconds: 1));

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
