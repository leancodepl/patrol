import 'dart:collection';

import '../common.dart';

import 'web_example_app.dart';

void main() {
  patrol('cookies', ($) async {
    await $.pumpWidgetAndSettle(const WebExampleApp());

    await $.platform.web.addCookie(
      name: 'test_cookie',
      value: 'cookie_value',
      url: 'http://localhost:8080',
    );
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    var cookies = await $.platform.web.getCookies();
    var testCookie = cookies.firstWhere(
      (c) => c['name'] == 'test_cookie',
      orElse: LinkedHashMap<Object?, Object?>.new,
    );
    expect(testCookie['value'], 'cookie_value');
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    await $.platform.web.clearCookies();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    cookies = await $.platform.web.getCookies();
    testCookie = cookies.firstWhere(
      (c) => c['name'] == 'test_cookie',
      orElse: LinkedHashMap<Object?, Object?>.new,
    );
    expect(testCookie.isEmpty, isTrue);
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));
  });
}
