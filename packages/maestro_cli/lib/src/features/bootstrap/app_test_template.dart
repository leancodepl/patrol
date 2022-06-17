import 'package:maestro_cli/src/common/constants.dart';

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
  final maestro = Maestro.forTest();

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

      await maestro.pressHome();

      await maestro.pressDoubleRecentApps();

      expect(findCounterText()!.data, '1');
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(findCounterText()!.data, '2');

      await maestro.pressHome();

      await maestro.openNotifications();

      await maestro.pressBack();
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
  static const _basicCode = '''
// ignore_for_file: avoid_print
import 'package:$dummyProjectName/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:maestro_test/maestro_test.dart';

// This is an example file. Use it as a base to create your own Maestro-powered
// test.
//
// It runs on target device.

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final maestro = Maestro.forTest();

  testWidgets(
    'counter state is the same after going to Home and switching apps',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('app')),
            backgroundColor: Colors.blue,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await maestro.pressHome();

      await maestro.pressDoubleRecentApps();

      await maestro.pressHome();

      await maestro.openNotifications();

      await maestro.pressBack();
    },
  );
}
''';

  @override
  String get code => _code;
}
