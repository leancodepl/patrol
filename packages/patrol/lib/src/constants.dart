import 'package:meta/meta.dart';

/// Whether Hot Restart is enabled.
@internal
const hotRestartEnabled = bool.fromEnvironment('PATROL_HOT_RESTART');

/// Whether BrowserStack-specific features are enabled.
@internal
const browserStackEnabled = bool.fromEnvironment('PATROL_BROWSERSTACK');
