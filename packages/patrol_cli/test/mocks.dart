import 'package:archive/archive.dart' as archive;
import 'package:http/http.dart' as http;
import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/common/artifacts_repository.dart';
import 'package:patrol_cli/src/features/devices/device_finder.dart';
import 'package:patrol_cli/src/features/drive/flutter_tool.dart';
import 'package:patrol_cli/src/features/drive/platform/android_driver.dart';
import 'package:patrol_cli/src/features/drive/platform/ios_driver.dart';
import 'package:pub_updater/pub_updater.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockZipDecoder extends Mock implements archive.ZipDecoder {}

class MockLogger extends Mock implements Logger {}

class MockPubUpdater extends Mock implements PubUpdater {}

class MockProgress extends Mock implements Progress {}

class MockArtifactsRepository extends Mock implements ArtifactsRepository {}

class MockDeviceFinder extends Mock implements DeviceFinder {}

class MockAndroidDriver extends Mock implements AndroidDriver {}

class MockIOSDriver extends Mock implements IOSDriver {}

class MockFlutterTool extends Mock implements FlutterTool {}
