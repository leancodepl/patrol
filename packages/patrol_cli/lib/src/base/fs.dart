import 'package:file/file.dart';
import 'package:platform/platform.dart';

Directory getHomeDirectory(FileSystem fs, Platform platform) {
  String? home;
  final envVars = platform.environment;
  if (platform.isMacOS) {
    home = envVars['HOME'];
  } else if (platform.isLinux) {
    home = envVars['HOME'];
  } else if (platform.isWindows) {
    home = envVars['UserProfile'];
  }

  return fs.directory(home);
}

/// Recursively checks if [filename] exists in the hierarchy of directories,
/// starting from the current directory of [fs] and going up.
bool existsInHierarchy(FileSystem fs, String filename) {
  var current = fs.currentDirectory;
  while (current.path != current.parent.path) {
    final file = current.childFile(filename);
    if (file.existsSync()) {
      return true;
    }

    current = current.parent;
  }

  return false;
}
