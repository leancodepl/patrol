import 'dart:io';

/// Writes [contents] to the file at [path].
///
/// Used by the generated test bundle in build-time discovery mode to serialize
/// the discovered Dart test tree to the manifest.
void writeTestManifest(String path, String contents) {
  File(path).writeAsStringSync(contents);
}
