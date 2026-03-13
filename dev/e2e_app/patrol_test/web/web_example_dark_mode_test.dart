import '../common.dart';

import 'web_example_app.dart';

void main() {
  patrol('dark mode', ($) async {
    await $.pumpWidgetAndSettle(const WebExampleApp());

    await $.platform.web.enableDarkMode();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    expect($('Dark Mode Active'), findsOneWidget);

    await $.platform.web.disableDarkMode();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    expect($('Light Mode Active'), findsOneWidget);

    await $.platform.web.enableDarkMode();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    expect($('Dark Mode Active'), findsOneWidget);
  });
}
