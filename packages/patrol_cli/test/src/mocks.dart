import 'dart:io' as io;

import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/android/android_test_backend.dart';
import 'package:patrol_cli/src/base/logger.dart' as logger;
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:process/process.dart' as process;
import 'package:pub_updater/pub_updater.dart' as pub;

class MockHttpClient extends Mock implements http.Client {}

class MockPubUpdater extends Mock implements pub.PubUpdater {}

class MockProcess extends Mock implements io.Process {}

class MockProcessManager extends Mock implements process.ProcessManager {}

class MockProgress extends Mock implements logger.Progress {}

class MockTask extends Mock implements logger.ProgressTask {}

class MockLogger extends Mock implements logger.Logger {}

class MockDeviceFinder extends Mock implements DeviceFinder {}

class MockAndroidTestBackend extends Mock implements AndroidTestBackend {}

class MockIOSTestBackend extends Mock implements IOSTestBackend {}
