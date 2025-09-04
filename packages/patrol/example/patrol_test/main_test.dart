import 'package:example/main.dart';
import 'package:example/pages/quiz/form_page.dart';
import 'package:example/ui/components/button/elevated_button.dart';
import 'package:example/ui/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest('main flow', ($) async {
    await $.pumpWidgetAndSettle(const MyApp());

    await $('Go to the quiz').tap();

    await $('Start').tap();

    await $(TextField).enterText('text');

    final colors = [PTColors.lcYellow, PTColors.lcBlack, PTColors.lcWhite];

    for (final color in colors) {
      await $(
        SelectableBox,
      ).which<SelectableBox>((box) => box.color == color).scrollTo().tap();
    }

    await $('Ready!').tap();

    await $(
      PTElevatedButton,
    ).which<PTElevatedButton>((widget) => widget.caption == 'Fluttercon').tap();

    await $(ListTile).containing($(Icons.flutter_dash)).$('click').tap();
  });
}
