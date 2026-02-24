import 'dart:io';

import 'package:example/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest('camera flow', ($) async {
    await $.pumpWidgetAndSettle(const MyApp());

    await $('Take a photo').tap();

    expect($(Placeholder), findsOneWidget);

    await $('Open camera').tap();

    if (!Platform.isMacOS && !kIsWeb) {
      if (await $.platform.mobile.isPermissionDialogVisible()) {
        await $.platform.mobile.grantPermissionWhenInUse();
      }

      await $.platform.mobile.takeCameraPhoto();

      await $.pumpAndSettle(duration: const Duration(seconds: 1));

      expect($(Placeholder), findsNothing);
      expect($(Image), findsOneWidget);
    }
  });
}
