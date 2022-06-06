import 'package:integration_test/integration_test_driver.dart';
import 'package:maestro_test/maestro_test.dart';

// Runs on our machine. Knows nothing about the app being tested.
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
