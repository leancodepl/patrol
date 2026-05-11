import 'dart:collection';

import '../common.dart';

import 'web_example_app.dart';

void main() {
  patrol('open external page, fill form, and return to Flutter app', ($) async {
    await $.pumpWidgetAndSettle(const WebExampleApp());

    final formUrl = '${Uri.base.origin}/assets/assets/iframe_content.html';
    final newPageId = await $.platform.web.openNewPage(url: formUrl);
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));

    await $.platform.web.switchToPage(pageId: newPageId);
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    final currentTab = await $.platform.web.getCurrentPage();
    expect(currentTab, newPageId);

    await $.platform.web.enterText(
      WebSelector(cssOrXpath: '#test-input'),
      text: 'Hello from new tab',
    );
    await $.platform.web.tap(WebSelector(cssOrXpath: '#submit-button'));
    await Future<void>.delayed(const Duration(seconds: 1));

    await $.platform.web.switchToMainPage();
    await $.pumpAndSettle();

    expect(await $.platform.web.getCurrentPage(), 'page_0');
    expect($('This is the home page'), findsOneWidget);

    await $.platform.web.closePage(pageId: newPageId);
  });

  patrol('open leancode.co, accept cookies, and close tab', ($) async {
    await $.pumpWidgetAndSettle(const WebExampleApp());

    final newPageId = await $.platform.web.openNewPage(
      url: 'https://leancode.co/',
    );
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 3));

    await $.platform.web.switchToPage(pageId: newPageId);
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));

    await $.platform.web.tap(WebSelector(text: 'Accept All'));
    await Future<void>.delayed(const Duration(seconds: 1));

    await $.platform.web.switchToMainPage();
    await $.pumpAndSettle();

    expect($('This is the home page'), findsOneWidget);

    await $.platform.web.closePage(pageId: newPageId);
  });

  patrol('cross-tab cookies persist across browser context', ($) async {
    await $.pumpWidgetAndSettle(const WebExampleApp());

    await $.platform.web.addCookie(
      name: 'session',
      value: 'abc123',
      url: Uri.base.origin,
    );

    var cookies = await $.platform.web.getCookies();
    var sessionCookie = cookies.firstWhere(
      (c) => c['name'] == 'session',
      orElse: LinkedHashMap<Object?, Object?>.new,
    );
    expect(sessionCookie['value'], 'abc123');

    final formUrl = '${Uri.base.origin}/assets/assets/iframe_content.html';
    final newPageId = await $.platform.web.openNewPage(url: formUrl);
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));

    await $.platform.web.switchToPage(pageId: newPageId);
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    cookies = await $.platform.web.getCookies();
    sessionCookie = cookies.firstWhere(
      (c) => c['name'] == 'session',
      orElse: LinkedHashMap<Object?, Object?>.new,
    );
    expect(sessionCookie['value'], 'abc123');

    await $.platform.web.switchToMainPage();
    await $.pumpAndSettle();

    await $.platform.web.clearCookies();
    await $.platform.web.closePage(pageId: newPageId);
  });
}
