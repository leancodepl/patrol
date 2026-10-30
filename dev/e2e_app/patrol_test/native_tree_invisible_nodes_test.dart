import 'common.dart';

void main() {
  patrol(
    'getNativeViews with includeInvisibleNodes returns off-screen WebView nodes',
    ($) async {
      await createApp($);

      await $('Open webview (offscreen content)').scrollTo().tap();
      await $.platform.android.waitUntilVisible(
        AndroidSelector(text: 'Top marker'),
      );

      final defaultTree = await $.platform.android.getNativeViews(null);
      final fullTree = await $.platform.android.getNativeViews(
        null,
        includeInvisibleNodes: true,
      );

      bool contains(List<AndroidNativeView> nodes, String text) => nodes.any(
        (node) =>
            node.text == text ||
            node.contentDescription == text ||
            contains(node.children, text),
      );

      // Chromium flags the marker below the 5000px spacer as not visible.
      expect(contains(defaultTree.roots, 'Top marker'), isTrue);
      expect(contains(defaultTree.roots, 'Offscreen marker'), isFalse);
      expect(contains(fullTree.roots, 'Offscreen marker'), isTrue);
    },
    tags: ['webview', 'android'],
  );
}
