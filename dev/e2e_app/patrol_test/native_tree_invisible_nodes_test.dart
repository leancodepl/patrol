import 'common.dart';

void main() {
  patrol(
    'getNativeViews with includeInvisibleNodes returns more than the default tree',
    ($) async {
      await createApp($);

      await $('Open webview (Patrol docs)').scrollTo().tap();
      await $.pump(Duration(seconds: 8));
      await $.pumpAndSettle();

      final defaultTree = await $.platform.android.getNativeViews(null);
      final fullTree = await $.platform.android.getNativeViews(
        null,
        includeInvisibleNodes: true,
      );

      int count(List<AndroidNativeView> nodes) =>
          nodes.fold(0, (sum, node) => sum + 1 + count(node.children));
      final defaultCount = count(defaultTree.roots);
      final fullCount = count(fullTree.roots);
      $.log('default: $defaultCount nodes, includeInvisibleNodes: $fullCount');

      // The docs page has content Chromium flags as not visible to the user
      // (e.g. off-screen), so the unfiltered tree is strictly bigger.
      expect(defaultCount, greaterThan(0));
      expect(fullCount, greaterThan(defaultCount));
    },
    tags: ['webview', 'android'],
  );
}
