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
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'config.dart';

// This is an example integration test using Patrol. Use it as a base to
// create your own Patrol-powered test.
//
// To run it, you have to use `patrol drive` instead of `flutter test`.
  
void main() {
  patrolTest(
    'counter state is the same after going to Home and switching apps',
    config: patrolConfig,
    nativeAutomation: true,
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
  
      await \$.native.pressHome();
  
      await \$.native.pressDoubleRecentApps();
  
      expect(findCounterText()!.data, '1');
      await \$(FloatingActionButton).tap();
      expect(findCounterText()!.data, '2');
  
      await \$.native.pressHome();
  
      await \$.native.openNotifications();
  
      await \$.native.pressBack();
  
      await \$.native.pressDoubleRecentApps();
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
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'config.dart';

// This is an example integration test using Patrol. Use it as a base to
// create your own Patrol-powered test.
//
// To run it, you have to use `patrol drive` instead of `flutter test`.

void main() {
  patrolTest(
    'counter state is the same after going to home and switching apps',
    config: patrolConfig,
    nativeAutomation: true,
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

      await $.native.pressHome();

      await $.native.pressDoubleRecentApps();

      await $.native.openNotifications();

      await $.native.enableWifi();
      await $.native.disableWifi();
      await $.native.enableWifi();

      await $.native.pressBack();

      expect($('app'), findsOneWidget);
    },
  );
}
''';
}

const driverFileContent = '''
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
''';

const configFileContent = '''
import 'package:patrol/patrol.dart';

// TODO: Replace with values specific to your app.
const patrolConfig = PatrolTestConfig(
  appName: 'Example App',
  packageName: 'pl.leancode.patrol.example',
  bundleId: 'pl.leancode.patrol.Example',
);
''';
