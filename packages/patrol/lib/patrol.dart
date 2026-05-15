/// Powerful Flutter-native UI testing framework overcoming limitations of
/// existing Flutter testing tools. Ready for action!
library;

export 'package:patrol_finders/patrol_finders.dart' hide PatrolTester;

export 'src/binding.dart';
// Exporting patrol methods to be used in tests.
// ignore: invalid_export_of_internal_element
export 'src/common.dart';
export 'src/custom_finders/patrol_integration_tester.dart';
export 'src/native/native.dart';
export 'src/platform/android/android_automator.dart';
export 'src/platform/android/android_automator_config.dart';
export 'src/platform/contracts/contracts.dart'
    show
        AndroidGetNativeViewsResponse,
        AndroidNativeView,
        AppleApp,
        GoogleApp,
        IOSElementType,
        IOSGetNativeViewsResponse,
        IOSNativeView,
        KeyboardBehavior,
        Notification,
        Point2D,
        Rectangle;
export 'src/platform/ios/ios_automator.dart';
export 'src/platform/ios/ios_automator_config.dart';
export 'src/platform/mobile/mobile_automator_config.dart';
export 'src/platform/patrol_app_service.dart';
export 'src/platform/platform_automator.dart';
export 'src/platform/selector.dart';
export 'src/platform/web/upload_file_data.dart';
export 'src/platform/web/web_automator.dart';
export 'src/platform/web/web_automator_config.dart';
