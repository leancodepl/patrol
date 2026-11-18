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

      AndroidNativeView? find(List<AndroidNativeView> nodes, String text) {
        for (final node in nodes) {
          if (node.text == text || node.contentDescription == text) {
            return node;
          }
          final match = find(node.children, text);
          if (match != null) {
            return match;
          }
        }
        return null;
      }

      // Chromium flags the marker below the 5000px spacer as not visible.
      expect(find(defaultTree.roots, 'Top marker')?.isVisibleToUser, isTrue);
      expect(find(defaultTree.roots, 'Offscreen marker'), isNull);
      expect(find(fullTree.roots, 'Top marker')?.isVisibleToUser, isTrue);
      expect(
        find(fullTree.roots, 'Offscreen marker')?.isVisibleToUser,
        isFalse,
      );
    },
    tags: ['webview', 'android'],
  );
}
