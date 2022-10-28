import 'package:logging/logging.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/common/artifacts_repository.dart';
import 'package:patrol_cli/src/features/devices/device_finder.dart';
import 'package:patrol_cli/src/features/drive/flutter_driver.dart';
import 'package:patrol_cli/src/features/drive/platform/android_driver.dart';
import 'package:patrol_cli/src/features/drive/platform/ios_driver.dart';
import 'package:pub_updater/pub_updater.dart';

class MockArtifactsRepository extends Mock implements ArtifactsRepository {}

class MockDeviceFinder extends Mock implements DeviceFinder {}

class MockAndroidDriver extends Mock implements AndroidDriver {}

class MockIOSDriver extends Mock implements IOSDriver {}

class MockFlutterDriver extends Mock implements FlutterDriver {}

class MockLogger extends Mock implements Logger {}

class MockPubUpdater extends Mock implements PubUpdater {}
