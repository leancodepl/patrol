import 'package:e2e_app/keys.dart';
import 'package:flutter/widgets.dart';

import 'common.dart';

void main() {
  // This test is skipped by default, because it must be run with correct
  // build-name (1.2.3) and build-number (123) flags.
  // You can change `skip` to `true` and run it with:
  // dart run ../../packages/patrol_cli/bin/main.dart test \
  // --target patrol_test/app_version_test.dart \
  // --build-name=1.2.3 --build-number=123
  patrolTest(
    'shows correct app version',
    ($) async {
      await createApp($);

      await $(K.appVersion)
          .which<Text>((element) => element.data == 'App version: 1.2.3+123')
          .waitUntilVisible();
    },
    tags: ['app_version'],
    skip: true,
  );
}
