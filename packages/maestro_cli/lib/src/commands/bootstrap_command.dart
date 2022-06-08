import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:maestro_cli/src/common/common.dart';
import 'package:maestro_cli/src/maestro_config.dart';
import 'package:path/path.dart' as path;

class BootstrapCommand extends Command<int> {
  BootstrapCommand() {
    argParser.addOption(
      'for',
      help: 'Project type to bootstrap for',
      defaultsTo: 'generic',
      allowed: ['generic', 'counter'],
    );
  }

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
    await _addMaestroToPubspec();
    await _addIntegrationTestToPubspec();
    await _createDefaultTestDriverFile();
    await _createDefaultIntegrationTestFile();

    return 0;
  }
}

bool _hasPubspec() => File('pubspec.yaml').existsSync();

Future<void> _createConfigFile() async {
  final file = File(configFileName);
  if (file.existsSync()) {
    file.deleteSync();
    log.info('Deleted existing $configFileName');
  }

  final progress = log.progress('Creating default $configFileName');

  try {
    final contents = MaestroConfig.defaultConfig().toToml();
    await File(configFileName).writeAsString(contents);
  } catch (err, st) {
    progress.fail('Failed to create default $configFileName');
    log.severe(null, err, st);
    return;
  }

  progress.complete('Created default $configFileName');
}

Future<void> _addMaestroToPubspec() async {
  const package = maestroPackage;

  final progress = log.progress('Adding $package to dev_dependencies');

  final result = await Process.run(
    'flutter',
    ['pub', 'add', package, '--dev'],
    runInShell: true,
  );

  if (result.exitCode != 0) {
    if (result.stdErr.contains('is already in "dev_dependencies"')) {
      progress.complete('$package is already in dev_dependencies');
    } else {
      progress.fail('Failed to add $package to dev_dependencies');
      log.severe(result.stderr);
    }
  } else {
    progress.complete('Added $package to dev_dependencies');
  }
}

Future<void> _addIntegrationTestToPubspec() async {
  const package = integrationTestPackage;

  final progress = log.progress('Adding $package to dev_dependencies');

  final result = await Process.run(
    'flutter',
    ['pub', 'add', package, '--dev', '--sdk', 'flutter'],
    runInShell: true,
  );

  if (result.exitCode != 0) {
    if (result.stdErr.contains('is already in "dev_dependencies"')) {
      progress.complete('$package is already in dev_dependencies');
    } else {
      progress.fail('Failed to add $package to dev_dependencies');
      log.severe(result.stderr);
    }
  } else {
    progress.complete('Added $package to dev_dependencies');
  }
}

Future<void> _createDefaultTestDriverFile() async {
  final relativeFilePath = path.join(driverDirName, driverFileName);

  final progress = log.progress('Creating default $relativeFilePath');

  try {
    final dir = Directory(driverDirName);
    if (!dir.existsSync()) {
      await dir.create();
    }

    final file = File(relativeFilePath);
    if (!file.existsSync()) {
      await file.writeAsString(driverFileContent);
    }
  } catch (err, st) {
    progress.fail('Failed to create default $relativeFilePath');
    log.severe(null, err, st);
    return;
  }

  progress.complete('Created default $relativeFilePath');
}

Future<void> _createDefaultIntegrationTestFile() async {
  final relativeFilePath = path.join(testDirName, testFileName);

  final progress = log.progress('Creating default $relativeFilePath');

  try {
    final dir = Directory(testDirName);
    if (!dir.existsSync()) {
      await dir.create();
    }

    final file = File(relativeFilePath);
    if (!file.existsSync()) {
      await file.writeAsString(testFileContent);
    }
  } catch (err, st) {
    progress.fail('Failed to create default $relativeFilePath');
    log.severe(null, err, st);
    return;
  }

  progress.complete('Created default $relativeFilePath');
}
