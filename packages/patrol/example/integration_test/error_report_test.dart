import 'package:flutter/material.dart';

import 'common.dart';

void main() {
  patrol('good report', ($) async {
    await createApp($);

    await $(FloatingActionButton).tap();
    expect($('1'), findsOneWidget);
  });

  patrol('bad report', ($) async {
    await createApp($);

    await $(FloatingActionButton).tap();
    await $(FloatingActionButton).tap();
    expect($('2'), findsOneWidget);
  });
}
