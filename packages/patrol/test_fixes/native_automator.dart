import 'package:patrol/patrol.dart';

void main() {
  patrolTest(
    'native API',
    nativeAutomatorConfig: NativeAutomatorConfig(
      keyboardBehavior: KeyboardBehavior.alternative,
      findTimeout: const Duration(seconds: 5),
    ),
    ($) async {
      await $.native.pressHome();
      await $.native.tap(Selector(text: 'Allow'));
      await $.native2.tap(
        NativeSelector(
          android: AndroidSelector(text: 'Allow'),
          ios: IOSSelector(label: 'Allow'),
        ),
      );
      await $.nativeAutomator.enableWifi();
      await $.nativeAutomator2.disableWifi();

      final NativeAutomator automator = $.native;
      final NativeAutomator2 automator2 = $.native2;
    },
  );

  final automator = NativeAutomator(
    platformAutomator: PlatformAutomator(
      config: PlatformAutomatorConfig.defaultConfig(),
    ),
  );
  final automator2 = NativeAutomator2(
    platformAutomator: PlatformAutomator(
      config: PlatformAutomatorConfig.defaultConfig(),
    ),
  );
}
