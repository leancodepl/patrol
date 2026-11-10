import 'package:file/file.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:platform/testing.dart';
import 'package:test/test.dart';

final throwsToolExit = throwsA(isToolExit);
const isToolExit = TypeMatcher<ToolExit>();

NativePlatform initFakePlatform(String platform, {String user = 'charlie'}) {
  switch (platform) {
    case 'macos':
      return TestNativePlatform(
        operatingSystem: NativePlatform.macOS,
        environment: {'HOME': '/home/$user'},
      );
    case 'linux':
      return TestNativePlatform(
        operatingSystem: NativePlatform.linux,
        environment: {'HOME': '/home/$user'},
      );
    case 'windows':
      return TestNativePlatform(
        operatingSystem: NativePlatform.windows,
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
