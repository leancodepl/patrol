import 'common.dart';

void main() {
  patrol(
    'performs pull to refresh gesture (native)',
    ($) async {
      await createApp($);
      await $('Open scrolling screen').scrollTo().tap();
      const maxAttempts = 5;
      for (var attempt = 0; attempt < maxAttempts; attempt++) {
        // Perform pull to refresh
        await $.native.pullToRefresh();

        // Wait for the refresh to complete
        await $.pumpAndSettle();

        // Check if the target element exists
        if ($('Awaited item 3').exists) {
          break;
        }
      }
      // Verify if the element is visible
      await $('Awaited item 3').waitUntilVisible();

      await $.pumpAndSettle(duration: const Duration(seconds: 10));
    },
  );
}
