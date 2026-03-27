import 'common.dart';

void main() {
  patrol(
    'open iOS settings and return with breadcrumb button',
    ($) async {
      await createApp($);

      await $(#openExternalAppScreenButton).scrollTo().tap();

      await $(#openIosSettingsButton).tap();

      await $.platform.ios.tapBackToPreviousAppButton();

      await $.waitUntilVisible($(#externalAppStatusText));
      await $.waitUntilVisible($(#openIosSettingsButton));
    },
    tags: ['ios', 'simulator', 'physical_device'],
  );
}
