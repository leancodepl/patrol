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

    _createConfigFile();

    _createDefaultIntegrationTestFile();

    _addMaestroToPubspec();

    return 0;
  }
}

void _createConfigFile() {
  log.info('Writing default maestro.toml config file...');
  final contents = MaestroConfig.defaultConfig().toToml();
  File('maestro.toml').writeAsStringSync(contents);
}

void _createDefaultIntegrationTestFile() {
  log.info('Writing default test_driver/integration_test.dart');
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
}

void _addMaestroToPubspec() {
  log.info('Adding maestro to dev_dependencies in pubspec.yaml');

  final result = Process.runSync(
    'flutter',
    ['pub', 'add', 'maestro', '--dev'],
  );

  if (result.exitCode != 0) {
    log
      ..severe('Failed to add maestro to pubspec.yaml.')
      ..severe(result.stderr);
    return;
  }
}
