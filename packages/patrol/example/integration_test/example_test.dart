import 'package:flutter/material.dart';

import 'common.dart';

void main() {
  patrol(
    'aye',
    ($) async {
      await createApp($);

      await $(ListView).$(ListTile).tap();
      await $(ListView).$(ListTile).at(1).tap();
    },
  );
}
