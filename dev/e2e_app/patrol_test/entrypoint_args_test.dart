import 'common.dart';

void main() {
  patrol(
    'receives Dart entrypoint args from the native side',
    ($) async {
      // Set by getDartEntrypointArgs() in the e2e_app's MainActivity.
      expect($.entrypointArgs, contains('--patrol-e2e'));
    },
    tags: ['android', 'emulator', 'physical_device'],
  );
}
