import '../common.dart';

import 'web_example_app.dart';

void main() {
  patrol('interact with form in new page while navigating Flutter app',
      ($) async {
    await $.pumpWidgetAndSettle(const WebExampleApp());

    final formUrl = '${Uri.base.origin}/assets/assets/iframe_content.html';
    final newPageId = await $.platform.web.openNewPage(url: formUrl);
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));

    final pagesResult = await $.platform.web.getPages();
    final pages = pagesResult['pages'] as List<Object?>;
    expect(pages.length, 2);

    // Fill form in the new page
    await $.platform.web.switchToPage(pageId: newPageId);
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    await $.platform.web.enterText(
      WebSelector(cssOrXpath: '#test-input'),
      text: 'Patrol multi-page test',
    );
    await $.platform.web.tap(WebSelector(cssOrXpath: '#submit-button'));
    await Future<void>.delayed(const Duration(seconds: 1));

    // Switch back and navigate the Flutter app
    await $.platform.web.switchToPage(pageId: 'page_0');
    await $.pumpAndSettle();

    await $('Go to Page 1').scrollTo().tap();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));

    expect($('This is Page 1'), findsOneWidget);

    await $.platform.web.goBack();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));

    expect($('This is the home page'), findsOneWidget);

    await $.platform.web.closePage(pageId: newPageId);

    final finalPages = await $.platform.web.getPages();
    final remaining = finalPages['pages'] as List<Object?>;
    expect(remaining.length, 1);
  });
}
