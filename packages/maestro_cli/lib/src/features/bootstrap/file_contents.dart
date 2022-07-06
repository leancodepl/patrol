import 'package:maestro_cli/src/common/common.dart';

abstract class AppTestTemplate {
  const AppTestTemplate();

  factory AppTestTemplate.fromTemplateName({
    required String templateName,
    required String projetName,
  }) {
    switch (templateName) {
      case counter:
        return const CounterTemplate();
      case generic:
        return GenericTemplate(name: projetName);
      default:
        throw Exception('Unknown template: $templateName');
    }
  }

  static const counter = 'counter';
  static const generic = 'generic';

  String get code;
}

class CounterTemplate extends AppTestTemplate {
  const CounterTemplate();

  @override
  String get code => _code;

  static const _code = '''
// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:$maestroPackage/$maestroPackage.dart';

// This is an example integration test using Maestro. Use it as a base to create
// your own Maestro-powered test.
//
// It runs on target device.

void main() {
  final maestro = Maestro.forTest();

  maestroTest(
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

      await tester.pumpWidgetAndSettle(const MyApp());

      await \$(FloatingActionButton).tap();
      expect(findCounterText()!.data, '1');

      await maestro.pressHome();

      await maestro.pressDoubleRecentApps();

      expect(findCounterText()!.data, '1');
      await \$(FloatingActionButton).tap();
      await tester.pumpAndSettle();
      expect(findCounterText()!.data, '2');

      await maestro.pressHome();

      await maestro.openHalfNotificationShade();

      await maestro.pressBack();

      await maestro.pressDoubleRecentApps();
    },
  );
}
''';
}

class GenericTemplate extends AppTestTemplate {
  GenericTemplate({required this.name})
      : _code = _basicCode.replaceFirst(dummyProjectName, name);

  /// Name of the app project as it appears in pubspec.yaml file.
  final String name;

  final String _code;

  static const dummyProjectName = 'PROJECT_NAME';
  static const _basicCode = r'''
// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/maestro_test.dart';

// This is an example integration test using Maestro. Use it as a base to create
// your own Maestro-powered test.
//
// It runs on target device.

void main() {
  final maestro = Maestro.forTest();

  maestroTest(
    'counter state is the same after going to Home and switching apps',
    ($) async {
      // Replace with your own app widget.
      await $.pumpWidgetAndSettle(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('app')),
            backgroundColor: Colors.blue,
          ),
        ),
      );

      await maestro.pressHome();

      await maestro.pressDoubleRecentApps();

      await maestro.openHalfNotificationShade();

      await maestro.enableWifi();
      await maestro.disableWifi();
      await maestro.enableWifi();

      await maestro.pressBack();

      expect($('app'), findsOneWidget);
    },
  );
}
''';

  @override
  String get code => _code;
}

const driverFileContent = '''
// ignore_for_file: avoid_print
import 'package:integration_test/integration_test_driver.dart';
import 'package:maestro_test/maestro_drive_helper.dart';

// Runs on our machine. Knows nothing about the app being tested.

Future<void> main() async {
  final maestro = MaestroDriveHelper();
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
