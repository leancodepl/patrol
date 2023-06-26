import 'dart:io' as io;

import 'package:mocktail/mocktail.dart';
import 'package:platform/platform.dart';

class FakeProcessResult extends Fake implements io.ProcessResult {}

void setUpFakes() {
  registerFallbackValue(Uri());
}

FakePlatform fakePlatform(String home) {
  return FakePlatform(
    environment: {'HOME': home},
    operatingSystem: 'macos',
    operatingSystemVersion: 'Version 13.3.1 (a) (Build 22E772610a)',
    localeName: 'en-US',
  );
}
