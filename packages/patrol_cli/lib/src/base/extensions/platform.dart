import 'package:file/memory.dart' as memoryfs;
import 'package:platform/platform.dart';

extension PlatformX on Platform {
  memoryfs.FileSystemStyle get fileSystemStyle {
    return isWindows
        ? memoryfs.FileSystemStyle.windows
        : memoryfs.FileSystemStyle.posix;
  }

  String get home {
    if (isMacOS) {
      return environment['HOME']!;
    } else if (isLinux) {
      return environment['HOME']!;
    } else if (isWindows) {
      return environment['UserProfile']!;
    } else {
      throw StateError('Unsupported platform: $operatingSystem');
    }
  }
}
