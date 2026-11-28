import 'dart:convert';

import 'package:path/path.dart' as p;

/// Components every Visual Studio install that builds the runner must have:
/// the C++ compiler and the CMake bundled with Visual Studio.
const requiredComponents = [
  'Microsoft.VisualStudio.Component.VC.Tools.x86.x64',
  'Microsoft.VisualStudio.Component.VC.CMake.Project',
];

/// Decodes `vswhere.exe` output, which is not valid UTF-8 on some locales.
const vswhereEncoding = Utf8Codec(allowMalformed: true);

/// A Visual Studio install reported by `vswhere.exe`.
class VisualStudioInstall {
  /// Creates a [VisualStudioInstall].
  const VisualStudioInstall({required this.version, required this.path});

  /// Full version, such as `18.12.12412.261`.
  final String version;

  /// Install directory, such as `C:\Program Files\Microsoft Visual Studio\18`.
  final String path;

  /// The CMake generator for this version, or null when none is known.
  String? get cmakeGenerator {
    final major = int.tryParse(version.trim().split('.').first);
    return switch (major) {
      17 => 'Visual Studio 17 2022',
      18 => 'Visual Studio 18 2026',
      _ => null,
    };
  }

  /// The CMake bundled with this install, which always knows its generator.
  String get bundledCmakePath => p.windows.join(
    path,
    'Common7',
    'IDE',
    'CommonExtensions',
    'Microsoft',
    'CMake',
    'CMake',
    'bin',
    'cmake.exe',
  );
}

/// Path to `vswhere.exe`, which the Visual Studio installer always places here.
String vswherePath(Map<String, String> environment) {
  final programFiles =
      environment['ProgramFiles(x86)'] ?? r'C:\Program Files (x86)';
  return p.windows.join(
    programFiles,
    'Microsoft Visual Studio',
    'Installer',
    'vswhere.exe',
  );
}

/// Arguments for `vswhere.exe` that print [property] of the newest Visual
/// Studio (including Build Tools) with [requiredComponents].
List<String> vswhereArguments(String property) => [
  '-latest',
  '-products',
  '*',
  '-requires',
  ...requiredComponents,
  '-property',
  property,
  '-utf8',
];

/// The install described by the `installationVersion` and `installationPath`
/// values `vswhere.exe` printed, or null when it found none.
VisualStudioInstall? visualStudioInstallFrom({
  required String version,
  required String path,
}) {
  final trimmedVersion = version.trim();
  final trimmedPath = path.trim();
  if (trimmedVersion.isEmpty || trimmedPath.isEmpty) {
    return null;
  }
  return VisualStudioInstall(version: trimmedVersion, path: trimmedPath);
}

/// Arguments for configuring the runner with [install]'s generator and
/// instance, so neither `CMAKE_GENERATOR` nor another install replaces them.
List<String> cmakeConfigureArguments({
  required String cmake,
  required String sourceDir,
  required String buildDir,
  required String generator,
  required VisualStudioInstall install,
}) => [
  cmake,
  '-S',
  sourceDir,
  '-B',
  buildDir,
  '-G',
  generator,
  '-A',
  'x64',
  '-DCMAKE_GENERATOR_INSTANCE=${install.path}',
];
