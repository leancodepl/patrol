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
      await $.platform.mobile.tap(
        MobileSelector(
          android: AndroidSelector(
            text: 'Patrol MCP',
            className: 'android.widget.Button',
          ),
          ios: IOSSelector(
            label: 'Patrol MCP',
            elementType: IOSElementType.button,
          ),
        ),
      );
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
