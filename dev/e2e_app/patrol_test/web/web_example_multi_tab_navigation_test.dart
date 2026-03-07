import '../common.dart';

import 'web_example_app.dart';

void main() {
  patrol('interact with form in new tab while navigating Flutter app',
      ($) async {
    await $.pumpWidgetAndSettle(const WebExampleApp());

    final formUrl = '${Uri.base.origin}/assets/assets/iframe_content.html';
    final newTabId = await $.platform.web.openNewTab(url: formUrl);
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));

    final tabsResult = await $.platform.web.getTabs();
    final tabs = tabsResult['tabs'] as List<Object?>;
    expect(tabs.length, 2);

    // Fill form in the new tab
    await $.platform.web.switchToTab(tabId: newTabId);
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    await $.platform.web.enterText(
      WebSelector(cssOrXpath: '#test-input'),
      text: 'Patrol multi-tab test',
    );
    await $.platform.web.tap(WebSelector(cssOrXpath: '#submit-button'));
    await Future<void>.delayed(const Duration(seconds: 1));

    // Switch back and navigate the Flutter app
    await $.platform.web.switchToTab(tabId: 'tab_0');
    await $.pumpAndSettle();

    await $('Go to Page 1').scrollTo().tap();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));

    expect($('This is Page 1'), findsOneWidget);

    await $.platform.web.goBack();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));

    expect($('This is the home page'), findsOneWidget);

    await $.platform.web.closeTab(tabId: newTabId);

    final finalTabs = await $.platform.web.getTabs();
    final remaining = finalTabs['tabs'] as List<Object?>;
    expect(remaining.length, 1);
  });
}
