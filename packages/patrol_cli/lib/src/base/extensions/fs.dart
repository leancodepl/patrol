import 'package:file/file.dart';

extension FileSystemX on FileSystem {
  /// Recursively checks if [filename] exists in the hierarchy of directories,
  /// starting from the [currentDirectory] and going up.
  bool existsInHierarchy(String filename) {
    var current = currentDirectory;
    while (current.path != current.parent.path) {
      final file = current.childFile(filename);
      if (file.existsSync()) {
        return true;
      }

      current = current.parent;
    }

    return false;
  }
}
