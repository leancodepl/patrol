import 'package:flutter_test/flutter_test.dart';

abstract class WebAutomator {
  Future<void> initialize();

  Future<void> enableDarkMode();

  Future<void> disableDarkMode();
}
