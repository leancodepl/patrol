/// Public API for driving a patrol develop session programmatically.
library;

export 'package:patrol_log/patrol_log.dart'
    show ConfigEntry, Entry, ErrorEntry, TestEntry, TestEntryStatus;
export 'src/base/command_line.dart';
export 'src/commands/develop_options.dart';
export 'src/commands/develop_service.dart';
export 'src/commands/develop_session_factory.dart';
export 'src/devices.dart' show Device, DeviceFinder, TargetPlatform;
export 'src/ios/ios_test_backend.dart' show BuildMode;
export 'src/runner/flutter_command.dart' show FlutterCommand;
