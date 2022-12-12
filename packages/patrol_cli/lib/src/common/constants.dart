import 'package:path/path.dart' as path;

/// Version of Patrol CLI. Must be kept in sync with pubspec.yaml.
const globalVersion = '0.7.17';

const patrolPackage = 'patrol';
const patrolCliPackage = 'patrol_cli';
const integrationTestPackage = 'integration_test';

const pubspecFileName = 'pubspec.yaml';

// test_driver directory

const driverDirName = 'test_driver';

const driverFileName = 'integration_test.dart';
final driverFilePath = path.join(driverDirName, driverFileName);

// integration_test directory

const testDirName = 'integration_test';

const testFileName = 'app_test.dart';
final testFilePath = path.join(testDirName, testFileName);

const configFileName = 'config.dart';
final configFilePath = path.join(testDirName, configFileName);
