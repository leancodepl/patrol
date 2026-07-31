import '../common.dart';

import 'web_example_app.dart';

void main() {
  patrol('iframe interactions - scroll, enter text, and tap', ($) async {
    await $.pumpWidgetAndSettle(const WebExampleApp());

    await $('Go to Iframe Test').scrollTo().tap();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));

    expect($('Iframe Test'), findsOneWidget);

    final iframeSelector = WebSelector(cssOrXpath: 'iframe');
    final inputSelector = WebSelector(cssOrXpath: '#test-input');
    final buttonSelector = WebSelector(cssOrXpath: '#submit-button');

    await $.platform.web.scrollTo(
      inputSelector,
      iframeSelector: iframeSelector,
    );
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    await $.platform.web.enterText(
      inputSelector,
      text: 'Hello from Patrol!',
      iframeSelector: iframeSelector,
    );
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    await $.platform.web.tap(buttonSelector, iframeSelector: iframeSelector);
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));
  });
}
