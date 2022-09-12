import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import 'package:patrol_cli/src/common/common.dart';
import 'package:patrol_cli/src/features/bootstrap/file_contents.dart';
import 'package:patrol_cli/src/features/bootstrap/pubspec.dart' as pubspec;
import 'package:patrol_cli/src/patrol_config.dart';

class BootstrapCommand extends Command<int> {
  BootstrapCommand() {
    argParser.addOption(
      'template',
      help: 'Project type to bootstrap for',
      defaultsTo: BasicTemplate.name,
      allowed: [BasicTemplate.name, CounterTemplate.name],
    );
  }

  @override
  String get name => 'bootstrap';

  @override
  String get description =>
      'Create default config and test files and add patrol as a dev dependency.';

  @override
  Future<int> run() async {
    final dynamic templateName = argResults?['template'];
    if (templateName is! String) {
      throw const FormatException('`template` argument is not a string');
    }

    _ensureHasPubspec();
    await _createConfigFile();
    await _addPatrolToPubspec();
    await _addIntegrationTestToPubspec();
    await _createDefaultTestDriverFile();
    await _createDefaultIntegrationTestFile(templateName);

    return 0;
  }
}

void _ensureHasPubspec() {
  final pubspecExists = File('pubspec.yaml').existsSync();

  if (!pubspecExists) {
    throw Exception(
      'No pubspec.yaml found. Patrol must be run from Flutter project root.',
    );
  }
}

Future<void> _createConfigFile() async {
  final file = File(configFileName);
  if (file.existsSync()) {
    file.deleteSync();
    log.info('Deleted existing $configFileName');
  }

  final progress = log.progress('Creating default $configFileName');

  try {
    final contents = PatrolConfig.defaultConfig().toToml();
    await File(configFileName).writeAsString(contents);
  } catch (err) {
    progress.fail('Failed to create default $configFileName');
    rethrow;
  }

  progress.complete('Created default $configFileName');
}

Future<void> _addPatrolToPubspec() async {
  const package = patrolPackage;

  final progress = log.progress('Adding $package to dev_dependencies');

  final result = await Process.run(
    'flutter',
    ['pub', 'add', package, '--dev'],
    runInShell: true,
  );

  if (result.exitCode != 0) {
    if (result.stdOut.contains('is already in "dev_dependencies"')) {
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
    if (result.stdOut.contains('is already in "dev_dependencies"')) {
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
    await file.writeAsString(driverFileContent);
  } catch (err, st) {
    progress.fail('Failed to create default $relativeFilePath');
    log.severe(null, err, st);
    return;
  }

  progress.complete('Created default $relativeFilePath');
}

Future<void> _createDefaultIntegrationTestFile(String templateName) async {
  final relativeFilePath = path.join(testDirName, testFileName);

  final progress = log.progress('Creating default $relativeFilePath');

  final projectName = pubspec.getName();

  final template = AppTestTemplate.fromTemplateName(
    templateName: templateName,
    projectName: projectName,
  );

  try {
    final dir = Directory(testDirName);
    if (!dir.existsSync()) {
      await dir.create();
    }

    final file = File(relativeFilePath);
    await file.writeAsString(template.generateCode());
  } catch (err, st) {
    progress.fail('Failed to create default $relativeFilePath');
    log.severe(null, err, st);
    return;
  }

  progress.complete('Created default $relativeFilePath');
}
