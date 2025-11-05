import 'common.dart';

void main() {
  patrol('counter state is the same after going to Home and switching apps', (
    $,
  ) async {
    await createApp($);

    await $.native2.enableDarkMode();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));

    await $.native2.disableDarkMode();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));

    await $.native2.enableDarkMode();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));
  });

  patrol('grant permissions', ($) async {
    await createApp($);

    await $('Open permissions screen').scrollTo().tap();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));

    await $.native2.grantPermissions(permissions: ['geolocation']);
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));

    await $('Request location permission').tap();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));

    await $.native2.clearPermissions();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));

    await $('Request location permission').tap();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));
  });
}
