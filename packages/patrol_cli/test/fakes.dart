import 'package:mocktail/mocktail.dart';

void setUpFakes() {
  registerFallbackValue(Uri());
  registerFallbackValue(<int>[]);
}
