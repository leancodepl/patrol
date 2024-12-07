import 'package:flutter/material.dart';

import 'common.dart';

void main() {
  patrol('Enter text twice into one field', ($) async {
    await createApp($);

    await $('Open text fields screen').scrollTo().tap();

    await $(const Key('textFieldUsername')).enterText('User');
    await $(const Key('homepage_search_button')).tap();
    await $('Item 10').scrollTo().tap();
    await $(const Key('textFieldUsername'))
        .scrollTo(scrollDirection: AxisDirection.up);
    expect($('User'), findsOneWidget);

    await $(const Key('textFieldUsername')).enterText('User2');
    await $(const Key('homepage_search_button')).tap();
    expect($('User'), findsNothing);
    expect($('User2'), findsOneWidget);
  });
}
