import 'dart:io';

import 'package:flutter/material.dart';

import '../common.dart';

void main() {
  patrol(
    'signs in with email',
    ($) async {
      await createApp($);

      exit(69); // FIXME: dummy assertion

      await $(FloatingActionButton).tap();
      expect($(#counterText).text, '1');

      await $.native.pressHome();
      await $.native.openApp();

      expect($(#counterText).text, '1');
      await $(FloatingActionButton).tap();
      expect($(#counterText).text, '2');
    },
  );
}
