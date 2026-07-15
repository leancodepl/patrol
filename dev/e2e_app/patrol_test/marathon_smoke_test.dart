import 'package:flutter/material.dart';

import 'common.dart';

/// Lightweight Patrol tests for exercising Marathon iOS sharding.
void main() {
  patrol('marathon smoke counter starts at zero', tags: ['ios', 'simulator'], (
    $,
  ) async {
    await createApp($);
    expect($(#counterText).text, '0');
  });

  patrol('marathon smoke tap once shows one', tags: ['ios', 'simulator'], (
    $,
  ) async {
    await createApp($);
    await $(FloatingActionButton).tap();
    expect($(#counterText).text, '1');
  });

  patrol('marathon smoke tap once shows one copy a', tags: ['ios', 'simulator'], (
    $,
  ) async {
    await createApp($);
    await $(FloatingActionButton).tap();
    expect($(#counterText).text, '1');
  });

  patrol('marathon smoke tap once shows one copy b', tags: ['ios', 'simulator'], (
    $,
  ) async {
    await createApp($);
    await $(FloatingActionButton).tap();
    expect($(#counterText).text, '1');
  });

  patrol('marathon smoke tap twice shows two', tags: ['ios', 'simulator'], (
    $,
  ) async {
    await createApp($);
    await $(FloatingActionButton).tap();
    await $(FloatingActionButton).tap();
    expect($(#counterText).text, '2');
  });

  patrol('marathon smoke tap twice shows two copy a', tags: ['ios', 'simulator'], (
    $,
  ) async {
    await createApp($);
    await $(FloatingActionButton).tap();
    await $(FloatingActionButton).tap();
    expect($(#counterText).text, '2');
  });

  patrol('marathon smoke enter hello text', tags: ['ios', 'simulator'], (
    $,
  ) async {
    await createApp($);
    await $(#textField).enterText('Hello, Marathon!');
    expect($('Hello, Marathon!'), findsOneWidget);
  });

  patrol('marathon smoke enter hello text copy a', tags: ['ios', 'simulator'], (
    $,
  ) async {
    await createApp($);
    await $(#textField).enterText('Hello, Marathon!');
    expect($('Hello, Marathon!'), findsOneWidget);
  });
}
