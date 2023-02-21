import 'package:flutter/material.dart';

import 'common.dart';

void main() {
  patrol('good report', ($) async {
    await createApp($);

    await $(FloatingActionButton).tap();
  });

  patrol('bad report', ($) async {
    await createApp($);

    await $(FloatingActionButton).tap();
    await $(FloatingActionButton).tap();
  });
}
