/// Base URI of the Patrol native automation server — the same server that
/// backs `$.platform.mobile.*` (default `localhost:8081`).
///
/// Optional Patrol extension packages (for example `patrol_axe`) should send
/// their custom native requests here, so their HTTP client talks to the routes
/// their native code registered via the platform extension hook
/// (`PatrolServerExtension`).
///
/// The host/port resolution matches core Patrol (`PATROL_HOST` /
/// `PATROL_TEST_SERVER_PORT`), so `patrol test` port-forwarding just works.
Uri get patrolNativeServerUri => Uri.http(
  '${const String.fromEnvironment('PATROL_HOST', defaultValue: 'localhost')}:'
  '${const String.fromEnvironment('PATROL_TEST_SERVER_PORT', defaultValue: '8081')}',
);
