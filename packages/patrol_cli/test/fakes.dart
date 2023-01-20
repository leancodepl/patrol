import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/features/run_commons/device.dart';
import 'package:patrol_cli/src/features/test/android_test_backend.dart';
import 'package:patrol_cli/src/features/test/ios_test_backend.dart';

class FakeDevice extends Fake implements Device {}

class FakeProcessResult extends Fake implements ProcessResult {}

class FakeAndroidAppOptions extends Fake implements AndroidAppOptions {}

class FakeIOSAppOptions extends Fake implements IOSAppOptions {}

void setUpFakes() {
  registerFallbackValue(Uri());
  registerFallbackValue(<int>[]);
  registerFallbackValue(FakeDevice());
  registerFallbackValue(FakeAndroidAppOptions());
  registerFallbackValue(FakeIOSAppOptions());
}
