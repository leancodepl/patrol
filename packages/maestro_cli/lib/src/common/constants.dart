/// Version of Maestro CLI. Must be kept in sync with pubspec.yaml.
const version = '0.1.1';

const maestroPackage = 'maestro_test';
const maestroCliPackage = 'maestro_cli';
const integrationTestPackage = 'integration_test';

const pubspecFileName = 'pubspec.yaml';
const configFileName = 'maestro.toml';

const driverDirName = 'test_driver';
const driverFileName = 'integration_test.dart';
const driverFileContent = '''
import 'package:integration_test/integration_test_driver.dart';
import 'package:$maestroPackage/$maestroPackage.dart';

// Runs on your machine. Knows nothing about the app being tested.

Future<void> main() async {
  print('Waiting for automator server');
  Automator.init(verbose: true);
  while (!await Automator.instance.isRunning()) {}
  print('Automator server is running, starting test drive');
  try {
    await integrationDriver();
  } finally {
    print('Stopping automator server');
    await Automator.instance.stop();
  }
}
''';

const testDirName = 'integration_test';
const testFileName = 'app_test.dart';
