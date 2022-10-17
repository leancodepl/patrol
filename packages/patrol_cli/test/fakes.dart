import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/features/drive/device.dart';

class FakeDevice extends Fake implements Device {}

void setUpFakes() {
  registerFallbackValue(Uri());
  registerFallbackValue(<int>[]);
  registerFallbackValue(FakeDevice());
}
