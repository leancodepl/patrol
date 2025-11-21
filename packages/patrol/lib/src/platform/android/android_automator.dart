import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/src/platform/android/android_automator_config.dart';
import 'package:patrol/src/platform/contracts/contracts.dart';
import 'package:patrol/src/platform/mobile/mobile_automator.dart';

/// Provides functionality to interact with the OS that the app under test is
/// running on.
///
/// Communicates over http with the native automation server running on the
/// target device.
abstract interface class AndroidAutomator implements MobileAutomator {
  /// Opens a platform-specific app.
  ///
  /// On Android, opens the app specified by [androidAppId] (package name).
  ///
  /// You can pass a [GoogleApp] enum for common Android apps or a custom app ID string.
  ///
  /// Example with enums:
  /// ```dart
  /// await $.platform.openPlatformApp(
  ///   androidAppId: GoogleApp.chrome,
  /// );
  /// ```
  ///
  /// Example with custom app IDs:
  /// ```dart
  /// await $.platform.openPlatformApp(
  ///   androidAppId: 'com.mycompany.myapp',
  /// );
  /// ```
  Future<void> openPlatformApp({required Object androidAppId});

  /// Initializes the native automator.
  ///
  /// It's used to initialize `android.app.UiAutomation` before Flutter tests
  /// start running. It's idempotent.
  ///
  /// See also:
  ///  * https://github.com/flutter/flutter/issues/129231
  Future<void> initialize();

  /// Presses the back button.
  ///
  /// This method throws on iOS, because there's no back button.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#pressback>,
  ///    which is used on Android.
  Future<void> pressBack();

  /// Double presses the recent apps button.
  Future<void> pressDoubleRecentApps();

  /// Taps on the visible notification using [selector].
  ///
  /// If the notification is not visible immediately, this method waits for the
  /// notification to become visible for [timeout] duration. If [timeout] is not
  /// specified, it utilizes the [AndroidAutomatorConfig.findTimeout] duration
  /// from the configuration.
  ///
  /// Notification shade has to be opened first with [openNotifications].
  ///
  /// On iOS, only [IOSSelector.titleContains] is taken into account.
  ///
  /// See also:
  ///
  /// * [tapOnNotificationByIndex], which is less flexible but also less verbose
  Future<void> tapOnNotificationBySelector(
    AndroidSelector selector, {
    Duration? timeout,
  });

  /// Searches for the [index]-th visible notification and taps on it.
  ///
  /// If the notification is not visible immediately, this method waits for the
  /// notification to become visible for [timeout] duration. If [timeout] is not
  /// specified, it utilizes the [AndroidAutomatorConfig.findTimeout] duration
  /// from the configuration.
  ///
  /// Notification shade has to be opened first with [openNotifications].
  ///
  /// See also:
  ///
  ///  * [tapOnNotificationBySelector], which allows for more precise
  ///    specification of the notification to tap on
  Future<void> tapOnNotificationByIndex(int index, {Duration? timeout});

  /// Enables location.
  ///
  /// On Android, opens the location settings screen and toggles the location
  /// switch to enable location.
  /// If the location already enabled, it does nothing.
  Future<void> enableLocation();

  /// Disables location.
  ///
  /// On Android, opens the location settings screen and toggles the location
  /// switch to disable location.
  /// If the location already enabled, it does nothing.
  Future<void> disableLocation();

  /// Taps on the native view specified by [selector].
  ///
  /// It waits for the view to become visible for [timeout] duration. If
  /// [timeout] is not specified, it utilizes the
  /// [AndroidAutomatorConfig.findTimeout] duration from the configuration.
  /// If the native view is not found, an exception is thrown.
  Future<void> tap(AndroidSelector selector, {Duration? timeout});

  /// Double taps on the native view specified by [selector].
  ///
  /// It waits for the view to become visible for [timeout] duration. If
  /// [timeout] is not specified, it utilizes the
  /// [AndroidAutomatorConfig.findTimeout] duration from the configuration.
  /// If the native view is not found, an exception is thrown.
  ///
  /// The [delayBetweenTaps] parameter allows you to specify the duration
  /// between consecutive taps in milliseconds. This can be useful in scenarios
  /// where the target view requires a certain delay between taps to register
  /// the action correctly, such as in cases of UI responsiveness or animations.
  /// The default delay between taps is 300 milliseconds.
  ///
  /// Note: The [delayBetweenTaps] parameter is currently respected only
  /// for Android.
  Future<void> doubleTap(
    AndroidSelector selector, {
    Duration? timeout,
    Duration? delayBetweenTaps,
  });

