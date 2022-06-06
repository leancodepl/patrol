/// Version of Maestro CLI. Must be kept in sync with pubspec.yaml.
const version = '0.0.7';

const maestroPackage = 'maestro';
const integrationTestPackage = 'integration_test';
const maestroCliPackage = 'maestro_cli';

const configFileName = 'maestro.toml';

const driverDirName = 'test_driver';
const driverFileName = 'integration_test.dart';
const driverFileContent = '''
import 'package:integration_test/integration_test_driver.dart';
import 'package:$maestroPackage/$maestroPackage.dart';

// Runs on the your machine. Knows nothing about the app being tested.

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
const testFileContent = '''
// TODO: This is an example file. Use it as a base to create your own
// Maestro-powered test.

import 'package:example/main.dart' as app; // TODO: replace with your app.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:maestro/maestro.dart';

// Runs on the target device.

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  Automator.init(verbose: true);
  final automator = Automator.instance;

  testWidgets(
    'counter state is the same after going to Home and switching apps',
    (tester) async {
      Text findCounterText() {
        return tester
            .firstElement(find.byKey(const ValueKey('counterText')))
            .widget as Text;
      }

      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(findCounterText().data, '1');

      await automator.pressHome();
      print('after press home 1');

      await automator.pressDoubleRecentApps();
      print('after press recent apps 1');

      expect(findCounterText().data, '1');
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(findCounterText().data, '2');
    },
  );
}

''';
