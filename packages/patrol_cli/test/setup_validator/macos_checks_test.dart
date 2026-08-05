import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:patrol_cli/src/setup_validator/checks/macos_checks.dart';
import 'package:patrol_cli/src/setup_validator/finding.dart';
import 'package:patrol_cli/src/setup_validator/project_probe.dart';
import 'package:test/test.dart';

const _runnerUITestsM = '''
@import XCTest;
@import patrol;
@import ObjectiveC.runtime;

PATROL_INTEGRATION_TEST_MACOS_RUNNER(RunnerUITests)
''';

const _podfile = '''
target 'Runner' do
  use_frameworks!
  flutter_install_all_macos_pods File.dirname(File.realpath(__FILE__))

  target 'RunnerUITests' do
    inherit! :complete
  end
end
''';

const _sandboxedEntitlements = '''
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
	<key>com.apple.security.app-sandbox</key>
	<true/>
	<key>com.apple.security.network.client</key>
	<true/>
	<key>com.apple.security.network.server</key>
	<true/>
</dict>
</plist>
''';

const _pbxproj = '// !\$*UTF8*\$!\n'
    '{\n'
    '\tobjects = {\n'
    '\t\tAA1 /* Runner */ = {\n'
    '\t\t\tisa = PBXNativeTarget;\n'
    '\t\t\tname = Runner;\n'
    '\t\t};\n'
    '\t\tAA2 /* RunnerUITests */ = {\n'
    '\t\t\tisa = PBXNativeTarget;\n'
    '\t\t\tbuildPhases = (\n'
    '\t\t\t\tBBBBBBBBBBBBBBBBBBBBBBB2 /* macos_assemble build */,\n'
    '\t\t\t\tBBBBBBBBBBBBBBBBBBBBBBB3 /* macos_assemble embed */,\n'
    '\t\t\t);\n'
    '\t\t\tname = RunnerUITests;\n'
    '\t\t};\n'
    '\t\tBBBBBBBBBBBBBBBBBBBBBBB2 /* ShellScript */ = {\n'
    '\t\t\tisa = PBXShellScriptBuildPhase;\n'
    '\t\t\tshellScript = "/bin/sh \\"\\\$FLUTTER_ROOT/packages/'
    'flutter_tools/bin/macos_assemble.sh\\" build\\n";\n'
    '\t\t};\n'
    '\t\tBBBBBBBBBBBBBBBBBBBBBBB3 /* ShellScript */ = {\n'
    '\t\t\tisa = PBXShellScriptBuildPhase;\n'
    '\t\t\tshellScript = "/bin/sh \\"\\\$FLUTTER_ROOT/packages/'
    'flutter_tools/bin/macos_assemble.sh\\" embed\\n";\n'
    '\t\t};\n'
    '\t\tC1 /* Debug */ = {\n'
    '\t\t\tisa = XCBuildConfiguration;\n'
    '\t\t\tbuildSettings = {\n'
    '\t\t\t\tCODE_SIGN_ENTITLEMENTS = RunnerUITests/DebugProfile.entitlements;\n'
    '\t\t\t\tENABLE_USER_SCRIPT_SANDBOXING = NO;\n'
    '\t\t\t\tMACOSX_DEPLOYMENT_TARGET = 10.14;\n'
    '\t\t\t};\n'
    '\t\t};\n'
    '\t\tC2 /* Debug */ = {\n'
    '\t\t\tisa = XCBuildConfiguration;\n'
    '\t\t\tbuildSettings = {\n'
    '\t\t\t\tMACOSX_DEPLOYMENT_TARGET = 10.14;\n'
    '\t\t\t\tTEST_TARGET_NAME = Runner;\n'
    '\t\t\t};\n'
    '\t\t};\n'
    '\t};\n'
    '}\n';

