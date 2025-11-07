import 'dart:collection';
import 'package:patrol/src/platform/web/upload_file_data.dart';
import 'package:patrol/src/platform/web/web_selector.dart';

abstract interface class WebAutomator {
  Future<void> initialize();

  Future<void> configure();

  Future<void> enableDarkMode();

  Future<void> disableDarkMode();

  Future<void> tap(WebSelector selector, {WebSelector? iframeSelector});

  Future<void> enterText(
    WebSelector selector, {
    required String text,
    WebSelector? iframeSelector,
  });

  Future<void> scrollTo(WebSelector selector, {WebSelector? iframeSelector});

  Future<void> grantPermissions({required List<String> permissions});

  Future<void> clearPermissions();

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

  Future<List<LinkedHashMap<Object?, Object?>>> getCookies();

  Future<void> clearCookies();

  Future<void> uploadFile({required List<UploadFileData> files});

  Future<String> acceptNextDialog();

  Future<String> dismissNextDialog();

  Future<void> pressKey({required String key});

  Future<void> pressKeyCombo({required List<String> keys});

  Future<void> goBack();

  Future<void> goForward();

  Future<String> getClipboard();

  Future<void> setClipboard({required String text});

  Future<void> resizeWindow({required int width, required int height});

  Future<List<String>> verifyFileDownloads();
}
