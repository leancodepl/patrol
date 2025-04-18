import 'package:flutter/material.dart';

import 'common.dart';

void main() {
  patrol(
    'swipe back gesture pops top view off the navigation stack',
    ($) async {
      await createApp($);

      await $(find.text('Open loading screen')).tap();

      await $.native.swipeBack(height: 0.2);

      await $(Key('scaffold')).waitUntilVisible();
    },
  );
}
