import 'package:flutter_test/flutter_test.dart';

import 'example_test.dart' as example_test;
import 'notifications_test.dart' as notifications_test;
import 'permissions_many_test.dart' as permissions_many_test;

Future<void> main() async {
  group('app_test.dart', example_test.main);

  group('permissions_many_test.dart', permissions_many_test.main);

  group('notifications_test.dart', notifications_test.main);
}
