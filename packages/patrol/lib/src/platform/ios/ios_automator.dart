import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/src/platform/contracts/contracts.dart';
import 'package:patrol/src/platform/ios/ios_automator_config.dart';
import 'package:patrol/src/platform/mobile/mobile_automator.dart';

/// Provides functionality to interact with the OS that the app under test is
/// running on.
///
/// Communicates over http with the native automation server running on the
/// target device.
abstract interface class IOSAutomator implements MobileAutomator {
  /// Opens a platform-specific app.
  ///
  /// On iOS, opens the app specified by [iosAppId] (bundle identifier).
  ///
  /// You can pass an [AppleApp] enum for common iOS apps, or a custom app ID string.
  ///
  /// Example with enums:
  /// ```dart
  /// await $.platform.openPlatformApp(
  ///   iosAppId: AppleApp.safari,
  /// );
  /// ```
  ///
  /// Example with custom app IDs:
  /// ```dart
  /// await $.platform.openPlatformApp(
  ///   iosAppId: 'com.mycompany.myapp',
  /// );
  /// ```
  Future<void> openPlatformApp({required Object iosAppId});

  /// Closes the currently visible heads up notification.
  ///
  /// If no heads up notification is visible, the behavior is undefined.
  Future<void> closeHeadsUpNotification();

  /// Taps on the visible notification using [selector].
  ///
  /// If the notification is not visible immediately, this method waits for the
  /// notification to become visible for [timeout] duration. If [timeout] is not
  /// specified, it utilizes the [IOSAutomatorConfig.findTimeout] duration
  /// from the configuration.
  ///
  /// Notification shade has to be opened first with [openNotifications].
  ///
  /// On iOS, [IOSSelector.textContains], [IOSSelector.titleContains], and
  /// [IOSSelector.text] are taken into account.
  ///
  /// See also:
  ///
  /// * [tapOnNotificationByIndex], which is less flexible but also less verbose
  Future<void> tapOnNotificationBySelector(
    IOSSelector selector, {
    Duration? timeout,
  });

  /// Searches for the [index]-th visible notification and taps on it.
  ///
  /// If the notification is not visible immediately, this method waits for the
  /// notification to become visible for [timeout] duration. If [timeout] is not
  /// specified, it utilizes the [IOSAutomatorConfig.findTimeout] duration
  /// from the configuration.
  ///
  /// Notification shade has to be opened first with [openNotifications].
  ///
  /// See also:
  ///
  ///  * [tapOnNotificationBySelector], which allows for more precise
  ///    specification of the notification to tap on
  Future<void> tapOnNotificationByIndex(int index, {Duration? timeout});

  /// Taps on the native view specified by [selector].
  ///
  /// It waits for the view to become visible for [timeout] duration. If
  /// [timeout] is not specified, it utilizes the
  /// [IOSAutomatorConfig.findTimeout] duration from the configuration.
  /// If the native view is not found, an exception is thrown.
  Future<void> tap(IOSSelector selector, {String? appId, Duration? timeout});

  /// Double taps on the native view specified by [selector].
  ///
  /// It waits for the view to become visible for [timeout] duration. If
  /// [timeout] is not specified, it utilizes the
  /// [IOSAutomatorConfig.findTimeout] duration from the configuration.
  /// If the native view is not found, an exception is thrown.
  Future<void> doubleTap(
    IOSSelector selector, {
    String? appId,
    Duration? timeout,
  });

  /// Taps at a given [location].
  ///
  /// [location] must be in the inclusive 0-1 range.
  Future<void> tapAt(Offset location, {String? appId});

  /// Enters text to the native view specified by [selector].
  ///
  /// If the text field isn't immediately visible, this method waits for the
  /// view to become visible. It prioritizes the [timeout] duration provided
  /// in the method call. If [timeout] is not specified, it utilizes the
  /// [IOSAutomatorConfig.findTimeout] duration from the configuration.
  ///
  /// The native view specified by [selector] must be:
  ///  * TextField or SecureTextField on iOS
  ///
  /// See also:
  ///  * [enterTextByIndex], which is less flexible but also less verbose
  Future<void> enterText(
    IOSSelector selector, {
    required String text,
    String? appId,
    KeyboardBehavior? keyboardBehavior,
    Duration? timeout,
    Offset? tapLocation,
  });

  /// Enters text to the [index]-th visible text field.
  ///
  /// If the text field at [index] isn't visible immediately, this method waits
  /// for the view to become visible. It prioritizes the [timeout] duration
  /// provided in the method call. If [timeout] is not specified, it utilizes
  /// the [IOSAutomatorConfig.findTimeout] duration from the configuration.
  ///
  /// Native views considered to be texts fields are:
  ///  * TextField or SecureTextField on iOS
  ///
  /// See also:
  ///  * [enterText], which allows for more precise specification of the text
  ///    field to enter text into
  Future<void> enterTextByIndex(
    String text, {
    required int index,
    String? appId,
    KeyboardBehavior? keyboardBehavior,
    Duration? timeout,
    Offset? tapLocation,
  });

  /// Swipes from [from] to [to].
  ///
  /// [from] and [to] must be in the inclusive 0-1 range.
  Future<void> swipe({
    required Offset from,
    required Offset to,
    String? appId,
    bool enablePatrolLog = true,
  });

