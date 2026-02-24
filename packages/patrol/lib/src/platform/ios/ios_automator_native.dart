import 'dart:io' as io;

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:patrol/src/native/native_automator.dart';
import 'package:patrol/src/platform/contracts/contracts.dart';
import 'package:patrol/src/platform/contracts/ios_automator_client.dart';
import 'package:patrol/src/platform/ios/ios_automator.dart' as ios_automator;
import 'package:patrol/src/platform/ios/ios_automator_config.dart';
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
class IOSAutomator extends NativeMobileAutomator
    implements ios_automator.IOSAutomator {
  /// Creates a new [IOSAutomator].
  IOSAutomator({required IOSAutomatorConfig config})
    : assert(
        config.connectionTimeout > config.findTimeout,
        'find timeout is longer than connection timeout',
      ),
      _config = config,
      super(config: config) {
    if (_config.bundleId.isEmpty && io.Platform.isIOS) {
      _config.logger("bundleId is not set. It's recommended to set it.");
    }

    _client = IosAutomatorClient(
      http.Client(),
      Uri.http('${_config.host}:${_config.port}'),
      timeout: _config.connectionTimeout,
    );
    _config.logger('NativeAutomatorClient created, port: ${_config.port}');
  }

  final _patrolLog = PatrolLogWriter();
  final IOSAutomatorConfig _config;

  late final IosAutomatorClient _client;

  /// Returns the platform-dependent unique identifier of the app under test.
  @override
  String get resolvedAppId {
    return _config.bundleId;
  }

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
  @override
  Future<void> openPlatformApp({required Object iosAppId}) async {
    // Extract the actual app ID string from enum or string
    final iosId = switch (iosAppId) {
      final AppleApp app => app.value,
      final String id => id,
      _ => throw ArgumentError('iosAppId must be an AppleApp enum or a String'),
    };

    await wrapRequest(
      'openPlatformApp',
      () => _client.openPlatformApp(IOSOpenPlatformAppRequest(iosAppId: iosId)),
    );
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
    } on IosAutomatorClientException catch (err) {
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

  /// Closes the currently visible heads up notification (iOS only).
  ///
  /// If no heads up notification is visible, the behavior is undefined.
  @override
  Future<void> closeHeadsUpNotification() async {
    await wrapRequest(
      'closeHeadsUpNotification',
      _client.closeHeadsUpNotification,
    );
  }

  /// Searches for the [index]-th visible notification and taps on it.
  ///
  /// If the notification is not visible immediately, this method waits for the
  /// notification to become visible for [timeout] duration. If [timeout] is not
  /// specified, it utilizes the `findTimeout` duration
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
        IOSTapOnNotificationRequest(
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
  /// specified, it utilizes the `findTimeout` duration
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
  @override
  Future<void> tapOnNotificationBySelector(
    IOSSelector selector, {
    Duration? timeout,
  }) async {
    await wrapRequest(
      'tapOnNotificationBySelector',
      () => _client.tapOnNotification(
        IOSTapOnNotificationRequest(
          selector: selector,
          timeoutMillis: timeout?.inMilliseconds,
        ),
      ),
    );
  }

  /// Taps on the native view specified by [selector].
  ///
  /// It waits for the view to become visible for [timeout] duration. If
  /// [timeout] is not specified, it utilizes the
  /// `findTimeout` duration from the configuration.
  /// If the native view is not found, an exception is thrown.
  @override
  Future<void> tap(
    IOSSelector selector, {
    String? appId,
    Duration? timeout,
  }) async {
    await wrapRequest('tap', () async {
      await _client.tap(
        IOSTapRequest(
          selector: selector,
          appId: appId ?? resolvedAppId,
          timeoutMillis: timeout?.inMilliseconds,
        ),
      );
    });
  }

  /// Double taps on the native view specified by [selector].
  ///
  /// It waits for the view to become visible for [timeout] duration. If
  /// [timeout] is not specified, it utilizes the
  /// `findTimeout` duration from the configuration.
  /// If the native view is not found, an exception is thrown.
  @override
  Future<void> doubleTap(
    IOSSelector selector, {
    String? appId,
    Duration? timeout,
  }) async {
    await wrapRequest(
      'doubleTap',
      () => _client.doubleTap(
        IOSTapRequest(
          selector: selector,
          appId: appId ?? resolvedAppId,
          timeoutMillis: timeout?.inMilliseconds,
        ),
      ),
    );
  }

  /// Taps at a given [location].
  ///
  /// [location] must be in the inclusive 0-1 range.
  @override
  Future<void> tapAt(Offset location, {String? appId}) async {
    assert(location.dx >= 0 && location.dx <= 1);
    assert(location.dy >= 0 && location.dy <= 1);

    // Needed for an edge case observed on Android where if a newly opened app
    // updates its layout right after being launched, tapping without delay fails
    await Future<void>.delayed(const Duration(milliseconds: 5));

    await wrapRequest('tapAt', () async {
      await _client.tapAt(
        IOSTapAtRequest(
          x: location.dx,
          y: location.dy,
          appId: appId ?? resolvedAppId,
        ),
      );
    });
  }

  /// Enters text to the native view specified by [selector].
  ///
  /// If the text field isn't immediately visible, this method waits for the
  /// view to become visible. It prioritizes the [timeout] duration provided
  /// in the method call. If [timeout] is not specified, it utilizes the
  /// `findTimeout` duration from the configuration.
  ///
  /// The native view specified by [selector] must be:
  ///  * EditText or AutoCompleteTextView on Android
  ///  * TextField or SecureTextField on iOS
  ///
  /// See also:
  ///  * [enterTextByIndex], which is less flexible but also less verbose
  @override
  Future<void> enterText(
    IOSSelector selector, {
    required String text,
    String? appId,
    KeyboardBehavior? keyboardBehavior,
    Duration? timeout,
    Offset? tapLocation,
  }) async {
    await wrapRequest(
      'enterText',
      () => _client.enterText(
        IOSEnterTextRequest(
          data: text,
          appId: appId ?? resolvedAppId,
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
  /// the `findTimeout` duration from the configuration.
  ///
  /// Native views considered to be texts fields are:
  ///  * EditText on Android
  ///  * TextField or SecureTextField on iOS
  ///
  /// See also:
  ///  * [enterText], which allows for more precise specification of the text
  ///    field to enter text into
  @override
  Future<void> enterTextByIndex(
    String text, {
    required int index,
    String? appId,
    KeyboardBehavior? keyboardBehavior,
    Duration? timeout,
    Offset? tapLocation,
  }) async {
    await wrapRequest(
      'enterTextByIndex',
      () => _client.enterText(
        IOSEnterTextRequest(
          data: text,
          appId: appId ?? resolvedAppId,
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
  @override
  Future<void> swipe({
    required Offset from,
    required Offset to,
    String? appId,
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
        IOSSwipeRequest(
          startX: from.dx,
          startY: from.dy,
          endX: to.dx,
          endY: to.dy,
          appId: appId ?? resolvedAppId,
        ),
      ),
    );
  }

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
  /// On Android, navigation with gestures might have to be turned on in devices settings.
  ///
  /// Example usage:
  /// ```dart
  /// await tester.swipeBack(dy: 0.8); // Swipe back at 1/5 height of the screen
  /// await tester.swipeBack(); // Swipe back at the center of the screen
  /// ```
  @override
  Future<void> swipeBack({double dy = 0.5, String? appId}) async {
    assert(dy >= 0.0 && dy <= 1.0, 'dy must be between 0.0 and 1.0');
    await wrapRequest(
      'swipeBack',
      () => swipe(
        from: Offset(0, dy),
        to: Offset(1, dy),
        appId: appId,
        enablePatrolLog: false,
      ),
    );
  }

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
  @override
  Future<void> pullToRefresh({
    Offset from = const Offset(0.5, 0.5),
    Offset to = const Offset(0.5, 0.9),
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
        enablePatrolLog: false,
      ),
    );
  }

  /// Waits until the native view specified by [selector] becomes visible.
  /// It waits for the view to become visible for [timeout] duration. If
  /// [timeout] is not specified, it utilizes the
  /// `findTimeout`.
  @override
  Future<void> waitUntilVisible(
    IOSSelector selector, {
    String? appId,
    Duration? timeout,
  }) async {
    await wrapRequest(
      'waitUntilVisible',
      () => _client.waitUntilVisible(
        IOSWaitUntilVisibleRequest(
          selector: selector,
          appId: appId ?? resolvedAppId,
          timeoutMillis: timeout?.inMilliseconds,
        ),
      ),
    );
  }

  /// Returns a list of currently visible native UI controls, specified by
  /// [selector], which are currently visible on screen.
  ///
  /// If [selector] is null, returns the whole native UI tree.
  @override
  Future<IOSGetNativeViewsResponse> getNativeViews(
    IOSSelector? selector, {
    List<String>? iosInstalledApps,
    String? appId,
  }) {
    return wrapRequest(
      'getNativeViews',
      () => _client.getNativeViews(
        IOSGetNativeViewsRequest(
          selector: selector,
          appId: appId ?? resolvedAppId,
          iosInstalledApps: iosInstalledApps,
        ),
      ),
      enablePatrolLog: false,
    );
  }

  @override
  Future<void> injectCameraPhoto({required String imageName}) async {
    await wrapRequest('injectCameraPhoto', () async {
      await _client.injectCameraPhoto(
        IOSInjectCameraPhotoRequest(
          imageName: imageName,
          appId: resolvedAppId,
        ),
      );
    });
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
    IOSSelector? shutterButtonSelector,
    IOSSelector? doneButtonSelector,
    Duration? timeout,
  }) async {
    await wrapRequest('takeCameraPhoto', () async {
      await _client.takeCameraPhoto(
        IOSTakeCameraPhotoRequest(
          shutterButtonSelector: shutterButtonSelector,
          doneButtonSelector: doneButtonSelector,
          appId: resolvedAppId,
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
    IOSSelector? imageSelector,
    int? index,
    Duration? timeout,
  }) async {
    await wrapRequest('pickImageFromGallery', () async {
      await _client.pickImageFromGallery(
        IOSPickImageFromGalleryRequest(
          imageSelector: imageSelector,
          appId: resolvedAppId,
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
    IOSSelector? imageSelector,
    Duration? timeout,
  }) async {
    await wrapRequest('pickMultipleImagesFromGallery', () async {
      await _client.pickMultipleImagesFromGallery(
        IOSPickMultipleImagesFromGalleryRequest(
          imageSelector: imageSelector,
          appId: resolvedAppId,
          imageIndexes: imageIndexes,
          timeoutMillis: timeout?.inMilliseconds,
        ),
      );
    });
  }
}
