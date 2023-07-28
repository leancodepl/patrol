/// Flutter-native UI testing framework eliminating limitations of
/// flutter_driver.
library patrol;

export 'package:patrol_finders/patrol_finders.dart' hide PatrolTester;

export 'src/binding.dart';
// ignore: invalid_export_of_internal_element
export 'src/common.dart';
// ignore: invalid_export_of_internal_element
export 'src/custom_finders/patrol_integration_tester.dart';
export 'src/native/native.dart';
