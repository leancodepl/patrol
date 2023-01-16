import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/features/run_commons/device.dart';

class FakeDevice extends Fake implements Device {}

class FakeProcessResult extends Fake implements ProcessResult {}

void setUpFakes() {
  registerFallbackValue(Uri());
  registerFallbackValue(<int>[]);
  registerFallbackValue(FakeDevice());
}
