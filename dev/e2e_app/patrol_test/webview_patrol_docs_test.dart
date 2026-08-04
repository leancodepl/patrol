import 'common.dart';

void main() {
  patrol(
    'interacts with the Patrol docs website in a webview',
    ($) async {
      await createApp($);

      await $('Open webview (Patrol docs)').scrollTo().tap();
      await $.pump(const Duration(seconds: 5));

      // Dismiss the cookie consent popup if it appears
      try {
        await $.platform.mobile.tap(
          Selector(text: 'ACCEPT ALL COOKIES'),
          timeout: const Duration(seconds: 10),
        );
      } on PatrolActionException catch (_) {
        // nothing
      }

      await Future<void>.delayed(const Duration(seconds: 5));
      // Open the search modal and type a query into its input field.
      await $.platform.mobile.tap(
        MobileSelector(
          android: AndroidSelector(text: 'Open Search'),
          ios: IOSSelector(label: 'Open Search'),
        ),
      );
      await $.platform.mobile.enterTextByIndex(
        'Patrol MCP',
        index: 0,
        keyboardBehavior: KeyboardBehavior.showAndDismiss,
      );
      final patrolMcpResult = MobileSelector(
        android: AndroidSelector(text: 'Patrol MCP'),
        ios: IOSSelector(
          label: 'Patrol MCP',
          elementType: IOSElementType.button,
        ),
      );
      // The search results are fetched asynchronously over the network, so
      // wait for the result to render before tapping it instead of racing it.
      await $.platform.mobile.waitUntilVisible(patrolMcpResult);
      await $.platform.mobile.tap(patrolMcpResult);
      await Future<void>.delayed(const Duration(seconds: 5));
      await $.platform.mobile.waitUntilVisible(
        MobileSelector(
          android: AndroidSelector(
            text: 'AI-powered test automation with Patrol MCP server',
          ),
          ios: IOSSelector(
            label: 'AI-powered test automation with Patrol MCP server',
          ),
        ),
      );
    },
    tags: ['webview', 'android', 'ios'],
  );
}
