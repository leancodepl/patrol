import 'common.dart';
import 'service_airplane_mode_test.dart' as airplane_mode_test;
import 'service_bluetooth_test.dart' as bluetooth_test;
import 'service_cellular_test.dart' as location_test;
import 'service_dark_mode_test.dart' as dark_mode_test;
import 'service_wifi_test.dart' as wifi_test;

void main() {
  group('bundled tests', () {
    airplane_mode_test.main();
    bluetooth_test.main();
    location_test.main();
    dark_mode_test.main();
    wifi_test.main();
  });
}
