abstract class AppTestTemplate {
  const AppTestTemplate();

  factory AppTestTemplate.fromTemplateName({
    required String templateName,
    required String projectName,
  }) {
    switch (templateName) {
      case CounterTemplate.name:
        return CounterTemplate(projectName: projectName);
      case BasicTemplate.name:
        return const BasicTemplate();
      default:
        throw Exception('Unknown template: $templateName');
    }
  }

  String generateCode();
}

/// Template which can be applied to a default counter app.
class CounterTemplate extends AppTestTemplate {
  const CounterTemplate({required this.projectName});

  static const name = 'counter';

  /// Name of the app project as it appears in pubspec.yaml file.
  final String projectName;

  @override
  String generateCode() {
    return '''
  // ignore_for_file: avoid_print
  import 'package:$projectName/main.dart';
  import 'package:flutter/material.dart';
  import 'package:patrol/patrol.dart';
  
  // This is an example integration test using Patrol. Use it as a base to
  // create your own Patrol-powered test.
  //
  // It runs on target device.
  
  void main() {
  final patrol = Patrol.forTest();
  
  patrolTest(
    'counter state is the same after going to Home and switching apps',
    (\$) async {
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
  
      await \$.pumpWidgetAndSettle(const MyApp());
  
      await \$(FloatingActionButton).tap();
      expect(findCounterText()!.data, '1');
  
      await patrol.pressHome();
  
      await patrol.pressDoubleRecentApps();
  
      expect(findCounterText()!.data, '1');
      await \$(FloatingActionButton).tap();
      expect(findCounterText()!.data, '2');
  
      await patrol.pressHome();
  
      await patrol.openNotifications();
  
      await patrol.pressBack();
  
      await patrol.pressDoubleRecentApps();
    },
  );
  }

  ''';
  }
}

/// Template which can be applied to any app, because it doesn't need to import
/// anything app-specific.
class BasicTemplate extends AppTestTemplate {
  const BasicTemplate();

  static const name = 'basic';

  @override
  String generateCode() => r'''
// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:patrol/patrol.dart';

// This is an example integration test using Patrol. Use it as a base to create
// your own Patrol-powered test.
//
// It runs on target device.

void main() {
  final patrol = Patrol.forTest();

  patrolTest(
    'counter state is the same after going to home and switching apps',
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

      await patrol.pressHome();

      await patrol.pressDoubleRecentApps();

      await patrol.openNotifications();

      await patrol.enableWifi();
      await patrol.disableWifi();
      await patrol.enableWifi();

      await patrol.pressBack();

      expect($('app'), findsOneWidget);
    },
  );
}
''';
}

const driverFileContent = '''
// ignore_for_file: avoid_print
import 'package:integration_test/integration_test_driver.dart';
import 'package:patrol/patrol_drive_helper.dart';

// Runs on our machine. Knows nothing about the app being tested.

Future<void> main() async {
  final patrol = PatrolDriveHelper();
  while (!await patrol.isRunning()) {
    print('Waiting for patrol automation server...');
    await Future<void>.delayed(const Duration(seconds: 1));
  }
  print('Patrol automation server is running, starting test drive');
  try {
    await integrationDriver();
  } finally {
    print('Stopping Patrol automation server');
    await patrol.stop();
  }
}
''';
