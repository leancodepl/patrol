import 'package:patrol_cli/patrol_cli.dart' show Device, TargetPlatform;

/// Platforms `patrol develop` can run. Add [TargetPlatform.web] once web
/// develop lands (feat/patrol-web-develop); macOS is unsupported.
const developSupportedPlatforms = {TargetPlatform.android, TargetPlatform.iOS};

/// Attached devices the MCP can run on (returned by the `devices` tool).
List<Device> supportedDevices(List<Device> attached) => attached
    .where((d) => developSupportedPlatforms.contains(d.targetPlatform))
    .toList();

/// The best device to run on when none is specified (see [_rank] for the
/// order), or `null` if nothing auto-selectable is attached. Web is never
/// auto-selected.
Device? autoSelectDevice(List<Device> attached) {
  final ranked =
      attached
          .map((d) => (device: d, rank: _rank(d)))
          .where((e) => e.rank < _notSelectable)
          .toList()
        ..sort((a, b) => a.rank.compareTo(b.rank));

  return ranked.isEmpty ? null : ranked.first.device;
}

const _notSelectable = 99;

int _rank(Device d) {
  // Android before iOS, physical devices before emulators/simulators.
  // Device.real is true for physical devices, false for emulators/simulators.
  return switch ((d.targetPlatform, d.real)) {
    (TargetPlatform.android, true) => 0, // Android device
    (TargetPlatform.android, false) => 1, // Android emulator
    (TargetPlatform.iOS, true) => 2, // iOS device
    (TargetPlatform.iOS, false) => 3, // iOS simulator
    _ => _notSelectable, // web / macOS
  };
}
