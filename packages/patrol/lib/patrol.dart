/// Powerful Flutter-native UI testing framework overcoming limitations of
/// existing Flutter testing tools. Ready for action!
library;

export 'package:patrol_finders/patrol_finders.dart' hide PatrolTester;

export 'src/binding.dart';
// Exporting patrol methods to be used in tests.
// ignore: invalid_export_of_internal_element
export 'src/common.dart';
export 'src/custom_finders/patrol_integration_tester.dart';
export 'src/native/native.dart';
export 'src/server_port_provider.dart';
