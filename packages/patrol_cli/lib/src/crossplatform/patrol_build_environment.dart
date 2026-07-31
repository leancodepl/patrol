/// SPM uses this to set the corresponding PATROL_ENABLED flag.
const String patrolEnabledEnvironmentKey = 'PATROL_ENABLED';

/// Environment for `xcodebuild build-for-testing` on iOS and macOS.
const Map<String, String> darwinEnvironment = {
  patrolEnabledEnvironmentKey: '1',
};
