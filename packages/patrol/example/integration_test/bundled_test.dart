import 'package:flutter_test/flutter_test.dart';

import 'example_test.dart' as example_test;
import 'notifications_test.dart' as notifications_test;
import 'permissions_many_test.dart' as permissions_many_test;

Future<void> main() async {
  // initialize the bindings
  // get the "FLUTTER_TEST_TARGET" environment variable through the platform channel
  final target = ...;

  if (target == 'integration_test/example_test.dart') {
    group('app_test.dart', example_test.main);
  }

  if (target == 'integration_test/permissions_many_test.dart') {
    group('permissions_many_test.dart', permissions_many_test.main);
  }

  if (target == 'integration_test/notifications_test.dart') {
    group('notifications_test.dart', notifications_test.main);
  }
}
