import '../common.dart';

import 'web_example_app.dart';

void main() {
  patrol('This test is used to `test patrol develop` on web', ($) async {
    await $.pumpWidgetAndSettle(const WebExampleApp());

    await Future<void>.delayed(const Duration(seconds: 1));

    expect($('This is the home page'), findsOneWidget);

    await $('Go to Page 1').scrollTo().tap();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));

    expect($('This is Page 1'), findsOneWidget);

    // Browser navigation is asynchronous and outlives pumpAndSettle, so give
    // it time to land before asserting -- see the other web tests.
    await $.platform.web.goBack();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));

    expect($('This is the home page'), findsOneWidget);
  });
}
