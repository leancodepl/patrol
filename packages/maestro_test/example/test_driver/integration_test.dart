import 'package:integration_test/integration_test_driver.dart';
import 'package:maestro_test/maestro_test.dart';

// Runs on our machine. Knows nothing about the app being tested.
Future<void> main() async {
  final maestro = Maestro.forDriver();
  while (!await maestro.isRunning()) {
    print('Waiting for automator server...');
    await Future<void>.delayed(const Duration(seconds: 1));
  }
  print('Automator server is running, starting test drive');
  try {
    await integrationDriver();
  } finally {
    print('Stopping automator server');
    await maestro.stop();
  }
}
