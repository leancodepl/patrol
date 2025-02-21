import 'common.dart';

const _timeout = Duration(seconds: 5); // to avoid timeouts on CI

void main() {
  patrol('mock location', ($) async {
    await createApp($);

    await $('Open map screen').scrollTo().tap();
    await $.pumpAndSettle();

    if (await $.native.isPermissionDialogVisible(timeout: _timeout)) {
      await $.native.grantPermissionWhenInUse();
    }

    await $.pumpAndSettle();

    await $.native.setMockLocation(55.2297, 21.0122);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await $.pumpAndSettle();
    expect(await $('Location').waitUntilVisible(), findsOneWidget);
    expect(await $('Latitude: 55.2297').waitUntilVisible(), findsOneWidget);
    expect(await $('Longitude: 21.0122').waitUntilVisible(), findsOneWidget);
    await Future<void>.delayed(const Duration(milliseconds: 1000));

    await $.native.setMockLocation(55.5297, 21.0122);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await $.pumpAndSettle();
    expect(await $('Location').waitUntilVisible(), findsOneWidget);
    expect(await $('Latitude: 55.5297').waitUntilVisible(), findsOneWidget);
    expect(await $('Longitude: 21.0122').waitUntilVisible(), findsOneWidget);
    await Future<void>.delayed(const Duration(milliseconds: 1000));

    await $.native.setMockLocation(55.7297, 21.0122);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await $.pumpAndSettle();
    expect(await $('Location').waitUntilVisible(), findsOneWidget);
    expect(await $('Latitude: 55.7297').waitUntilVisible(), findsOneWidget);
    expect(await $('Longitude: 21.0122').waitUntilVisible(), findsOneWidget);
    await Future<void>.delayed(const Duration(milliseconds: 1000));
  });
}
