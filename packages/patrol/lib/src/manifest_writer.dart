// Writes the build-time test-discovery manifest to disk.
//
// The implementation is selected with a conditional import so the generated
// `test_bundle.dart` never imports `dart:io` directly. Importing `dart:io`
// there would make the bundle uncompilable for Flutter web even when
// build-time discovery is disabled. On platforms without `dart:io` (e.g.
// Flutter web) this resolves to a no-op; discovery only ever runs on the host
// VM via `flutter test`.
export 'manifest_writer_stub.dart'
    if (dart.library.io) 'manifest_writer_io.dart';
