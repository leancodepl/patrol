import 'dart:io' as io;

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:patrol/patrol.dart' show PatrolActionException;
import 'package:patrol/src/platform/android/android_automator.dart'
    as android_automator;
import 'package:patrol/src/platform/android/android_automator_config.dart';
import 'package:patrol/src/platform/contracts/android_automator_client.dart';
import 'package:patrol/src/platform/contracts/contracts.dart';
import 'package:patrol/src/platform/mobile/mobile_automator_native.dart';
import 'package:patrol_log/patrol_log.dart';

extension on KeyboardBehavior {
  KeyboardBehavior get toContractsEnum {
    switch (this) {
      case KeyboardBehavior.showAndDismiss:
        return KeyboardBehavior.showAndDismiss;
      case KeyboardBehavior.alternative:
        return KeyboardBehavior.alternative;
    }
  }
}

/// Provides functionality to interact with the OS that the app under test is
/// running on.
///
/// Communicates over http with the native automation server running on the
/// target device.
class AndroidAutomator extends NativeMobileAutomator
    implements android_automator.AndroidAutomator {
  /// Creates a new [AndroidAutomator].
  AndroidAutomator({required AndroidAutomatorConfig config})
    : assert(
        config.connectionTimeout > config.findTimeout,
        'find timeout is longer than connection timeout',
      ),
      _config = config,
      super(config: config) {
    if (_config.packageName.isEmpty && io.Platform.isAndroid) {
      _config.logger("packageName is not set. It's recommended to set it.");
    }

    _client = AndroidAutomatorClient(
      http.Client(),
      Uri.http('${_config.host}:${_config.port}'),
      timeout: _config.connectionTimeout,
    );
    _config.logger(
      'Android NativeAutomatorClient created, port: ${_config.port}',
    );
  }

  final _patrolLog = PatrolLogWriter();
  final AndroidAutomatorConfig _config;

  late final AndroidAutomatorClient _client;

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
  @override
  Future<void> openPlatformApp({required Object androidAppId}) async {
    // Extract the actual app ID string from enum or string
    final androidId = switch (androidAppId) {
      final GoogleApp app => app.value,
      final String id => id,
      _ => throw ArgumentError(
        'androidAppId must be a GoogleApp enum or a String',
      ),
    };

    await wrapRequest(
      'openPlatformApp',
      () => _client.openPlatformApp(
        AndroidOpenPlatformAppRequest(androidAppId: androidId),
      ),
    );
  }

  /// Initializes the native automator.
  ///
  /// It's used to initialize `android.app.UiAutomation` before Flutter tests
  /// start running. It's idempotent.
  ///
  /// See also:
  ///  * https://github.com/flutter/flutter/issues/129231
  @override
  Future<void> initialize() async {
    await wrapRequest('initialize', _client.initialize, enablePatrolLog: false);
  }

  /// Returns the platform-dependent unique identifier of the app under test.
  @override
  String get resolvedAppId {
    return _config.packageName;
  }

  @override
  Future<T> wrapRequest<T>(
    String name,
    Future<T> Function() request, {
    bool enablePatrolLog = true,
  }) async {
    try {
      return await super.wrapRequest(
        name,
        request,
        enablePatrolLog: enablePatrolLog,
      );
    } on AndroidAutomatorClientException catch (err) {
      final text =
          '${AnsiCodes.lightBlue}$name${AnsiCodes.reset} ${AnsiCodes.gray}(native)${AnsiCodes.reset}';

      _config.logger('$name() failed');
      final log =
          'IosAutomatorClientException: '
          '$name() failed with $err';

      if (enablePatrolLog) {
        _patrolLog.log(
          StepEntry(action: text, status: StepEntryStatus.failure),
        );
      }
      throw PatrolActionException(log);
    }
  }

  /// Presses the back button.
  ///
  /// See also:
  ///  * <https://developer.android.com/reference/androidx/test/uiautomator/UiDevice#pressback>,
  ///    which is used on Android.
  @override
  Future<void> pressBack() async {
    await wrapRequest('pressBack', _client.pressBack);
  }

  /// Double presses the recent apps button.
  @override
  Future<void> pressDoubleRecentApps() async {
    await wrapRequest('pressDoubleRecentApps', _client.doublePressRecentApps);
  }

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
  @override
  Future<void> tapOnNotificationByIndex(int index, {Duration? timeout}) async {
    await wrapRequest(
      'tapOnNotificationByIndex',
      () => _client.tapOnNotification(
        AndroidTapOnNotificationRequest(
          index: index,
          timeoutMillis: timeout?.inMilliseconds,
        ),
      ),
    );
  }

  /// Taps on the visible notification using [selector].
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
  /// * [tapOnNotificationByIndex], which is less flexible but also less verbose
  @override
  Future<void> tapOnNotificationBySelector(
    AndroidSelector selector, {
    Duration? timeout,
  }) async {
    await wrapRequest(
      'tapOnNotificationBySelector',
      () => _client.tapOnNotification(
        AndroidTapOnNotificationRequest(
          selector: selector,
          timeoutMillis: timeout?.inMilliseconds,
        ),
      ),
    );
  }

  /// Enables location.
  ///
  /// On Android, opens the location settings screen and toggles the location
  /// switch to enable location.
  /// If the location already enabled, it does nothing.
  @override
  Future<void> enableLocation() async {
    await wrapRequest('enableLocation', _client.enableLocation);
  }

  /// Disables location.
  ///
  /// On Android, opens the location settings screen and toggles the location
  /// switch to disable location.
  /// If the location already enabled, it does nothing.
  @override
  Future<void> disableLocation() async {
    await wrapRequest('disableLocation', _client.disableLocation);
  }

  /// Taps on the native view specified by [selector].
  ///
  /// It waits for the view to become visible for [timeout] duration. If
  /// [timeout] is not specified, it utilizes the
  /// [AndroidAutomatorConfig.findTimeout] duration from the configuration.
  /// If the native view is not found, an exception is thrown.
  @override
  Future<void> tap(AndroidSelector selector, {Duration? timeout}) async {
    await wrapRequest('tap', () async {
      await _client.tap(
        AndroidTapRequest(
          selector: selector,
          timeoutMillis: timeout?.inMilliseconds,
        ),
      );
    });
  }

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
  @override
  Future<void> doubleTap(
    AndroidSelector selector, {
    Duration? timeout,
    Duration? delayBetweenTaps,
  }) async {
    await wrapRequest(
      'doubleTap',
      () => _client.doubleTap(
        AndroidTapRequest(
          selector: selector,
          timeoutMillis: timeout?.inMilliseconds,
          delayBetweenTapsMillis: delayBetweenTaps?.inMilliseconds,
        ),
      ),
    );
  }

  /// Taps at a given [location].
  ///
  /// [location] must be in the inclusive 0-1 range.
  @override
  Future<void> tapAt(Offset location) async {
    assert(location.dx >= 0 && location.dx <= 1);
    assert(location.dy >= 0 && location.dy <= 1);

    // Needed for an edge case observed on Android where if a newly opened app
    // updates its layout right after being launched, tapping without delay fails
    await Future<void>.delayed(const Duration(milliseconds: 5));

    await wrapRequest('tapAt', () async {
      await _client.tapAt(AndroidTapAtRequest(x: location.dx, y: location.dy));
    });
  }

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
  @override
  Future<void> enterText(
    AndroidSelector selector, {
    required String text,
    KeyboardBehavior? keyboardBehavior,
    Duration? timeout,
    Offset? tapLocation,
  }) async {
    await wrapRequest(
      'enterText',
      () => _client.enterText(
        AndroidEnterTextRequest(
          data: text,
          selector: selector,
          keyboardBehavior:
              (keyboardBehavior ?? _config.keyboardBehavior).toContractsEnum,
          timeoutMillis: timeout?.inMilliseconds,
          dx: tapLocation?.dx ?? 0.9,
          dy: tapLocation?.dy ?? 0.9,
        ),
      ),
    );
  }

  /// Enters text to the [index]-th visible text field.
  ///
  /// If the text field at [index] isn't visible immediately, this method waits
  /// for the view to become visible. It prioritizes the [timeout] duration
  /// provided in the method call. If [timeout] is not specified, it utilizes
  /// the [AndroidAutomatorConfig.findTimeout] duration from the configuration.
  ///
  /// Native views considered to be texts fields are:
  ///  * EditText on Android
  ///
  /// See also:
  ///  * [enterText], which allows for more precise specification of the text
  ///    field to enter text into
  @override
  Future<void> enterTextByIndex(
    String text, {
    required int index,
    KeyboardBehavior? keyboardBehavior,
    Duration? timeout,
    Offset? tapLocation,
  }) async {
    await wrapRequest(
      'enterTextByIndex',
      () => _client.enterText(
        AndroidEnterTextRequest(
          data: text,
          index: index,
          keyboardBehavior:
              (keyboardBehavior ?? _config.keyboardBehavior).toContractsEnum,
          timeoutMillis: timeout?.inMilliseconds,
          dx: tapLocation?.dx ?? 0.9,
          dy: tapLocation?.dy ?? 0.9,
        ),
      ),
    );
  }

  /// Swipes from [from] to [to].
  ///
  /// [from] and [to] must be in the inclusive 0-1 range.
  ///
  /// On Android, [steps] controls speed and smoothness. One unit of [steps] is
  /// equivalent to 5 ms. If you want to slow down the swipe time, increase
  /// [steps]. If [swipe] doesn't work, try increasing [steps].
  @override
  Future<void> swipe({
    required Offset from,
    required Offset to,
    int steps = 12,
    bool enablePatrolLog = true,
  }) async {
    assert(from.dx >= 0 && from.dx <= 1);
    assert(from.dy >= 0 && from.dy <= 1);
    assert(to.dx >= 0 && to.dx <= 1);
    assert(to.dy >= 0 && to.dy <= 1);

    await wrapRequest(
      'swipe',
      enablePatrolLog: enablePatrolLog,
      () => _client.swipe(
        AndroidSwipeRequest(
          startX: from.dx,
          startY: from.dy,
          endX: to.dx,
          endY: to.dy,
          steps: steps,
        ),
      ),
    );
  }

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
  /// On Android, navigation with gestures might have to be turned on in devices settings.
  ///
  /// Example usage:
  /// ```dart
  /// await tester.swipeBack(dy: 0.8); // Swipe back at 1/5 height of the screen
  /// await tester.swipeBack(); // Swipe back at the center of the screen
  /// ```
  @override
  Future<void> swipeBack({double dy = 0.5}) async {
    assert(dy >= 0.0 && dy <= 1.0, 'dy must be between 0.0 and 1.0');
    await wrapRequest(
      'swipeBack',
      () =>
          swipe(from: Offset(0, dy), to: Offset(1, dy), enablePatrolLog: false),
    );
  }

  /// Simulates pull-to-refresh gesture.
  ///
  /// It swipes from [from] to [to] with the specified number of [steps].
  ///
  /// [from] and [to] must be in the inclusive 0-1 range.
  ///
  /// [steps] controls the speed and smoothness of the swipe. More steps equals
  /// slower gesture.
  ///
  /// The default values simulate a typical pull-to-refresh gesture:
  /// * [from]: Center of the screen (0.5, 0.5)
  /// * [to]: Bottom center of the screen (0.5, 0.9)
  /// * [steps]: 50
  /// You can override these if scrollable content is not at the center of the
  /// screen or if the direction of the gesture is different.
  @override
  Future<void> pullToRefresh({
    Offset from = const Offset(0.5, 0.5),
    Offset to = const Offset(0.5, 0.9),
    int steps = 50,
  }) async {
    assert(from.dx >= 0 && from.dx <= 1);
    assert(from.dy >= 0 && from.dy <= 1);
    assert(to.dx >= 0 && to.dx <= 1);
    assert(to.dy >= 0 && to.dy <= 1);

    await wrapRequest(
      'pullToRefresh',
      () => swipe(
        from: Offset(from.dx, from.dy),
        to: Offset(to.dx, to.dy),
        steps: steps,
        enablePatrolLog: false,
      ),
    );
  }

  /// Waits until the native view specified by [selector] becomes visible.
  /// It waits for the view to become visible for [timeout] duration. If
  /// [timeout] is not specified, it utilizes the
  /// [AndroidAutomatorConfig.findTimeout].
  @override
  Future<void> waitUntilVisible(
    AndroidSelector selector, {
    Duration? timeout,
  }) async {
    await wrapRequest(
      'waitUntilVisible',
      () => _client.waitUntilVisible(
        AndroidWaitUntilVisibleRequest(
          selector: selector,
          timeoutMillis: timeout?.inMilliseconds,
        ),
      ),
    );
  }

  /// Returns a list of currently visible native UI controls, specified by
  /// [selector], which are currently visible on screen.
  ///
  /// If [selector] is null, returns the whole native UI tree.
  Future<AndroidGetNativeViewsResponse> getNativeViews(
    AndroidSelector? selector,
  ) async {
    return await wrapRequest(
      'getNativeViews',
      () => _client.getNativeViews(
        AndroidGetNativeViewsRequest(selector: selector),
      ),
    );
  }

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
  @override
  Future<void> takeCameraPhoto({
    AndroidSelector? shutterButtonSelector,
    AndroidSelector? doneButtonSelector,
    Duration? timeout,
  }) async {
    await wrapRequest('takeCameraPhoto', () async {
      await _client.takeCameraPhoto(
        AndroidTakeCameraPhotoRequest(
          shutterButtonSelector: shutterButtonSelector,
          doneButtonSelector: doneButtonSelector,
          timeoutMillis: timeout?.inMilliseconds,
        ),
      );
    });
  }

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
  @override
  Future<void> pickImageFromGallery({
    AndroidSelector? imageSelector,
    int? index,
    Duration? timeout,
  }) async {
    await wrapRequest('pickImageFromGallery', () async {
      await _client.pickImageFromGallery(
        AndroidPickImageFromGalleryRequest(
          imageSelector: imageSelector,
          timeoutMillis: timeout?.inMilliseconds,
          imageIndex: index,
        ),
      );
    });
  }

  /// Pick multiple images from the gallery
  ///
  /// This method opens the gallery and selects multiple images based on [imageIndexes].
  ///
  /// You can provide a custom selector for the images using [imageSelector].
  /// If no custom selector is provided, default selectors will be used.
  /// The method will automatically handle the selection confirmation process.
  @override
  Future<void> pickMultipleImagesFromGallery({
    required List<int> imageIndexes,
    AndroidSelector? imageSelector,
    Duration? timeout,
  }) async {
    await wrapRequest('pickMultipleImagesFromGallery', () async {
      await _client.pickMultipleImagesFromGallery(
        AndroidPickMultipleImagesFromGalleryRequest(
          imageSelector: imageSelector,
          imageIndexes: imageIndexes,
          timeoutMillis: timeout?.inMilliseconds,
        ),
      );
    });
  }
}
