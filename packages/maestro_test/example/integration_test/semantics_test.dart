import 'package:example/main.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/maestro_test.dart';

import 'config.dart';

Future<void> main() async {
  Maestro.forTest();

  maestroTest(
    'maestroTest works correctly with semantics',
    ($) async {
      await $.pumpWidgetAndSettle(const ExampleApp());

      final semanticsOwner = $.tester.binding.pipelineOwner.semanticsOwner!;

      final button = $.tester.getSemantics(
        find.bySemanticsLabel('Open webview screen (semantic)'),
      );
      semanticsOwner.performAction(button.id, SemanticsAction.tap);
      await $.pumpAndSettle();
      expect($('WebView'), findsOneWidget);
    },
    config: maestroConfig,
  );
}
