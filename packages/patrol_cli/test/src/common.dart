import 'package:file/file.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:platform/platform.dart';
import 'package:test/test.dart';

final throwsToolExit = throwsA(isToolExit);
const isToolExit = TypeMatcher<ToolExit>();

Platform initFakePlatform(String platform, {String user = 'charlie'}) {
  switch (platform) {
    case 'macos':
      return FakePlatform(
        operatingSystem: Platform.macOS,
        environment: {'HOME': '/home/$user'},
      );
    case 'linux':
      return FakePlatform(
        operatingSystem: Platform.linux,
        environment: {'HOME': '/home/$user'},
      );
    case 'windows':
      return FakePlatform(
        operatingSystem: Platform.windows,
        environment: {'UserProfile': 'C:\\Users\\$user'},
      );
    default:
      throw StateError('Unsupported platform: $platform');
  }
}

extension DirectoryX on Directory {
  /// Shorthand for [Directory.childDirectory].
  Directory dir(String basename) => childDirectory(basename);

  /// Shorthand for [Directory.childFile].
  File file(String basename) => childFile(basename);
}
