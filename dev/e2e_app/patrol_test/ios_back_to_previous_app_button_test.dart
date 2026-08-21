import 'package:e2e_app/keys.dart';

import 'common.dart';

void main() {
  patrol(
    'open iOS settings and return with breadcrumb button',
    ($) async {
      await createApp($);

      await $(#openExternalAppScreenButton).scrollTo().tap();

      await $(#openIosSettingsButton).tap();

      await $.platform.ios.tapBackToPreviousAppButton();

      await $(K.externalAppStatusText).waitUntilVisible();
      await $(K.openIosSettingsButton).waitUntilVisible();
    },
    tags: ['ios', 'simulator', 'physical_device'],
  );
}
