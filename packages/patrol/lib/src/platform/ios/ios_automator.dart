import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/src/platform/ios/contracts/contracts.dart';
import 'package:patrol/src/platform/mobile/mobile_automator.dart';

/// Provides functionality to interact with the OS that the app under test is
/// running on.
///
/// Communicates over http with the native automation server running on the
/// target device.
abstract class IOSAutomator extends MobileAutomator {
  /// Closes the currently visible heads up notification (iOS only).
  ///
  /// If no heads up notification is visible, the behavior is undefined.
  Future<void> closeHeadsUpNotification();

  /// Taps on the visible notification using [selector].
  ///
  /// If the notification is not visible immediately, this method waits for the
  /// notification to become visible for [timeout] duration. If [timeout] is not
  /// specified, it utilizes the [NativeAutomatorConfig.findTimeout] duration
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
    Selector selector, {
    Duration? timeout,
  });

  /// Taps on the native view specified by [selector].
  ///
  /// It waits for the view to become visible for [timeout] duration. If
  /// [timeout] is not specified, it utilizes the
  /// [NativeAutomatorConfig.findTimeout] duration from the configuration.
  /// If the native view is not found, an exception is thrown.
  Future<void> tap(Selector selector, {String? appId, Duration? timeout});

  /// Double taps on the native view specified by [selector].
  ///
  /// It waits for the view to become visible for [timeout] duration. If
  /// [timeout] is not specified, it utilizes the
  /// [NativeAutomatorConfig.findTimeout] duration from the configuration.
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
    Selector selector, {
    String? appId,
    Duration? timeout,
    Duration? delayBetweenTaps,
  });

  /// Enters text to the native view specified by [selector].
  ///
  /// If the text field isn't immediately visible, this method waits for the
  /// view to become visible. It prioritizes the [timeout] duration provided
  /// in the method call. If [timeout] is not specified, it utilizes the
  /// [NativeAutomatorConfig.findTimeout] duration from the configuration.
  ///
  /// The native view specified by [selector] must be:
  ///  * EditText or AutoCompleteTextView on Android
  ///  * TextField or SecureTextField on iOS
  ///
  /// See also:
  ///  * [enterTextByIndex], which is less flexible but also less verbose
  Future<void> enterText(
    Selector selector, {
    required String text,
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

  /// Waits until the native view specified by [selector] becomes visible.
  /// It waits for the view to become visible for [timeout] duration. If
  /// [timeout] is not specified, it utilizes the
  /// [NativeAutomatorConfig.findTimeout].
  Future<void> waitUntilVisible(
    Selector selector, {
    String? appId,
    Duration? timeout,
  });

  /// Returns a list of currently visible native UI controls, specified by
  /// [selector], which are currently visible on screen.
  ///
  /// If [selector] is null, returns the whole native UI tree.
  Future<List<NativeView>> getNativeViews(Selector selector, {String? appId});

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
    Selector? shutterButtonSelector,
    Selector? doneButtonSelector,
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
    Selector? imageSelector,
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
    Selector? imageSelector,
    Duration? timeout,
  });
}
