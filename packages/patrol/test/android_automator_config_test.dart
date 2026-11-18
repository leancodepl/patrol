import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/src/platform/android/android_automator_config.dart';
import 'package:patrol/src/platform/android/android_automator_native.dart';

void main() {
  group('AndroidAutomatorConfig', () {
    test('dontSuppressAccessibilityServices defaults to true', () {
      const config = AndroidAutomatorConfig();

      expect(config.dontSuppressAccessibilityServices, isTrue);
    });

    test('copyWith overrides dontSuppressAccessibilityServices', () {
      const config = AndroidAutomatorConfig();

      expect(
        config
            .copyWith(dontSuppressAccessibilityServices: false)
            .dontSuppressAccessibilityServices,
        isFalse,
      );
    });
  });

  group('AndroidAutomator.buildConfigureRequest()', () {
    test('forwards the accessibility flag to the native side', () {
      final automator = AndroidAutomator(
        config: const AndroidAutomatorConfig(
          dontSuppressAccessibilityServices: false,
        ),
      );

      final request = automator.buildConfigureRequest();

      expect(request.androidDontSuppressAccessibilityServices, isFalse);
    });

    test('forwards the default (true)', () {
      final automator = AndroidAutomator(
        config: const AndroidAutomatorConfig(),
      );

      final request = automator.buildConfigureRequest();

      expect(request.androidDontSuppressAccessibilityServices, isTrue);
    });
  });
}
