import 'package:cross_origin_lib/cross_origin_lib.dart';
import 'package:flutter_test/flutter_test.dart';

// Explicit pause between user-visible actions, so a human observer can
// follow the flow when running in headed mode. Comment out / shorten for
// regular CI runs.
const _step = Duration(milliseconds: 800);
Future<void> pause() => Future<void>.delayed(_step);

void main() {
  patrolRemoteTest(
    'panel_auth_canvas_roundtrip',
    startsIn: 'panel',
    callback: ($) async {
      expect(await $(#status_anon).count, 1);
      await pause();

      await $(#go_login).tap();
      await $.waitForApp('auth');
      await pause();

      await $(#email).enterText('foo@bar.com');
      await pause();
      await $(#password).enterText('s3cret');
      await pause();
      await $(#sign_in).tap();
      await $.waitForApp('panel');
      await pause();

      expect(await $('Hello foo@bar.com').count, 1);
      await pause();

      await $(#go_canvas).tap();
      await $.waitForApp('canvas');
      await pause();

      await $(#increment).tap();
      await pause();
      await $(#save_back).tap();
      await $.waitForApp('panel');
      await pause();

      expect(await $('Hello foo@bar.com, canvas value: 1').count, 1);
    },
  );
}
