import 'common.dart';

void main() {
  patrol('disables and enables location twice', ($) async {
    await createApp($);

    await $.native.disableLocation();
    await $.native.enableLocation();
    await $.native.disableLocation();
    await $.native.enableLocation();
  }, tags: ['locale_testing_android']);
}
