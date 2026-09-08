import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/src/platform/android/android_automator_config.dart';
import 'package:patrol/src/platform/android/android_automator_native.dart';

void main() {
  group('AndroidAutomatorConfig', () {
    test('accessibility flags default to true', () {
      const config = AndroidAutomatorConfig();

      expect(config.dontSuppressAccessibilityServices, isTrue);
      expect(config.retrieveInteractiveWindows, isTrue);
    });

    test('copyWith overrides the accessibility flags', () {
      const config = AndroidAutomatorConfig();

      final updated = config.copyWith(
        dontSuppressAccessibilityServices: false,
        retrieveInteractiveWindows: false,
      );

      expect(updated.dontSuppressAccessibilityServices, isFalse);
      expect(updated.retrieveInteractiveWindows, isFalse);
    });
  });

  group('AndroidAutomator.buildConfigureRequest()', () {
    test('forwards the accessibility flags to the native side', () {
      final automator = AndroidAutomator(
        config: const AndroidAutomatorConfig(
          dontSuppressAccessibilityServices: false,
          retrieveInteractiveWindows: false,
        ),
      );

      final request = automator.buildConfigureRequest();

      expect(request.androidDontSuppressAccessibilityServices, isFalse);
      expect(request.androidRetrieveInteractiveWindows, isFalse);
    });

    test('forwards the defaults (true)', () {
      final automator = AndroidAutomator(
        config: const AndroidAutomatorConfig(),
      );

      final request = automator.buildConfigureRequest();

      expect(request.androidDontSuppressAccessibilityServices, isTrue);
      expect(request.androidRetrieveInteractiveWindows, isTrue);
    });
  });
}
