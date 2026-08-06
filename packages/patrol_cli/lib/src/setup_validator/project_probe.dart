import 'package:file/file.dart';

/// Read-only access to the project's files for setup checks.
///
/// All paths are relative to the project root. Backed by `package:file`, so
/// tests can inject a `MemoryFileSystem`.
class ProjectProbe {
  ProjectProbe({required Directory projectRoot})
    : _root = projectRoot,
      _fs = projectRoot.fileSystem;

  final Directory _root;
  final FileSystem _fs;

  String _absolute(String relative) => _fs.path.join(_root.path, relative);

  bool fileExists(String relative) =>
      _fs.file(_absolute(relative)).existsSync();

  bool dirExists(String relative) =>
      _fs.directory(_absolute(relative)).existsSync();

  /// Returns the file contents, or null if it doesn't exist or can't be read.
  String? readFile(String relative) {
    final file = _fs.file(_absolute(relative));
    if (!file.existsSync()) {
      return null;
    }
    try {
      return file.readAsStringSync();
    } on FileSystemException {
      return null;
    }
  }

  /// Reads every file named [name] in the project root and its ancestor
  /// directories, nearest first. Pub workspaces keep pubspec.lock (and often
  /// .gitignore) at the workspace root, above the app's own directory.
  List<String> readFilesHereAndAbove(String name) {
    final contents = <String>[];
    var dir = _root.absolute;
    while (true) {
      final file = dir.childFile(name);
      if (file.existsSync()) {
        try {
          contents.add(file.readAsStringSync());
        } on FileSystemException {
          // Unreadable ancestor files are skipped.
        }
      }
      if (dir.parent.path == dir.path) {
        return contents;
      }
      dir = dir.parent;
    }
  }

  /// Recursively lists regular files under [relative], as paths relative to
  /// the project root. Returns an empty list if the directory doesn't exist.
  List<String> listFilesRecursively(String relative) {
    final dir = _fs.directory(_absolute(relative));
    if (!dir.existsSync()) {
      return [];
    }
    return dir
        .listSync(recursive: true, followLinks: false)
        .whereType<File>()
        .map((file) => _fs.path.relative(file.path, from: _root.path))
        .toList();
  }
}
