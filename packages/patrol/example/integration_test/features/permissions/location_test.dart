import '../../common.dart';

void main() {
  patrol('accepts location permission', ($) async {
    await $.pumpWidgetAndSettle(ExampleApp());

    await $('Open location screen').tap();

    await $('Grant permission').tap();

    await $.native.selectCoarseLocation();
    await $.native.selectFineLocation();
    await $.native.grantPermissionOnlyThisTime();

    await $.pump();

    expect(await $(RegExp('lat')).waitUntilVisible(), findsOneWidget);
    expect(await $(RegExp('lng')).waitUntilVisible(), findsOneWidget);
  });
}
