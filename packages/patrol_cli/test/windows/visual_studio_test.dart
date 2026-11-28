import 'package:patrol_cli/src/windows/visual_studio.dart';
import 'package:test/test.dart';

void main() {
  const vs2026 = VisualStudioInstall(
    version: '18.12.12412.261',
    path: r'C:\Program Files\Microsoft Visual Studio\18\Enterprise',
  );

  group('cmakeGenerator', () {
    test('maps Visual Studio 2022 and 2026 to their generators', () {
      const vs2022 = VisualStudioInstall(version: '17.14.36310.24', path: '');
      expect(vs2022.cmakeGenerator, 'Visual Studio 17 2022');
      expect(vs2026.cmakeGenerator, 'Visual Studio 18 2026');
    });

    test('is null for versions without a known generator', () {
      const vs2019 = VisualStudioInstall(version: '16.11.0.0', path: '');
      expect(vs2019.cmakeGenerator, isNull);
    });
  });

  test('bundledCmakePath points at the CMake shipped with the install', () {
    expect(
      vs2026.bundledCmakePath,
      r'C:\Program Files\Microsoft Visual Studio\18\Enterprise\Common7\IDE'
      r'\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe',
    );
  });

  group('visualStudioInstallFrom', () {
    test('reads the trimmed version and path vswhere printed', () {
      final install = visualStudioInstallFrom(
        version: '18.12.12412.261\r\n',
        path: '${vs2026.path}\r\n',
      );
      expect(install?.version, vs2026.version);
      expect(install?.path, vs2026.path);
    });

    test('is null when vswhere found no install', () {
      expect(visualStudioInstallFrom(version: '', path: ''), isNull);
      expect(visualStudioInstallFrom(version: '18.0', path: ' '), isNull);
    });
  });

  test('vswhere output with malformed UTF-8 still decodes', () {
    // flutter/flutter#102451: vswhere writes invalid UTF-8 on some locales.
    final decoded = vswhereEncoding.decode([0x31, 0x38, 0xFF, 0x2E, 0x30]);
    expect(decoded, startsWith('18'));
  });

  test('configure arguments pin the generator and the install', () {
    final args = cmakeConfigureArguments(
      cmake: vs2026.bundledCmakePath,
      sourceDir: 'runner',
      buildDir: r'runner\build',
      generator: 'Visual Studio 18 2026',
      install: vs2026,
    );

    expect(args.first, vs2026.bundledCmakePath);
    expect(args, containsAllInOrder(['-G', 'Visual Studio 18 2026']));
    expect(args, containsAllInOrder(['-A', 'x64']));
    expect(args, contains('-DCMAKE_GENERATOR_INSTANCE=${vs2026.path}'));
  });

  test('vswhere asks for the C++ tools and the bundled CMake', () {
    expect(
      vswhereArguments('installationPath'),
      containsAllInOrder([
        '-requires',
        ...requiredComponents,
        '-property',
        'installationPath',
      ]),
    );
    expect(
      requiredComponents,
      contains('Microsoft.VisualStudio.Component.VC.CMake.Project'),
    );
    expect(
      vswherePath({'ProgramFiles(x86)': r'D:\PF86'}),
      r'D:\PF86\Microsoft Visual Studio\Installer\vswhere.exe',
    );
  });
}