  /// Taps at a given [location].
  ///
  /// [location] must be in the inclusive 0-1 range.
  Future<void> tapAt(Offset location);

  /// Enters text to the native view specified by [selector].
  ///
  /// If the text field isn't immediately visible, this method waits for the
  /// view to become visible. It prioritizes the [timeout] duration provided
  /// in the method call. If [timeout] is not specified, it utilizes the
  /// [AndroidAutomatorConfig.findTimeout] duration from the configuration.
  ///
  /// The native view specified by [selector] must be:
  ///  * EditText on Android
  ///  * TextField or SecureTextField on iOS
  ///
  /// See also:
  ///  * [enterTextByIndex], which is less flexible but also less verbose
  Future<void> enterText(
    AndroidSelector selector, {
    required String text,
    KeyboardBehavior? keyboardBehavior,
    Duration? timeout,
    Offset? tapLocation,
  });

  /// Enters text to the [index]-th visible text field.
  ///
  /// If the text field at [index] isn't visible immediately, this method waits
  /// for the view to become visible. It prioritizes the [timeout] duration
  /// provided in the method call. If [timeout] is not specified, it utilizes
  /// the [AndroidAutomatorConfig.findTimeout] duration from the configuration.
  ///
  /// Native views considered to be texts fields are:
  ///  * EditText on Android
  ///  * TextField or SecureTextField on iOS
  ///
  /// See also:
  ///  * [enterText], which allows for more precise specification of the text
  ///    field to enter text into
  Future<void> enterTextByIndex(
    String text, {
    required int index,
    KeyboardBehavior? keyboardBehavior,
    Duration? timeout,
    Offset? tapLocation,
  });

  /// Swipes from [from] to [to].
  ///
  /// [from] and [to] must be in the inclusive 0-1 range.
  ///
  /// On Android, [steps] controls speed and smoothness. One unit of [steps] is
  /// equivalent to 5 ms. If you want to slow down the swipe time, increase
  /// [steps]. If [swipe] doesn't work, try increasing [steps].
  Future<void> swipe({
    required Offset from,
    required Offset to,
    int steps = 12,
    bool enablePatrolLog = true,
  });

  /// Mimics the swipe back (left to right) gesture.
  ///
  /// [dy] determines the vertical offset of the swipe. It must be in the inclusive 0-1 range.
  ///
  /// This is equivalent to:
  /// $.native.swipe(
  ///    from: Offset(0, dy),
  ///    to: Offset(1, dy),
  ///  );
  ///
  /// Example usage:
  /// ```dart
  /// await tester.swipeBack(dy: 0.8); // Swipe back at 1/5 height of the screen
  /// await tester.swipeBack(); // Swipe back at the center of the screen
  /// ```
  Future<void> swipeBack({double dy = 0.5});

  /// Simulates pull-to-refresh gesture.
  ///
  /// It swipes from [from] to [to].
  ///
  /// [steps] controls the speed and smoothness of the swipe. More steps equals
  /// slower gesture.
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
    int steps = 50,
  });

  /// Waits until the native view specified by [selector] becomes visible.
  /// It waits for the view to become visible for [timeout] duration. If
  /// [timeout] is not specified, it utilizes the
  /// [AndroidAutomatorConfig.findTimeout].
  Future<void> waitUntilVisible(AndroidSelector selector, {Duration? timeout});

  /// Returns a list of currently visible native UI controls, specified by
  /// [selector], which are currently visible on screen.
  ///
  /// If [selector] is null, returns the whole native UI tree.
  Future<AndroidGetNativeViewsResponse> getNativeViews(
    AndroidSelector? selector,
  );

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
    AndroidSelector? shutterButtonSelector,
    AndroidSelector? doneButtonSelector,
    Duration? timeout,
  });

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
    AndroidSelector? imageSelector,
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
    AndroidSelector? imageSelector,
    Duration? timeout,
  });
}
