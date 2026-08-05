import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/src/platform/android/android_automator_config.dart';
import 'package:patrol/src/platform/android/android_automator_native.dart';

void main() {
  group('AndroidAutomatorConfig', () {
    test('defaults keep today behavior', () {
      const config = AndroidAutomatorConfig();

      expect(config.dontSuppressAccessibilityServices, isFalse);
      expect(config.retrieveInteractiveWindows, isTrue);
    });

    test('copyWith overrides the accessibility flags', () {
      const config = AndroidAutomatorConfig();

      final updated = config.copyWith(
        dontSuppressAccessibilityServices: true,
        retrieveInteractiveWindows: false,
      );

      expect(updated.dontSuppressAccessibilityServices, isTrue);
      expect(updated.retrieveInteractiveWindows, isFalse);
    });
  });

  group('AndroidAutomator.buildConfigureRequest()', () {
    test('forwards the accessibility flags to the native side', () {
      final automator = AndroidAutomator(
        config: const AndroidAutomatorConfig(
          dontSuppressAccessibilityServices: true,
          retrieveInteractiveWindows: false,
        ),
      );

      // ignore: invalid_use_of_protected_member
      final request = automator.buildConfigureRequest();

      expect(request.androidDontSuppressAccessibilityServices, isTrue);
      expect(request.androidRetrieveInteractiveWindows, isFalse);
    });

    test('defaults forward today behavior', () {
      final automator = AndroidAutomator(
        config: const AndroidAutomatorConfig(),
      );

      // ignore: invalid_use_of_protected_member
      final request = automator.buildConfigureRequest();

      expect(request.androidDontSuppressAccessibilityServices, isFalse);
      expect(request.androidRetrieveInteractiveWindows, isTrue);
    });
  });
}
