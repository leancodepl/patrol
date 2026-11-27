import 'package:version/version.dart';

/// Whether [flutterVersion] is [minimum] or newer, counting the prereleases
/// of [minimum] (its betas) as new enough.
///
/// An unknown version passes, so a format change upstream can't block a
/// command: that is one that doesn't parse, or 0.x, which Flutter reports (as
/// `0.0.0-unknown`) when it can't read its git tags.
bool flutterVersionAtLeast(String flutterVersion, String minimum) {
  final Version version;
  try {
    version = Version.parse(flutterVersion);
  } on Object {
    return true;
  }
  return version.major == 0 || version >= Version.parse('$minimum-0.0.pre');
}
