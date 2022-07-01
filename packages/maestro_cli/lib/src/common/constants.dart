/// Version of Maestro CLI. Must be kept in sync with pubspec.yaml.
const version = '0.3.0';

const maestroPackage = 'maestro_test';
const maestroCliPackage = 'maestro_cli';
const integrationTestPackage = 'integration_test';

const pubspecFileName = 'pubspec.yaml';
const configFileName = 'maestro.toml';

const driverDirName = 'test_driver';
const driverFileName = 'integration_test.dart';
const driverFileContent = '''
// ignore_for_file: avoid_print
import 'package:integration_test/integration_test_driver.dart';
import 'package:maestro_test/maestro_test.dart';

// Runs on our machine. Knows nothing about the app being tested.

Future<void> main() async {
  final maestro = Maestro.forDriver();
  while (!await maestro.isRunning()) {
    print('Waiting for maestro automation server...');
    await Future<void>.delayed(const Duration(seconds: 1));
  }
  print('Maestro automation server is running, starting test drive');
  try {
    await integrationDriver();
  } finally {
    print('Stopping Maestro automation server');
    await maestro.stop();
  }
}
''';

const testDirName = 'integration_test';
const testFileName = 'app_test.dart';
