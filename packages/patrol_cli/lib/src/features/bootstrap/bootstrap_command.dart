import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:patrol_cli/src/common/common.dart';
import 'package:patrol_cli/src/features/bootstrap/file_contents.dart';
import 'package:patrol_cli/src/features/bootstrap/pubspec.dart' as pubspec;

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
    await _addPatrolToPubspec();
    await _addIntegrationTestToPubspec();
    await _createDefaultTestDriverFile();
    await _createDefaultIntegrationTestFile(templateName);
    await _createDefaultConfigFile();
    _printTodos();

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
  final progress = log.progress('Creating default $driverFilePath');

  try {
    final file = File(driverFilePath)..createSync(recursive: true);
    await file.writeAsString(driverFileContent);
  } catch (err, st) {
    progress.fail('Failed to create default $driverFilePath');
    log.severe(null, err, st);
    return;
  }

  progress.complete('Created default $driverFilePath');
}

Future<void> _createDefaultIntegrationTestFile(String templateName) async {
  final progress = log.progress('Creating default $testFilePath');

  final projectName = pubspec.getName();

  final template = AppTestTemplate.fromTemplateName(
    templateName: templateName,
    projectName: projectName,
  );

  try {
    final file = File(testFilePath)..createSync(recursive: true);
    await file.writeAsString(template.generateCode());
  } catch (err, st) {
    progress.fail('Failed to create default $testFilePath');
    log.severe(null, err, st);
    return;
  }

  progress.complete('Created default $testFilePath');
}

Future<void> _createDefaultConfigFile() async {
  final progress = log.progress('Creating default $configFilePath');

  try {
    final file = File(configFilePath)..createSync(recursive: true);
    await file.writeAsString(configFileContent);
  } catch (err, st) {
    progress.fail('Failed to create default $configFilePath');
    log.severe(null, err, st);
    return;
  }

  progress.complete('Created default $configFilePath');
}

void _printTodos() {
  log
    ..info('🐶 Patrol – ready for action!')
    ..info('Please update $configFilePath with values specific to your app.');
}
