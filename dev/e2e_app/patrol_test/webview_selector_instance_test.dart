import 'dart:io';

import 'common.dart';

void main() {
  patrol('native selector instance picks the n-th match in a WebView', (
    $,
  ) async {
    await createApp($);

    await $('Open webview (duplicate text)').scrollTo().tap();
    await $.platform.mobile.waitUntilVisible(Selector(text: 'Unique'));

    // iOS also counts wrapper elements with the same label, so count matches
    // on each platform instead of assuming 2.
    final matches = Platform.isIOS
        ? (await $.platform.ios.getNativeViews(
            IOSSelector(text: 'Duplicate'),
          )).roots.length
        : (await $.platform.android.getNativeViews(
            AndroidSelector(text: 'Duplicate'),
          )).roots.length;
    expect(matches, greaterThanOrEqualTo(2));

    await $.platform.mobile.waitUntilVisible(
      Selector(text: 'Duplicate', instance: matches - 1),
    );

    // One past the last match must not be found, whichever selector type.
    final outOfRange = <String, CompoundSelector>{
      'Selector': Selector(text: 'Duplicate', instance: matches),
      'PlatformSelector': PlatformSelector(
        android: AndroidSelector(text: 'Duplicate', instance: matches),
        ios: IOSSelector(text: 'Duplicate', instance: matches),
      ),
    };
    for (final MapEntry(key: name, value: selector) in outOfRange.entries) {
      await expectLater(
        $.platform.mobile.waitUntilVisible(
          selector,
          timeout: const Duration(seconds: 5),
        ),
        throwsA(isA<PatrolActionException>()),
        reason: '$name with instance $matches of $matches matches',
      );
    }
  }, tags: ['webview', 'android', 'ios']);
}
