import 'package:patrol_cli/src/features/run_commons/device.dart';

const androidDeviceName = 'Pixel 5';
const androidDeviceId = 'emulator-5554';
const androidDevice = Device(
  name: androidDeviceName,
  id: androidDeviceId,
  targetPlatform: TargetPlatform.android,
  real: true,
);

const iosDeviceName = 'iPhone 13';
const iosDeviceId = '00008101-001611D026A0001E';
const iosDevice = Device(
  name: iosDeviceName,
  id: iosDeviceId,
  targetPlatform: TargetPlatform.iOS,
  real: true,
);
