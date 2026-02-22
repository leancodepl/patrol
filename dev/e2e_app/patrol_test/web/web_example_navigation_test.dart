import '../common.dart';

import 'web_example_app.dart';

void main() {
  patrol('navigation', ($) async {
    await $.pumpWidgetAndSettle(const WebExampleApp());

    await Future<void>.delayed(const Duration(seconds: 1));

    await $('Go to Page 1').scrollTo().tap();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));

    expect($('This is Page 1'), findsOneWidget);

    await $.platform.web.goBack();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));

    expect($('This is the home page'), findsOneWidget);

    await $.platform.web.goForward();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));

    expect($('This is Page 1'), findsOneWidget);
  });
}
