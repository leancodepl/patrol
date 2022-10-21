import 'package:flutter_test/flutter_test.dart';

import 'webview_a_test.dart';
import 'webview_b_test.dart';

void main() {
  group('tests webviews', () {
    testWebViewA();
    testWebViewB();
  });
}
