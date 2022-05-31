import 'package:integration_test/integration_test_driver.dart';
import 'package:maestro/maestro.dart';

Future<void> main() async {
  print('Waiting for automator server');
  Automator.init();
  while (!await Automator.instance.isRunning()) {}
  print('Automator server is running, starting test drive');
  try {
    print('here 0');
    await integrationDriver();
  } finally {
    print('Stopping automator server');
    await Automator.instance.stop();
  }
}
