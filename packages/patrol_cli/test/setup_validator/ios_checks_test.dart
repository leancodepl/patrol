import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:patrol_cli/src/setup_validator/checks/ios_checks.dart';
import 'package:patrol_cli/src/setup_validator/finding.dart';
import 'package:patrol_cli/src/setup_validator/project_probe.dart';
import 'package:test/test.dart';

const _runnerUITestsM = '''
@import XCTest;
@import patrol;
@import ObjectiveC.runtime;

PATROL_INTEGRATION_TEST_IOS_RUNNER(RunnerUITests)
''';

const _podfile = '''
target 'Runner' do
  use_frameworks!
  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))

  target 'RunnerUITests' do
    inherit! :complete
  end
end
''';

const _podfileLock = '''
PODS:
  - patrol (0.0.1):
    - Flutter
''';

String _pbxproj({bool spm = true, bool uiTestsTarget = true}) {
  const packageDependency =
      '\t\t\tpackageProductDependencies = (\n'
      '\t\t\t\tP2 /* FlutterGeneratedPluginSwiftPackage */,\n'
      '\t\t\t);\n';
  final uiTests = uiTestsTarget
      ? '\t\tAA2 /* RunnerUITests */ = {\n'
            '\t\t\tisa = PBXNativeTarget;\n'
            '\t\t\tbuildPhases = (\n'
            '\t\t\t\tBBBBBBBBBBBBBBBBBBBBBBB2 /* xcode_backend build */,\n'
            '\t\t\t\tBBBBBBBBBBBBBBBBBBBBBBB3 /* xcode_backend embed_and_thin */,\n'
            '\t\t\t);\n'
            '\t\t\tname = RunnerUITests;\n'
            '${spm ? packageDependency : ''}'
            '\t\t};\n'
      : '';

  return '// !\$*UTF8*\$!\n'
      '{\n'
      '\tobjects = {\n'
      '\t\tAA1 /* Runner */ = {\n'
      '\t\t\tisa = PBXNativeTarget;\n'
      '\t\t\tname = Runner;\n'
      '${spm ? packageDependency : ''}'
      '\t\t};\n'
      '$uiTests'
      '\t\tBBBBBBBBBBBBBBBBBBBBBBB2 /* ShellScript */ = {\n'
      '\t\t\tisa = PBXShellScriptBuildPhase;\n'
      '\t\t\tshellScript = "/bin/sh \\"\\\$FLUTTER_ROOT/packages/'
      'flutter_tools/bin/xcode_backend.sh\\" build\\n";\n'
      '\t\t};\n'
      '\t\tBBBBBBBBBBBBBBBBBBBBBBB3 /* ShellScript */ = {\n'
      '\t\t\tisa = PBXShellScriptBuildPhase;\n'
      '\t\t\tshellScript = "/bin/sh \\"\\\$FLUTTER_ROOT/packages/'
      'flutter_tools/bin/xcode_backend.sh\\" embed_and_thin\\n";\n'
      '\t\t};\n'
      '\t\tC1 /* Debug */ = {\n'
      '\t\t\tisa = XCBuildConfiguration;\n'
      '\t\t\tbuildSettings = {\n'
      '\t\t\t\tENABLE_USER_SCRIPT_SANDBOXING = NO;\n'
      '\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 13.0;\n'
      '\t\t\t};\n'
      '\t\t};\n'
      '\t\tC2 /* Debug */ = {\n'
      '\t\t\tisa = XCBuildConfiguration;\n'
      '\t\t\tbuildSettings = {\n'
      '\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 13.0;\n'
      '\t\t\t\tTEST_TARGET_NAME = Runner;\n'
      '\t\t\t};\n'
      '\t\t};\n'
      '\t};\n'
      '}\n';
}

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

  IOSCheckContext context() =>
      IOSCheckContext(probe: ProjectProbe(projectRoot: projectRoot));

  /// A complete pure-SPM project (today's leancode_flutter_template layout).
  void writeSpmProject({String project = 'Runner'}) {
    write('ios/$project.xcodeproj/project.pbxproj', _pbxproj());
    write('ios/RunnerUITests/RunnerUITests.m', _runnerUITestsM);
  }

  /// A complete pure-CocoaPods project (default `flutter create` + docs).
  void writePodsProject() {
    write('ios/Runner.xcodeproj/project.pbxproj', _pbxproj(spm: false));
    write('ios/RunnerUITests/RunnerUITests.m', _runnerUITestsM);
    write('ios/Podfile', _podfile);
    write('ios/Podfile.lock', _podfileLock);
  }

  List<String> idsOf(List<Finding> findings) =>
      findings.map((finding) => finding.id).toList();

  group('complete projects', () {
    test('pure SPM project yields only the manual-verify notice', () {
      writeSpmProject();
      expect(idsOf(iosFindings(context())), ['I12']);
    });

    test('pure CocoaPods project yields only the manual-verify notice', () {
      writePodsProject();
      expect(idsOf(iosFindings(context())), ['I12']);
    });

    test('hybrid project (SPM + Podfile) passes with the Podfile block', () {
      writeSpmProject();
      write('ios/Podfile', _podfile);
      // No patrol in Podfile.lock — correct in hybrid, I5 must stay silent.
      write('ios/Podfile.lock', 'PODS:\n  - bugfender (1.0.0)\n');
      expect(idsOf(iosFindings(context())), ['I12']);
    });
  });

  group('project discovery', () {
    test('missing xcodeproj reports a single error', () {
      final findings = iosFindings(context());
      expect(findings, hasLength(1));
      expect(findings.single.id, 'I2');
      expect(findings.single.severity, Severity.error);
    });

    test('renamed project gets a notice and checks still run (#1878)', () {
      writeSpmProject(project: 'MyApp');
      final findings = iosFindings(context());
      final naming = findings.firstWhere((finding) => finding.id == 'P2');
      expect(naming.severity, Severity.notice);
      expect(naming.summary, contains('ios/MyApp.xcodeproj'));
      expect(idsOf(findings), isNot(contains('I1')));
    });

    test('stale swiftpm Package.resolved does not mis-detect SPM', () {
      // Real CocoaPods projects can carry a leftover Package.resolved (e.g.
      // old Firebase pins) without any actual Flutter SPM integration.
      writePodsProject();
      write(
        'ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/'
        'Package.resolved',
        '{"pins": []}',
      );
      expect(idsOf(iosFindings(context())), ['I12']);
    });

    test('Pods and ephemeral directories are ignored', () {
      writeSpmProject();
      write('ios/Pods/SomePod/RunnerUITestsLaunchTests.m', '');
      write('ios/Flutter/ephemeral/Generated.xcconfig', 'FLUTTER_TARGET=x');
      expect(idsOf(iosFindings(context())), ['I12']);
    });
  });

  group('I0 integration mechanism', () {
    test('errors when neither CocoaPods nor SPM is present', () {
      write('ios/Runner.xcodeproj/project.pbxproj', _pbxproj(spm: false));
      write('ios/RunnerUITests/RunnerUITests.m', _runnerUITestsM);
      final findings = iosFindings(context());
      expect(idsOf(findings), contains('I0'));
    });
  });

  group('I1 RunnerUITests.m', () {
    test('errors when the macro file is missing', () {
      writeSpmProject();
      fs.file('/project/ios/RunnerUITests/RunnerUITests.m').deleteSync();
      expect(idsOf(iosFindings(context())), contains('I1'));
    });

    test('finds the macro in a non-canonical location', () {
      writeSpmProject();
      fs.file('/project/ios/RunnerUITests/RunnerUITests.m').deleteSync();
      write('ios/UITests/PatrolTests.m', _runnerUITestsM);
      expect(idsOf(iosFindings(context())), isNot(contains('I1')));
    });
  });

  group('I2 RunnerUITests target', () {
    test('errors when the native target is missing', () {
      writeSpmProject();
      write(
        'ios/Runner.xcodeproj/project.pbxproj',
        _pbxproj(uiTestsTarget: false),
      );
      expect(idsOf(iosFindings(context())), contains('I2'));
    });
  });

  group('I3 LaunchTests file', () {
    test('warns when RunnerUITestsLaunchTests.m still exists', () {
      writeSpmProject();
      write('ios/RunnerUITests/RunnerUITestsLaunchTests.m', '@import XCTest;');
      final findings = iosFindings(context());
      final finding = findings.firstWhere((finding) => finding.id == 'I3');
      expect(finding.severity, Severity.warning);
    });
  });

  group('I4 Podfile embedding', () {
    test('errors when the Podfile lacks the RunnerUITests target', () {
      writePodsProject();
      write('ios/Podfile', "target 'Runner' do\n  use_frameworks!\nend\n");
      final finding = iosFindings(
        context(),
      ).firstWhere((finding) => finding.id == 'I4');
      expect(finding.severity, Severity.error);
      expect(finding.summary, contains('@rpath'));
    });

    test('errors in hybrid projects too', () {
      writeSpmProject();
      write('ios/Podfile', "target 'Runner' do\nend\n");
      expect(idsOf(iosFindings(context())), contains('I4'));
    });
  });

  group('I5 pods installed', () {
    test('warns when Podfile.lock is missing (pure CocoaPods)', () {
      writePodsProject();
      fs.file('/project/ios/Podfile.lock').deleteSync();
      final finding = iosFindings(
        context(),
      ).firstWhere((finding) => finding.id == 'I5');
      expect(finding.severity, Severity.warning);
    });

    test('warns when Podfile.lock does not mention patrol', () {
      writePodsProject();
      write('ios/Podfile.lock', 'PODS:\n  - Flutter (1.0.0)\n');
      expect(idsOf(iosFindings(context())), contains('I5'));
    });
  });

  group('I6 SPM linkage', () {
    test('errors when the package is not linked to RunnerUITests', () {
      // Runner links the package (SPM detected), RunnerUITests does not.
      const orphanUITests =
          '\t\tAA2 /* RunnerUITests */ = {\n'
          '\t\t\tisa = PBXNativeTarget;\n'
          '\t\t\tname = RunnerUITests;\n'
          '\t\t};\n';
      final pbxproj = _pbxproj(uiTestsTarget: false).replaceFirst(
        '\t\tBBBBBBBBBBBBBBBBBBBBBBB2 /* ShellScript */',
        '$orphanUITests\t\tBBBBBBBBBBBBBBBBBBBBBBB2 /* ShellScript */',
      );
      write('ios/Runner.xcodeproj/project.pbxproj', pbxproj);
      write('ios/RunnerUITests/RunnerUITests.m', _runnerUITestsM);
      final finding = iosFindings(
        context(),
      ).firstWhere((finding) => finding.id == 'I6');
      expect(finding.severity, Severity.error);
      expect(finding.fix, contains('Frameworks and Libraries'));
    });
  });

  group('I6 linkage via referenced Frameworks phase', () {
    test('passes with the real template layout (phase object, not target)',
        () {
      // RunnerUITests references a Frameworks phase by ID; the package
      // linkage lives in that separate PBXFrameworksBuildPhase object.
      const pbxproj = '// !\$*UTF8*\$!\n'
          '{\n'
          '\tobjects = {\n'
          '\t\tAAAAAAAAAAAAAAAAAAAAAAA1 /* Runner */ = {\n'
          '\t\t\tisa = PBXNativeTarget;\n'
          '\t\t\tname = Runner;\n'
          '\t\t\tpackageProductDependencies = (\n'
          '\t\t\t\tPPPPPPPPPPPPPPPPPPPPPPP1 /* FlutterGeneratedPluginSwiftPackage */,\n'
          '\t\t\t);\n'
          '\t\t};\n'
          '\t\tAAAAAAAAAAAAAAAAAAAAAAA2 /* RunnerUITests */ = {\n'
          '\t\t\tisa = PBXNativeTarget;\n'
          '\t\t\tbuildPhases = (\n'
          '\t\t\t\tBBBBBBBBBBBBBBBBBBBBBBB1 /* xcode_backend build */,\n'
          '\t\t\t\tFFFFFFFFFFFFFFFFFFFFFFF1 /* Frameworks */,\n'
          '\t\t\t\tBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB2 /* xcode_backend embed_and_thin */,\n'
          '\t\t\t);\n'
          '\t\t\tname = RunnerUITests;\n'
          '\t\t};\n'
          '\t\tFFFFFFFFFFFFFFFFFFFFFFF1 /* Frameworks */ = {\n'
          '\t\t\tisa = PBXFrameworksBuildPhase;\n'
          '\t\t\tfiles = (\n'
          '\t\t\t\tCCCCCCCCCCCCCCCCCCCCCCC1 /* FlutterGeneratedPluginSwiftPackage in Frameworks */,\n'
          '\t\t\t);\n'
          '\t\t};\n'
          '\t\tBBBBBBBBBBBBBBBBBBBBBBB1 /* ShellScript */ = {\n'
          '\t\t\tisa = PBXShellScriptBuildPhase;\n'
          '\t\t\tshellScript = "xcode_backend.sh build";\n'
          '\t\t};\n'
          '\t\tBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB2 /* ShellScript */ = {\n'
          '\t\t\tisa = PBXShellScriptBuildPhase;\n'
          '\t\t\tshellScript = "xcode_backend.sh embed_and_thin";\n'
          '\t\t};\n'
          '\t};\n'
          '}\n';
      write('ios/Runner.xcodeproj/project.pbxproj', pbxproj);
      write('ios/RunnerUITests/RunnerUITests.m', _runnerUITestsM);
      expect(idsOf(iosFindings(context())), isNot(contains('I6')));
    });
  });

  group('I7 xcode_backend build phases', () {
    test('errors when embed_and_thin is missing', () {
      writeSpmProject();
      final pbxproj = _pbxproj().replaceAll('embed_and_thin', 'unrelated');
      write('ios/Runner.xcodeproj/project.pbxproj', pbxproj);
      final finding = iosFindings(
        context(),
      ).firstWhere((finding) => finding.id == 'I7');
      expect(finding.severity, Severity.error);
      expect(finding.summary, contains('embed_and_thin'));
    });
  });

  group('I7 scoping to the RunnerUITests target', () {
    test('errors when the phases exist only on the Runner target', () {
      writeSpmProject();
      // Move the phase references from RunnerUITests to Runner — the phase
      // objects still exist in the file, but not on the tests target.
      const phaseRefs =
          '\t\t\tbuildPhases = (\n'
          '\t\t\t\tBBBBBBBBBBBBBBBBBBBBBBB2 /* xcode_backend build */,\n'
          '\t\t\t\tBBBBBBBBBBBBBBBBBBBBBBB3 /* xcode_backend embed_and_thin */,\n'
          '\t\t\t);\n';
      final pbxproj = _pbxproj()
          .replaceFirst(phaseRefs, '')
          .replaceFirst('\t\t\tname = Runner;\n', '$phaseRefs\t\t\tname = Runner;\n');
      write('ios/Runner.xcodeproj/project.pbxproj', pbxproj);
      final finding = iosFindings(
        context(),
      ).firstWhere((finding) => finding.id == 'I7');
      expect(finding.severity, Severity.error);
    });
  });

  group('I7 phase ordering', () {
    const buildRef =
        '\t\t\t\tBBBBBBBBBBBBBBBBBBBBBBB2 /* xcode_backend build */,\n';
    const embedRef =
        '\t\t\t\tBBBBBBBBBBBBBBBBBBBBBBB3 /* xcode_backend embed_and_thin */,\n';
    const sourcesRef = '\t\t\t\tACE0ACE0ACE0ACE0ACE0ACE1 /* Sources */,\n';
    const frameworksRef =
        '\t\t\t\tFACEFACEFACEFACEFACEFAC1 /* Frameworks */,\n';

    String pbxprojWithPhases({required bool ordered}) {
      final refs = ordered
          ? '$buildRef$sourcesRef$frameworksRef$embedRef'
          : '$sourcesRef$buildRef$embedRef$frameworksRef';
      return _pbxproj()
          .replaceFirst('$buildRef$embedRef', refs)
          .replaceFirst(
            '\t};\n}',
            '\t\tACE0ACE0ACE0ACE0ACE0ACE1 /* Sources */ = {\n'
                '\t\t\tisa = PBXSourcesBuildPhase;\n'
                '\t\t};\n'
                '\t\tFACEFACEFACEFACEFACEFAC1 /* Frameworks */ = {\n'
                '\t\t\tisa = PBXFrameworksBuildPhase;\n'
                '\t\t};\n'
                '\t};\n}',
          );
    }

    test('correct order passes and leaves ordering out of the notice', () {
      writeSpmProject();
      write(
        'ios/Runner.xcodeproj/project.pbxproj',
        pbxprojWithPhases(ordered: true),
      );
      final findings = iosFindings(context());
      expect(idsOf(findings), isNot(contains('I7')));
      final notice = findings.firstWhere((finding) => finding.id == 'I12');
      expect(notice.summary, isNot(contains('ordered as in the docs')));
    });

    test('misordered phases produce an I7 warning', () {
      writeSpmProject();
      write(
        'ios/Runner.xcodeproj/project.pbxproj',
        pbxprojWithPhases(ordered: false),
      );
      final finding = iosFindings(
        context(),
      ).firstWhere((finding) => finding.id == 'I7');
      expect(finding.severity, Severity.warning);
      expect(finding.summary, contains('wrong order'));
    });
  });

  group('I13 configuration sets', () {
    /// Appends configuration lists: Runner has [runnerConfigs], RunnerUITests
    /// has [uiTestsConfigs].
    String pbxprojWithConfigLists(
      List<String> runnerConfigs,
      List<String> uiTestsConfigs,
    ) {
      String configBlock(String id, String name) =>
          '\t\t$id /* $name */ = {\n'
          '\t\t\tisa = XCBuildConfiguration;\n'
          '\t\t\tname = "$name";\n'
          '\t\t};\n';
      String listBlock(String id, Map<String, String> configs) =>
          '\t\t$id /* Build configuration list */ = {\n'
          '\t\t\tisa = XCConfigurationList;\n'
          '\t\t\tbuildConfigurations = (\n'
          '${configs.keys.map((key) => '\t\t\t\t$key /* ${configs[key]} */,\n').join()}'
          '\t\t\t);\n'
          '\t\t};\n';

      final runnerMap = {
        for (final (index, name) in runnerConfigs.indexed)
          'ADDADDADDADDADDADDADD${index}A0': name,
      };
      final uiTestsMap = {
        for (final (index, name) in uiTestsConfigs.indexed)
          'BEDBEDBEDBEDBEDBEDBED${index}B0': name,
      };

      return _pbxproj()
          .replaceFirst(
            '\t\t\tname = Runner;\n',
            '\t\t\tname = Runner;\n'
                '\t\t\tbuildConfigurationList = CACACACACACACACACACACAC1;\n',
          )
          .replaceFirst(
            '\t\t\tname = RunnerUITests;\n',
            '\t\t\tname = RunnerUITests;\n'
                '\t\t\tbuildConfigurationList = CACACACACACACACACACACAC2;\n',
          )
          .replaceFirst(
            '\t};\n}',
            '${listBlock('CACACACACACACACACACACAC1', runnerMap)}'
                '${listBlock('CACACACACACACACACACACAC2', uiTestsMap)}'
                '${runnerMap.entries.map((entry) => configBlock(entry.key, entry.value)).join()}'
                '${uiTestsMap.entries.map((entry) => configBlock(entry.key, entry.value)).join()}'
                '\t};\n}',
          );
    }

    test('matching sets pass and leave the item out of the notice', () {
      writeSpmProject();
      write(
        'ios/Runner.xcodeproj/project.pbxproj',
        pbxprojWithConfigLists(
          ['Debug', 'Release-prod'],
          ['Debug', 'Release-prod'],
        ),
      );
      final findings = iosFindings(context());
      expect(idsOf(findings), isNot(contains('I13')));
      final notice = findings.firstWhere((finding) => finding.id == 'I12');
      expect(notice.summary, isNot(contains('Configuration Set')));
    });

    test('warns when RunnerUITests misses a Runner configuration', () {
      writeSpmProject();
      write(
        'ios/Runner.xcodeproj/project.pbxproj',
        pbxprojWithConfigLists(['Debug', 'Release-prod'], ['Debug']),
      );
      final finding = iosFindings(
        context(),
      ).firstWhere((finding) => finding.id == 'I13');
      expect(finding.severity, Severity.warning);
      expect(finding.summary, contains('Release-prod'));
    });

    test('stays a manual item when config lists cannot be isolated', () {
      writeSpmProject();
      final notice = iosFindings(
        context(),
      ).firstWhere((finding) => finding.id == 'I12');
      expect(notice.summary, contains('Configuration Set'));
    });
  });

  group('I8 user script sandboxing', () {
    test('warns on an explicit YES', () {
      writeSpmProject();
      final pbxproj = _pbxproj().replaceAll(
        'ENABLE_USER_SCRIPT_SANDBOXING = NO',
        'ENABLE_USER_SCRIPT_SANDBOXING = YES',
      );
      write('ios/Runner.xcodeproj/project.pbxproj', pbxproj);
      expect(idsOf(iosFindings(context())), contains('I8'));
    });
  });

  group('I9 deployment targets', () {
    test('warns when RunnerUITests uses a value the app never uses', () {
      writeSpmProject();
      final pbxproj = _pbxproj().replaceFirst(
        'IPHONEOS_DEPLOYMENT_TARGET = 13.0;\n'
            '\t\t\t\tTEST_TARGET_NAME = Runner;',
        'IPHONEOS_DEPLOYMENT_TARGET = 26.0;\n'
            '\t\t\t\tTEST_TARGET_NAME = Runner;',
      );
      write('ios/Runner.xcodeproj/project.pbxproj', pbxproj);
      final finding = iosFindings(
        context(),
      ).firstWhere((finding) => finding.id == 'I9');
      expect(finding.severity, Severity.warning);
      expect(finding.summary, contains('26.0'));
    });

    test('stays silent when app flavors legitimately differ', () {
      writeSpmProject();
      // App configs use 13.0 and 15.0 across flavors; UITests uses 13.0.
      final pbxproj = _pbxproj().replaceFirst(
        '\t\tC2 /* Debug */ = {\n',
        '\t\tC3 /* Release-prod */ = {\n'
            '\t\t\tisa = XCBuildConfiguration;\n'
            '\t\t\tbuildSettings = {\n'
            '\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 15.0;\n'
            '\t\t\t};\n'
            '\t\t};\n'
            '\t\tC2 /* Debug */ = {\n',
      );
      write('ios/Runner.xcodeproj/project.pbxproj', pbxproj);
      expect(idsOf(iosFindings(context())), isNot(contains('I9')));
    });
  });

  group('I10 parallel execution', () {
    test('warns when a shared scheme enables parallel testing', () {
      writeSpmProject();
      write(
        'ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme',
        '<TestableReference parallelizable = "YES"></TestableReference>',
      );
      expect(idsOf(iosFindings(context())), contains('I10'));
    });

    test('warns when an Xcode 26 test plan enables parallel testing', () {
      writeSpmProject();
      write(
        'ios/RunnerUITests.xctestplan',
        '{"testTargets": [{"parallelizable": true}]}',
      );
      expect(idsOf(iosFindings(context())), contains('I10'));
    });

    test('a non-parallel test plan makes parallelism verified', () {
      writeSpmProject();
      write('ios/RunnerUITests.xctestplan', '{"testTargets": [{}]}');
      final findings = iosFindings(context());
      expect(idsOf(findings), isNot(contains('I10')));
      final notice = findings.firstWhere((finding) => finding.id == 'I12');
      expect(notice.summary, isNot(contains('parallel execution')));
    });
  });

  group('I8/I12 sandboxing default', () {
    test('an absent setting is silent — xcodebuild defaults to NO', () {
      writeSpmProject();
      write(
        'ios/Runner.xcodeproj/project.pbxproj',
        _pbxproj().replaceFirst(
          '\t\t\t\tENABLE_USER_SCRIPT_SANDBOXING = NO;\n',
          '',
        ),
      );
      final findings = iosFindings(context());
      expect(idsOf(findings), isNot(contains('I8')));
      final notice = findings.firstWhere((finding) => finding.id == 'I12');
      expect(notice.summary, isNot(contains('User Script Sandboxing')));
    });
  });

  group('I11 stray FLUTTER_TARGET', () {
    test('warns when a committed xcconfig hardcodes FLUTTER_TARGET', () {
      writeSpmProject();
      write('ios/Flutter/Debug.xcconfig', 'FLUTTER_TARGET=lib/main.dart\n');
      final finding = iosFindings(
        context(),
      ).firstWhere((finding) => finding.id == 'I11');
      expect(finding.severity, Severity.warning);
      expect(finding.summary, contains('Debug.xcconfig'));
    });

    test('ignores the generated Generated.xcconfig', () {
      writeSpmProject();
      write('ios/Flutter/Generated.xcconfig', 'FLUTTER_TARGET=lib/main.dart\n');
      expect(idsOf(iosFindings(context())), isNot(contains('I11')));
    });
  });

  group('I12 manual-verify notice', () {
    test('mentions unverifiable items and adapts to project state', () {
      writeSpmProject();
      final finding = iosFindings(
        context(),
      ).firstWhere((finding) => finding.id == 'I12');
      expect(finding.severity, Severity.notice);
      expect(finding.summary, contains('Configuration Set'));
      // The fixture has no Sources/Frameworks phases, so ordering is not
      // checkable and stays a manual item.
      expect(finding.summary, contains('ordered as in the docs'));
      // Sandboxing is set in the fixture, so it must not be listed.
      expect(finding.summary, isNot(contains('User Script Sandboxing')));
      // No shared schemes in the fixture, so parallelism goes manual.
      expect(finding.summary, contains('parallel execution'));
    });
  });
}