  /// Mimics the swipe back (left to right) gesture.
  ///
  /// [dy] determines the vertical offset of the swipe. It must be in the inclusive 0-1 range.
  ///
  /// [appId] optionally specifies the application ID to target.
  ///
  /// This is equivalent to:
  /// $.native.swipe(
  ///    from: Offset(0, dy),
  ///    to: Offset(1, dy),
  ///    appId: appId,
  ///  );
  ///
  /// Example usage:
  /// ```dart
  /// await tester.swipeBack(dy: 0.8); // Swipe back at 1/5 height of the screen
  /// await tester.swipeBack(); // Swipe back at the center of the screen
  /// ```
  Future<void> swipeBack({double dy = 0.5, String? appId});

  /// Simulates pull-to-refresh gesture.
  ///
  /// It swipes from [from] to [to].
  ///
  /// [from] and [to] must be in the inclusive 0-1 range.
  ///
  /// The default values simulate a typical pull-to-refresh gesture:
  /// * [from]: Center of the screen (0.5, 0.5)
  /// * [to]: Bottom center of the screen (0.5, 0.9)
  /// You can override these if scrollable content is not at the center of the
  /// screen or if the direction of the gesture is different.
  Future<void> pullToRefresh({
    Offset from = const Offset(0.5, 0.5),
    Offset to = const Offset(0.5, 0.9),
  });

  /// Waits until the native view specified by [selector] becomes visible.
  /// It waits for the view to become visible for [timeout] duration. If
  /// [timeout] is not specified, it utilizes the
  /// [IOSAutomatorConfig.findTimeout].
  Future<void> waitUntilVisible(
    IOSSelector selector, {
    String? appId,
    Duration? timeout,
  });

  /// Returns a list of currently visible native UI controls, specified by
  /// [selector], which are currently visible on screen.
  ///
  /// If [selector] is null, returns the whole native UI tree.
  Future<IOSGetNativeViewsResponse> getNativeViews(
    IOSSelector? selector, {
    List<String>? iosInstalledApps,
    String? appId,
  });

  /// Take and confirm the photo
  ///
  /// This method taps on the camera shutter button to take a photo, then taps
  /// on the confirmation button to accept it.
  ///
  /// You can provide custom selectors for both the shutter and confirmation buttons
  /// using [shutterButtonSelector] and [doneButtonSelector] parameters.
  /// If no custom selectors are provided, default selectors will be used.
  ///
  /// For different camera apps or device manufacturers, you may need to provide
  /// custom selectors with the appropriate resource identifiers for your specific app.
  Future<void> takeCameraPhoto({
    IOSSelector? shutterButtonSelector,
    IOSSelector? doneButtonSelector,
    Duration? timeout,
  });

  /// BROWSERSTACK ONLY
  ///
  /// Inject an image for BrowserStack Image Injection.
  ///
  /// This method stages the specified [imageName] so that the next time the
  /// app opens the camera, it will receive the injected image instead of real
  /// camera input. After calling this, use [takeCameraPhoto] to trigger the
  /// actual camera capture or call [feedInjectedImageToViewfinder] if a continuous
  /// scanning implementation is used (such as in QR code scanners).
  ///
  /// [imageName] must match the filename of an image uploaded to BrowserStack
  /// and included in the `cameraInjectionMedia` build capability.
  ///
  /// This only works when running on BrowserStack with:
  /// - `enableCameraImageInjection: "true"`
  /// - `resignApp: "true"`
  /// - `BrowserStackTestHelper` framework linked in the RunnerUITests target
  ///
  /// See [BrowserStack documentation](https://www.browserstack.com/docs/app-automate/xcuitest/image-injection)
  Future<void> injectCameraPhoto({required String imageName});

  /// BROWSERSTACK ONLY
  ///
  /// Feed the BrowserStack-injected image to the camera viewfinder.
  ///
  /// This captures the BrowserStack-injected image using a supported
  /// AVCapturePhoto API and feeds it to the AVCaptureVideoDataOutput
  /// This makes continuous QR/barcode scanning implementations
  /// (such as mobile_scanner) detect the injected image.
  ///
  /// Call [injectCameraPhoto] first to stage the image, then open the camera
  /// (e.g. navigate to a QR scanner screen), and finally call this method
  /// to feed the injected image to the viewfinder.
  Future<void> feedInjectedImageToViewfinder();

  /// Pick an image from the gallery
  ///
  /// This method opens the gallery and selects a single image.
  ///
  /// You can provide a custom selector for the image using [imageSelector].
  /// If no custom selector is provided, default selectors will be used.
  /// Alternatively, you can specify an [index] to select the nth image
  /// when using default selectors.
  ///
  /// Note: If you provide [imageSelector], the [index] parameter will be overwritten.
  Future<void> pickImageFromGallery({
    IOSSelector? imageSelector,
    int? index,
    Duration? timeout,
  });

  /// Pick multiple images from the gallery
  ///
  /// This method opens the gallery and selects multiple images based on [imageIndexes].
  ///
  /// You can provide a custom selector for the images using [imageSelector].
  /// If no custom selector is provided, default selectors will be used.
  /// The method will automatically handle the selection confirmation process.
  Future<void> pickMultipleImagesFromGallery({
    required List<int> imageIndexes,
    IOSSelector? imageSelector,
    Duration? timeout,
  });
}
