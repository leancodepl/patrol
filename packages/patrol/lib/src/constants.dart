import 'package:meta/meta.dart';

/// Whether Hot Restart is enabled.
@internal
const hotRestartEnabled = bool.fromEnvironment('PATROL_HOT_RESTART');
