import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Enriches [WidgetTester] with a more pleasant, tester-friendly API.
extension WidgetTesterX on WidgetTester {
  /// Find the first Text widget whose content is a [String] which can be parsed
  /// into a [num].
  Text? findTextWithNumber() {
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
}
