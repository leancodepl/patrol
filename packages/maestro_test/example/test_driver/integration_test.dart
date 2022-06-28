import 'package:integration_test/integration_test_driver.dart';
import 'package:maestro_test/maestro_test.dart';

// Runs on our machine. Knows nothing about the app being tested.
Future<void> main() async {
  final maestro = Maestro.forDriver();
  while (!await maestro.healthCheck()) {
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
