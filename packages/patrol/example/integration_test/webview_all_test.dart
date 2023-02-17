import 'package:flutter_test/flutter_test.dart';

import 'webview_hackernews_test.dart';
import 'webview_leancode_test.dart';
import 'webview_login_test.dart';
import 'webview_stackoverflow_test.dart';

void main() {
  group('Patrol', () {
    testWebViewA();
    testWebViewB();
    testWebViewC();
    testWebViewD();
  });
}
