import 'package:e2e_app/keys.dart';

import 'common.dart';

void main() {
  patrol('performs pull to refresh gesture', ($) async {
    await createApp($);
    await $('Open scrolling screen').scrollTo().tap();
    expect($(K.refreshText), findsNothing);
    await $.platform.mobile.pullToRefresh();
    await $(K.refreshText).waitUntilVisible();
  });
}