void main() {
  late MemoryFileSystem fs;
  late Directory projectRoot;

  setUp(() {
    fs = MemoryFileSystem();
    projectRoot = fs.directory('/project')..createSync();
  });

  void write(String path, String contents) {
    fs.file('/project/$path')
      ..createSync(recursive: true)
      ..writeAsStringSync(contents);
  }

  MacOSCheckContext context() =>
      MacOSCheckContext(probe: ProjectProbe(projectRoot: projectRoot));

  void writeCompleteProject() {
    write('macos/Runner.xcodeproj/project.pbxproj', _pbxproj);
    write('macos/RunnerUITests/RunnerUITests.m', _runnerUITestsM);
    write('macos/Podfile', _podfile);
    write('macos/Runner/DebugProfile.entitlements', _sandboxedEntitlements);
    write('macos/Runner/Release.entitlements', _sandboxedEntitlements);
    write(
      'macos/RunnerUITests/DebugProfile.entitlements',
      _sandboxedEntitlements,
    );
    write(
      'macos/RunnerUITests/Release.entitlements',
      _sandboxedEntitlements,
    );
  }

  List<String> idsOf(List<Finding> findings) =>
      findings.map((finding) => finding.id).toList();

  test('complete project yields only the manual-verify notice', () {
    writeCompleteProject();
    final findings = macosFindings(context());
    expect(findings, hasLength(1));
    expect(findings.single.severity, Severity.notice);
    expect(findings.single.summary, contains('Verify manually'));
  });

  test('missing xcodeproj reports a single error', () {
    final findings = macosFindings(context());
    expect(findings, hasLength(1));
    expect(findings.single.id, 'M2');
    expect(findings.single.severity, Severity.error);
  });

  test('renamed project gets a P2 notice (#1878)', () {
    writeCompleteProject();
    fs
        .directory('/project/macos/Runner.xcodeproj')
        .renameSync('/project/macos/MyApp.xcodeproj');
    expect(idsOf(macosFindings(context())), contains('P2'));
  });

  test('M0 errors when no integration mechanism exists', () {
    writeCompleteProject();
    fs.file('/project/macos/Podfile').deleteSync();
    expect(idsOf(macosFindings(context())), contains('M0'));
  });

  test('M1 errors when the macro file is missing', () {
    writeCompleteProject();
    fs.file('/project/macos/RunnerUITests/RunnerUITests.m').deleteSync();
    expect(idsOf(macosFindings(context())), contains('M1'));
  });

  test('M1 does not accept the iOS macro', () {
    writeCompleteProject();
    write(
      'macos/RunnerUITests/RunnerUITests.m',
      'PATROL_INTEGRATION_TEST_IOS_RUNNER(RunnerUITests)',
    );
    expect(idsOf(macosFindings(context())), contains('M1'));
  });

  test('M2 errors when the native target is missing', () {
    writeCompleteProject();
    write(
      'macos/Runner.xcodeproj/project.pbxproj',
      _pbxproj.replaceAll('RunnerUITests', 'SomethingElse'),
    );
    expect(idsOf(macosFindings(context())), contains('M2'));
  });

  group('M3 embedding', () {
    test('errors when the Podfile lacks the RunnerUITests block', () {
      writeCompleteProject();
      write('macos/Podfile', "target 'Runner' do\nend\n");
      final finding = macosFindings(
        context(),
      ).firstWhere((finding) => finding.id == 'M3');
      expect(finding.severity, Severity.error);
      expect(finding.fix, contains('pod install'));
    });

    test('checks SPM linkage when SPM is the mechanism', () {
      writeCompleteProject();
      fs.file('/project/macos/Podfile').deleteSync();
      // Runner links the package; RunnerUITests does not.
      final pbxproj = _pbxproj.replaceFirst(
        '\t\t\tname = Runner;\n',
        '\t\t\tname = Runner;\n'
            '\t\t\tpackageProductDependencies = (\n'
            '\t\t\t\tP1 /* FlutterGeneratedPluginSwiftPackage */,\n'
            '\t\t\t);\n',
      );
      write('macos/Runner.xcodeproj/project.pbxproj', pbxproj);
      final finding = macosFindings(
        context(),
      ).firstWhere((finding) => finding.id == 'M3');
      expect(finding.summary, contains('FlutterGeneratedPluginSwiftPackage'));
    });
  });

  test('M4 errors when a macos_assemble phase is missing', () {
    writeCompleteProject();
    write(
      'macos/Runner.xcodeproj/project.pbxproj',
      _pbxproj.replaceAll(r'macos_assemble.sh\" embed', r'other.sh\" embed'),
    );
    final finding = macosFindings(
      context(),
    ).firstWhere((finding) => finding.id == 'M4');
    expect(finding.severity, Severity.error);
    expect(finding.summary, contains('macos_assemble embed'));
  });

  group('M5 Runner entitlements', () {
    test('errors when a sandboxed profile lacks network permissions', () {
      writeCompleteProject();
      write(
        'macos/Runner/Release.entitlements',
        _sandboxedEntitlements.replaceAll(
          '\t<key>com.apple.security.network.server</key>\n\t<true/>\n',
          '',
        ),
      );
      final finding = macosFindings(
        context(),
      ).firstWhere((finding) => finding.id == 'M5');
      expect(finding.severity, Severity.error);
      expect(finding.summary, contains('Incoming Connections (Server)'));
    });

    test('is silent when the sandbox is disabled', () {
      writeCompleteProject();
      write(
        'macos/Runner/Release.entitlements',
        '<plist version="1.0"><dict></dict></plist>',
      );
      expect(idsOf(macosFindings(context())), isNot(contains('M5')));
    });
  });

  test('M6 errors when entitlements are not copied to RunnerUITests', () {
    writeCompleteProject();
    fs
        .file('/project/macos/RunnerUITests/Release.entitlements')
        .deleteSync();
    final finding = macosFindings(
      context(),
    ).firstWhere((finding) => finding.id == 'M6');
    expect(finding.severity, Severity.error);
    expect(finding.summary, contains('Release.entitlements'));
  });

  test('M7 warns when CODE_SIGN_ENTITLEMENTS is not configured', () {
    writeCompleteProject();
    write(
      'macos/Runner.xcodeproj/project.pbxproj',
      _pbxproj.replaceAll(
        '\t\t\t\tCODE_SIGN_ENTITLEMENTS = RunnerUITests/DebugProfile.entitlements;\n',
        '',
      ),
    );
    final finding = macosFindings(
      context(),
    ).firstWhere((finding) => finding.id == 'M7');
    expect(finding.severity, Severity.warning);
  });

  group('M8 mirrored iOS rules', () {
    test('warns on sandboxing YES, deployment mismatch and parallelism', () {
      writeCompleteProject();
      write(
        'macos/Runner.xcodeproj/project.pbxproj',
        _pbxproj
            .replaceAll(
              'ENABLE_USER_SCRIPT_SANDBOXING = NO',
              'ENABLE_USER_SCRIPT_SANDBOXING = YES',
            )
            .replaceFirst(
              'MACOSX_DEPLOYMENT_TARGET = 10.14;\n'
                  '\t\t\t\tTEST_TARGET_NAME = Runner;',
              'MACOSX_DEPLOYMENT_TARGET = 26.0;\n'
                  '\t\t\t\tTEST_TARGET_NAME = Runner;',
            ),
      );
      write(
        'macos/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme',
        '<TestableReference parallelizable = "YES"></TestableReference>',
      );
      write('macos/RunnerUITests/RunnerUITestsLaunchTests.m', '@import XCTest;');
      final findings = macosFindings(context());
      final m8 = findings.where(
        (finding) =>
            finding.id == 'M8' && finding.severity == Severity.warning,
      );
      expect(m8, hasLength(4));
    });

    test('manual notice adapts to project state', () {
      writeCompleteProject();
      final notice = macosFindings(context()).firstWhere(
        (finding) =>
            finding.id == 'M8' && finding.severity == Severity.notice,
      );
      expect(notice.summary, contains('Configuration Set'));
      expect(notice.summary, isNot(contains('User Script Sandboxing')));
      expect(notice.summary, contains('parallel execution'));
    });
  });
}
