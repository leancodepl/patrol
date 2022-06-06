/// Version of Maestro CLI. Must be kept in sync with pubspec.yaml.
const version = '0.0.7';

const maestroPackage = 'maestro_test';
const maestroCliPackage = 'maestro_cli';
const integrationTestPackage = 'integration_test';

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
import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:$maestroPackage/$maestroPackage.dart';

// This is an example file. Use it as a base to create your own Maestro-powered
// test.
//
// It runs on target device.

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  Automator.init(verbose: true);
  final automator = Automator.instance;

  testWidgets(
    'counter state is the same after going to Home and switching apps',
    (tester) async {
      /// Find the first Text widget whose content is a String which represents
      /// a num.
      Text? findCounterText() {
        final textWidgets = find.byType(Text);
        final foundElements = textWidgets.evaluate();

        for (final element in foundElements) {
          final textWidget = element.widget as Text;
          final text = textWidget.data;
          if (text == null) {
            continue;
          }

          final number = num.tryParse(text);
          if (number != null) {
            return textWidget;
          }
        }

        return null;
      }

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(findCounterText()!.data, '1');

      await automator.pressHome();

      await automator.pressDoubleRecentApps();

      expect(findCounterText()!.data, '1');
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(findCounterText()!.data, '2');

      await automator.pressHome();

      await automator.openNotifications();
    },
  );
}

''';
