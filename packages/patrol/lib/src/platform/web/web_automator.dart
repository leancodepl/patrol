import 'dart:collection';
import 'dart:ui';

import 'package:patrol/src/platform/web/upload_file_data.dart';
import 'package:patrol/src/platform/web/web_selector.dart';

/// Provides functionality to interact with web applications.
abstract interface class WebAutomator {
  /// Initializes the web automator.
  Future<void> initialize();

  /// Configures the web automator.
  Future<void> configure();

  /// Enables dark mode.
  Future<void> enableDarkMode();

  /// Disables dark mode.
  Future<void> disableDarkMode();

  /// Taps on the web element specified by [selector].
  Future<void> tap(WebSelector selector, {WebSelector? iframeSelector});

  /// Enters text to the web element specified by [selector].
  Future<void> enterText(
    WebSelector selector, {
    required String text,
    WebSelector? iframeSelector,
  });

  /// Scrolls to the web element specified by [selector].
  Future<void> scrollTo(WebSelector selector, {WebSelector? iframeSelector});

  /// Grants the specified browser [permissions].
  Future<void> grantPermissions({required List<String> permissions});

  /// Clears all browser permissions.
  Future<void> clearPermissions();

  /// Adds a cookie.
  Future<void> addCookie({
    required String name,
    required String value,
    String? url,
    String? domain,
    String? path,
    int? expires,
    bool? httpOnly,
    bool? secure,
    String? sameSite,
  });

  /// Gets all cookies.
  Future<List<LinkedHashMap<Object?, Object?>>> getCookies();

  /// Clears all cookies.
  Future<void> clearCookies();

  /// Uploads files.
  Future<void> uploadFile({required List<UploadFileData> files});

  /// Accepts the next dialog that appears.
  Future<String> acceptNextDialog();

  /// Dismisses the next dialog that appears.
  Future<String> dismissNextDialog();

  /// Presses a keyboard key.
  Future<void> pressKey({required String key});

  /// Presses a keyboard key combination.
  Future<void> pressKeyCombo({required List<String> keys});

  /// Goes back in the browser history.
  Future<void> goBack();

  /// Goes forward in the browser history.
  Future<void> goForward();

  /// Gets the clipboard content.
  Future<String> getClipboard();

  /// Sets the clipboard content.
  Future<void> setClipboard({required String text});

  /// Resizes the browser window.
  Future<void> resizeWindow({required Size size});

  /// Returns a list of all files downloaded during the single test.
  Future<List<String>> verifyFileDownloads();
}
