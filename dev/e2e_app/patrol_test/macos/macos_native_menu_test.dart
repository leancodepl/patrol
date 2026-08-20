import 'package:flutter/services.dart';

import '../common.dart';

const _macosChannel = MethodChannel('pl.leancode.patrol.e2e/macos');

void main() {
  patrol('taps a nested native application menu', ($) async {
    await createApp($);

    expect(
      await _macosChannel.invokeMethod<int>('getPatrolMenuActionCount'),
      0,
    );

    await $.platform.macos.tapMenu(['Patrol Test', 'Actions', 'Record Action']);

    expect(
      await _macosChannel.invokeMethod<int>('getPatrolMenuActionCount'),
      1,
    );
  }, tags: ['macos']);
}
