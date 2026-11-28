import 'package:patrol_cli/src/windows/visual_studio.dart';
import 'package:test/test.dart';

void main() {
  group('cmakeGeneratorFor', () {
    test('maps Visual Studio 2022 and 2026 to their generators', () {
      expect(cmakeGeneratorFor('17.14.36310.24'), 'Visual Studio 17 2022');
      expect(cmakeGeneratorFor('18.12.12412.261\r\n'), 'Visual Studio 18 2026');
    });

    test('returns null for versions without a known generator', () {
      expect(cmakeGeneratorFor('16.11.0.0'), isNull);
      expect(cmakeGeneratorFor(''), isNull);
    });
  });

  test('configure arguments always pass the generator explicitly', () {
    final args = cmakeConfigureArguments(
      sourceDir: 'runner',
      buildDir: 'runner/build',
      generator: 'Visual Studio 18 2026',
    );

    expect(args, containsAllInOrder(['-G', 'Visual Studio 18 2026']));
    expect(args, containsAllInOrder(['-A', 'x64']));
  });

  test('vswhere asks for an install with the C++ desktop tools', () {
    expect(
      vswhereArguments(),
      containsAllInOrder(['-requires', vcToolsComponent]),
    );
    expect(
      vswherePath({'ProgramFiles(x86)': r'D:\PF86'}),
      r'D:\PF86\Microsoft Visual Studio\Installer\vswhere.exe',
    );
  });
}
