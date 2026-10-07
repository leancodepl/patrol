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
  // Ports injected through the environment (Linux) must take precedence over
  // the `--dart-define` values and the defaults, which are what these tests
  // fall back to because no PATROL_*_PORT dart-define is set.
  group('PatrolRuntimePorts.loadFromEnvironment()', () {
    tearDown(() => PatrolRuntimePorts.loadFromEnvironment({}));

    test('environment ports are used by the app service and automator', () {
      PatrolRuntimePorts.loadFromEnvironment({
        'PATROL_TEST_SERVER_PORT': '9101',
        'PATROL_APP_SERVER_PORT': '9102',
      });

      expect(const MobileAutomatorConfig().port, '9101');
      expect(_service().port, 9102);
    });

    test('missing, malformed or out-of-range environment ports fall back to '
        'the defaults', () {
      for (final environment in [
        {'UNRELATED': '1'},
        {'PATROL_TEST_SERVER_PORT': 'not-a-port', 'PATROL_APP_SERVER_PORT': ''},
        {'PATROL_TEST_SERVER_PORT': '0', 'PATROL_APP_SERVER_PORT': '-1'},
        {'PATROL_TEST_SERVER_PORT': '65536', 'PATROL_APP_SERVER_PORT': '70000'},
      ]) {
        PatrolRuntimePorts.loadFromEnvironment(environment);

        expect(const MobileAutomatorConfig().port, '8081');
        expect(_service().port, 8082);
      }
    });
  });
}
