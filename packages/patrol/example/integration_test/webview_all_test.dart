import 'package:flutter_test/flutter_test.dart';

import 'webview_hackernews_test.dart' as hackernews;
import 'webview_leancode_test.dart' as leancode;
import 'webview_login_test.dart' as login;
import 'webview_stackoverflow_test.dart' as stackoverflow;

void main() {
  group('all webviews', () {
    leancode.main();
    hackernews.main();
    stackoverflow.main();
    login.main();
  });
}
