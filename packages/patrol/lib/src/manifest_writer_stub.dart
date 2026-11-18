/// No-op fallback used on platforms without `dart:io` (e.g. Flutter web).
///
/// Build-time test discovery only runs on the host VM (`flutter test`), so this
/// is never exercised on web; it exists solely so the generated bundle can
/// compile for web without importing `dart:io`.
void writeTestManifest(String path, String contents) {}
