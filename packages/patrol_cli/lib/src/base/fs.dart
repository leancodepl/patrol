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
