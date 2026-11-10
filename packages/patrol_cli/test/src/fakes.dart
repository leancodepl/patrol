import 'package:mocktail/mocktail.dart';
import 'package:platform/testing.dart';

void setUpFakes() {
  registerFallbackValue(Uri());
}

TestNativePlatform fakePlatform(String home) {
  return TestNativePlatform(
    environment: {'HOME': home},
    operatingSystem: 'macos',
    operatingSystemVersion: 'Version 13.3.1 (a) (Build 22E772610a)',
    localeName: 'en-US',
  );
}
