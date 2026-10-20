/// Public API for driving a patrol develop session programmatically.
///
/// The published `patrol_mcp` 0.2.x allows any `patrol_cli ^4.3.0`, so it
/// resolves against new releases and imports this barrel whole. Symbols may be
/// added here, never removed or moved, until that package is retired.
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
