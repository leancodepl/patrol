import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:patrol/src/platform/contracts/contracts.dart';
import 'package:patrol/src/platform/mobile/patrol_runtime_ports.dart';

PatrolAppService _service() => PatrolAppService(
  topLevelDartTestGroup: const DartGroupEntry(
    name: '',
    type: GroupEntryType.group,
    entries: [],
    skip: false,
    tags: [],
  ),
);

void main() {
  // The app server port injected through the environment (Linux) must take
  // precedence over the `--dart-define` value and the default, which is what
  // these tests fall back to because no PATROL_*_PORT dart-define is set.
  group('PatrolRuntimePorts.loadFromEnvironment()', () {
    tearDown(() => PatrolRuntimePorts.loadFromEnvironment({}));

    test('the environment app server port is used by the app service', () {
      PatrolRuntimePorts.loadFromEnvironment({
        'PATROL_TEST_SERVER_PORT': '9101',
        'PATROL_APP_SERVER_PORT': '9102',
      });

      expect(_service().port, 9102);
      // Linux has no native test server: its port is not read from the
      // environment, so the automator keeps the default.
      expect(const MobileAutomatorConfig().port, '8081');
    });

    test('missing, malformed or out-of-range environment ports fall back to '
        'the defaults', () {
      for (final environment in [
        {'UNRELATED': '1'},
        {'PATROL_APP_SERVER_PORT': ''},
        {'PATROL_APP_SERVER_PORT': 'not-a-port'},
        {'PATROL_APP_SERVER_PORT': '0'},
        {'PATROL_APP_SERVER_PORT': '-1'},
        {'PATROL_APP_SERVER_PORT': '65536'},
        {'PATROL_APP_SERVER_PORT': '70000'},
      ]) {
        PatrolRuntimePorts.loadFromEnvironment(environment);

        expect(_service().port, 8082, reason: '$environment');
      }
    });
  });
}
