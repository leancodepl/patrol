import 'package:path/path.dart' as p;

/// Component every Visual Studio install that builds the runner must have.
const vcToolsComponent = 'Microsoft.VisualStudio.Component.VC.Tools.x86.x64';

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

/// Arguments for `vswhere.exe` that print the version of the newest
/// Visual Studio (including Build Tools) with the C++ desktop toolchain.
List<String> vswhereArguments() => [
  '-latest',
  '-products',
  '*',
  '-requires',
  vcToolsComponent,
  '-property',
  'installationVersion',
];

/// The CMake generator for a Visual Studio [installationVersion] such as
/// `17.14.36310.24`, or null when this version has no known generator.
String? cmakeGeneratorFor(String installationVersion) {
  final major = int.tryParse(installationVersion.trim().split('.').first);
  return switch (major) {
    17 => 'Visual Studio 17 2022',
    18 => 'Visual Studio 18 2026',
    _ => null,
  };
}

/// Arguments for configuring the runner with an explicit [generator], so a
/// `CMAKE_GENERATOR` set in the environment does not replace it.
List<String> cmakeConfigureArguments({
  required String sourceDir,
  required String buildDir,
  required String generator,
}) => ['cmake', '-S', sourceDir, '-B', buildDir, '-G', generator, '-A', 'x64'];
