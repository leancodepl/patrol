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
}
