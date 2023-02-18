import 'common.dart';

void main() {
  patrol('disables and enables airplane mode twice', ($) async {
    await createApp($);

    await $.native.disableAirplaneMode();
    await $.native.enableAirplaneMode();
    await $.native.disableAirplaneMode();
    await $.native.enableAirplaneMode();
  });
}
