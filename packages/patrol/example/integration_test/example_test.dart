import 'package:flutter/material.dart';

import 'common.dart';

void main() {
  patrol(
    'aye',
    ($) async {
      await createApp($);

      await Future.delayed(Duration(seconds: 10));

      await $(ListView).$(ListTile).at(1).tap();
    },
  );
}
