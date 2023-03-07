import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/android/android_test_backend.dart';
import 'package:patrol_cli/src/features/devices/device.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';

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
