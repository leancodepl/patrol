import 'dart:io';

import 'package:example/main.dart';
import 'package:example/pages/quiz/form_page.dart';
import 'package:example/ui/components/button/elevated_button.dart';
import 'package:example/ui/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest('main flow', ($) async {
    await $.pumpWidgetAndSettle(const MyApp());

    await $('Go to the quiz').tap();

    await $('Start').tap();

    await $(TextField).enterText('text');

    final colors = [PTColors.lcYellow, PTColors.lcBlack, PTColors.lcWhite];

    for (final color in colors) {
      await $(SelectableBox)
          .which<SelectableBox>((box) => box.color == color)
          .scrollTo()
          .tap();
    }

    await $('Ready!').tap();

    // Why doesn't it work?
    // await $(ElevatedButton).$(Center).$('Fluttercon').tap();

    await $(PTElevatedButton)
        .which<PTElevatedButton>((widget) => widget.caption == 'Fluttercon')
        .tap();

    await $(ListTile).containing($(Icons.flutter_dash)).$('click').tap();

    // For macOS we don't want to continue the test as we don't have support for native interactions
    if (!Platform.isMacOS) {
      await $(ElevatedButton)
          .which<ElevatedButton>(
            (widget) => widget.enabled,
          )
          .at(2)
          .scrollTo()
          .tap();

      if (await $.native.isPermissionDialogVisible()) {
        await $.native.grantPermissionWhenInUse();
      }

      await $.native.pressHome();
      await $.native.openNotifications();

      // wait for notification to show up
      await Future<void>.delayed(const Duration(seconds: 5));

      await $.native.openNotifications();

      await $.native.tapOnNotificationByIndex(0);

      await $.pumpAndSettle();

      expect($('Congratulations!'), findsOneWidget);
    }
  });
}
