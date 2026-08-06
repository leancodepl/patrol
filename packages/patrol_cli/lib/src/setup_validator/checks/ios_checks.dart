import 'package:patrol_cli/src/setup_validator/checks/darwin_common.dart';
import 'package:patrol_cli/src/setup_validator/checks/shared_checks.dart';
import 'package:patrol_cli/src/setup_validator/finding.dart';

const faqDocsUrl = 'https://patrol.leancode.co/documentation#faq';
const physicalIosDocsUrl =
    'https://patrol.leancode.co/documentation/physical-ios-devices-setup';

/// iOS project state shared by checks I0-I12.
class IOSCheckContext extends DarwinCheckContext {
  IOSCheckContext({required super.probe}) : super(platformDir: 'ios');
}

/// Runs all iOS checks in catalog order.
List<Finding> iosFindings(IOSCheckContext ctx) {
  if (ctx.xcodeprojDir == null) {
    return [
      const Finding(
        id: 'I2',
        severity: Severity.error,
        summary:
            'No Xcode project (ios/*.xcodeproj with project.pbxproj) found, '
            'so the iOS setup could not be verified.',
        fix: 'Make sure the Flutter project has an ios/ Xcode project.',
        docsUrl: '$docsBaseUrl#ios-setup',
      ),
    ];
  }

  return [
    checkProjectNaming(ctx),
    checkIntegrationMechanism(ctx),
    checkRunnerUITestsFile(ctx),
    checkRunnerUITestsTarget(ctx),
    checkLaunchTestsFileDeleted(ctx),
    checkPodfileUITestsTarget(ctx),
    checkPodsInstalled(ctx),
    checkSpmLinkage(ctx),
    checkXcodeBackendBuildPhases(ctx),
    checkUserScriptSandboxing(ctx),
    checkDeploymentTargets(ctx),
    checkParallelExecution(ctx),
    checkStrayFlutterTarget(ctx),
    manualVerificationNotice(ctx),
  ].nonNulls.toList();
}

/// P2: the Xcode project is not named Runner — file checks adapt, but other
/// parts of the CLI still assume the standard name (issue #1878).
Finding? checkProjectNaming(IOSCheckContext ctx) {
  if (ctx.xcodeprojDir == 'ios/Runner.xcodeproj') {
    return null;
  }
  return Finding(
    id: 'P2',
    severity: Severity.notice,
    summary:
        'Xcode project is ${ctx.xcodeprojDir}, not the standard '
        'ios/Runner.xcodeproj. Validation adapts, but other patrol_cli '
        'commands still assume the name `Runner` '
        '(github.com/leancodepl/patrol/issues/1878).',
  );
}

/// I0: at least one plugin-integration mechanism (CocoaPods or SPM) exists.
Finding? checkIntegrationMechanism(IOSCheckContext ctx) {
  if (ctx.podfileExists || ctx.spmDetected) {
    return null;
  }
  return const Finding(
    id: 'I0',
    severity: Severity.error,
    summary:
        'Neither CocoaPods (ios/Podfile) nor Swift Package Manager '
        '(FlutterGeneratedPluginSwiftPackage) integration was found.',
    fix:
        'Set up plugin integration: keep the default Podfile, or migrate to '
        'SPM following the Flutter docs.',
    docsUrl: '$docsBaseUrl#ios-setup',
  );
}

/// I1: RunnerUITests.m with the Patrol runner macro exists.
Finding? checkRunnerUITestsFile(IOSCheckContext ctx) {
  const macro = 'PATROL_INTEGRATION_TEST_IOS_RUNNER';

  final canonical = ctx.probe.readFile('ios/RunnerUITests/RunnerUITests.m');
  if (canonical?.contains(macro) ?? false) {
    return null;
  }

  final anyMatch = ctx.files
      .where((path) => path.endsWith('.m'))
      .any((path) => ctx.probe.readFile(path)?.contains(macro) ?? false);
  if (anyMatch) {
    return null;
  }

  return const Finding(
    id: 'I1',
    severity: Severity.error,
    summary:
        'No RunnerUITests.m with the $macro macro found under ios/.',
    fix:
        'Create the RunnerUITests UI Testing Bundle target and replace '
        'RunnerUITests.m contents with the snippet from the docs.',
    docsUrl: '$docsBaseUrl#ios-setup-configure-runner-uitests',
  );
}

/// I2: the RunnerUITests native target exists in the Xcode project.
Finding? checkRunnerUITestsTarget(IOSCheckContext ctx) {
  final contents = ctx.pbxproj!;
  final hasTarget = RegExp(
    r'/\* RunnerUITests \*/ = \{\s*isa = PBXNativeTarget',
  ).hasMatch(contents);
  if (hasTarget) {
    return null;
  }
  return Finding(
    id: 'I2',
    severity: Severity.error,
    summary:
        'No `RunnerUITests` target found in ${ctx.xcodeprojDir}. Without it '
        'there is nothing for Patrol to run on iOS.',
    fix:
        'In Xcode: File > New > Target... > UI Testing Bundle, product name '
        '`RunnerUITests`, target to be tested `Runner`, language Objective-C.',
    docsUrl: '$docsBaseUrl#ios-setup-create-test-target',
  );
}

/// I3: the auto-generated RunnerUITestsLaunchTests.m should be deleted.
Finding? checkLaunchTestsFileDeleted(IOSCheckContext ctx) {
  final present = ctx.files.any(
    (path) => path.endsWith('RunnerUITestsLaunchTests.m'),
  );
  if (!present) {
    return null;
  }
  return const Finding(
    id: 'I3',
    severity: Severity.warning,
    summary:
        'RunnerUITestsLaunchTests.m still exists — the docs say to delete it.',
    fix: 'Delete it through Xcode (right click > Move to Trash).',
    docsUrl: '$docsBaseUrl#ios-setup-delete-launch-tests',
  );
}

/// I4: with CocoaPods present, the Podfile embeds RunnerUITests with
/// `inherit! :complete`. Error also in hybrid projects — the known-good
/// hybrid template config includes this block.
Finding? checkPodfileUITestsTarget(IOSCheckContext ctx) {
  if (!ctx.podfileExists) {
    return null;
  }
  final podfile = ctx.probe.readFile('ios/Podfile') ?? '';
  final hasTarget = RegExp(
    r'''target\s+['"]RunnerUITests['"]''',
  ).hasMatch(podfile);
  if (hasTarget && podfile.contains('inherit! :complete')) {
    return null;
  }
  return const Finding(
    id: 'I4',
    severity: Severity.error,
    summary:
        'ios/Podfile does not embed RunnerUITests with `inherit! :complete`. '
        'A typical symptom is the app failing to start with '
        '`Library not loaded: @rpath/...` '
        '(github.com/leancodepl/patrol/issues/2307).',
    fix:
        "Inside the existing `target 'Runner'` block, nest: "
        "`target 'RunnerUITests' do inherit! :complete end`, then run "
        '`pod install --repo-update`.',
    docsUrl: '$docsBaseUrl#ios-setup-configure-runner-uitests',
  );
}

/// I5: pure-CocoaPods projects should have patrol in Podfile.lock. Skipped in
/// hybrid — patrol correctly resolves via SPM there.
Finding? checkPodsInstalled(IOSCheckContext ctx) {
  if (!ctx.podfileExists || ctx.spmDetected) {
    return null;
  }
  final lock = ctx.probe.readFile('ios/Podfile.lock');
  if (lock == null) {
    return const Finding(
      id: 'I5',
      severity: Severity.warning,
      summary: 'ios/Podfile.lock not found — pods look uninstalled.',
      fix: 'Run `pod install --repo-update` in the ios/ directory.',
      docsUrl: '$docsBaseUrl#ios-setup-pod-install',
    );
  }
  if (lock.contains('patrol')) {
    return null;
  }
  return const Finding(
    id: 'I5',
    severity: Severity.warning,
    summary: 'ios/Podfile.lock does not mention patrol — pods look stale.',
    fix: 'Run `pod install --repo-update` in the ios/ directory.',
    docsUrl: '$docsBaseUrl#ios-setup-pod-install',
  );
}

/// I6: with SPM detected, FlutterGeneratedPluginSwiftPackage must be linked
/// to the RunnerUITests target, not only to Runner.
Finding? checkSpmLinkage(IOSCheckContext ctx) {
  if (!ctx.spmDetected) {
    return null;
  }
  final linked = ctx.spmLinkedToRunnerUITests;
  if (linked == null) {
    // No isolatable target block: I2 reports the missing target; formatting
    // surprises are not worth a false Error.
    return null;
  }
  if (linked) {
    return null;
  }
  return const Finding(
    id: 'I6',
    severity: Severity.error,
    summary:
        'FlutterGeneratedPluginSwiftPackage is not linked to the '
        'RunnerUITests target (SPM integration detected).',
    fix:
        'In Xcode go to RunnerUITests > General > Frameworks and Libraries, '
        'click +, and select FlutterGeneratedPluginSwiftPackage.',
    docsUrl: '$docsBaseUrl#ios-setup-configure-runner-uitests',
  );
}

final _xcodeBackendBuildScript = RegExp(
  r'xcode_backend\.sh[\\"' "'" r']*\s+build',
);
final _xcodeBackendEmbedScript = RegExp('embed_and_thin');

/// I7: the two xcode_backend Run Script build phases exist on the
/// RunnerUITests target and are ordered as in the docs (build before Compile
/// Sources, embed_and_thin after Frameworks). Scoped to that target's
/// referenced phases — the standard Runner target has its own xcode_backend
/// phases, so a global probe would always pass.
Finding? checkXcodeBackendBuildPhases(IOSCheckContext ctx) {
  final scripts = ctx.runnerUITestsScriptPhases;
  if (scripts == null) {
    // I2 reports the missing target.
    return null;
  }
  final hasBuild = scripts.any(_xcodeBackendBuildScript.hasMatch);
  final hasEmbed = scripts.any(_xcodeBackendEmbedScript.hasMatch);
  if (hasBuild && hasEmbed) {
    final ordered = ctx.scriptPhasesOrdered(
      buildScript: _xcodeBackendBuildScript,
      embedScript: _xcodeBackendEmbedScript,
    );
    if (ordered == false) {
      return const Finding(
        id: 'I7',
        severity: Severity.warning,
        summary:
            'The xcode_backend Run Script phases of RunnerUITests are in the '
            'wrong order: `xcode_backend build` must run before Compile '
            'Sources and `xcode_backend embed_and_thin` after Frameworks.',
        fix:
            'Drag the Build Phases into the order shown in the docs '
            'screenshot.',
        docsUrl: '$docsBaseUrl#ios-setup-order-build-phases',
      );
    }
    return null;
  }
  final missing = [
    if (!hasBuild) '`xcode_backend build`',
    if (!hasEmbed) '`xcode_backend embed_and_thin`',
  ].join(' and ');
  return Finding(
    id: 'I7',
    severity: Severity.error,
    summary:
        'Missing $missing Run Script build phase(s) in the RunnerUITests '
        'target.',
    fix:
        'Add the two Run Script phases calling '
        r'"$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh" with '
        '`build` and `embed_and_thin`, ordered as shown in the docs.',
    docsUrl: '$docsBaseUrl#ios-setup-add-build-phases',
  );
}

/// I8: User Script Sandboxing must be off, or the script phases cannot run.
Finding? checkUserScriptSandboxing(IOSCheckContext ctx) {
  if (!ctx.pbxproj!.contains('ENABLE_USER_SCRIPT_SANDBOXING = YES')) {
    return null;
  }
  return const Finding(
    id: 'I8',
    severity: Severity.warning,
    summary: 'ENABLE_USER_SCRIPT_SANDBOXING is set to YES in the project.',
    fix:
        'Set User Script Sandboxing to No in Build Settings for the '
        'RunnerUITests (and Runner) targets.',
    docsUrl: '$docsBaseUrl#ios-setup-disable-script-sandboxing',
  );
}

/// I9: the RunnerUITests deployment target should match Runner's. Apps
/// legitimately vary the value across flavors, so only a UITests value the
/// app never uses is reported.
Finding? checkDeploymentTargets(IOSCheckContext ctx) {
  final targets = ctx.deploymentTargets('IPHONEOS_DEPLOYMENT_TARGET');
  if (targets.uiTests.isEmpty ||
      targets.app.isEmpty ||
      targets.app.containsAll(targets.uiTests)) {
    return null;
  }
  return Finding(
    id: 'I9',
    severity: Severity.warning,
    summary:
        'RunnerUITests uses iOS deployment target '
        '${(targets.uiTests.toList()..sort()).join(', ')}, but the app '
        'targets use ${(targets.app.toList()..sort()).join(', ')}. '
        'RunnerUITests must match Runner.',
    fix:
        'Align the iOS Deployment Target of RunnerUITests with Runner in '
        'Build Settings.',
    docsUrl: '$docsBaseUrl#ios-setup-set-min-ios-version',
  );
}

/// I10: parallel execution breaks Patrol; checkable only in shared schemes.
Finding? checkParallelExecution(IOSCheckContext ctx) {
  final schemes = ctx.files.where((path) => path.endsWith('.xcscheme'));
  for (final path in schemes) {
    final contents = ctx.probe.readFile(path) ?? '';
    if (RegExp(r'parallelizable\s*=\s*"YES"').hasMatch(contents)) {
      return Finding(
        id: 'I10',
        severity: Severity.warning,
        summary:
            'Scheme $path has parallel test execution enabled, which breaks '
            'Patrol (the simulator gets cloned).',
        fix: 'Disable parallel execution for all schemes.',
        docsUrl: '$docsBaseUrl#ios-setup-disable-parallel-execution',
      );
    }
  }
  return null;
}

/// I11: a committed FLUTTER_TARGET override is a known cause of "wrong app
/// opens" / "waits for idle forever" (docs FAQ). The generated
/// Flutter/Generated.xcconfig legitimately contains it and is skipped.
Finding? checkStrayFlutterTarget(IOSCheckContext ctx) {
  final offenders = <String>[
    for (final path in ctx.files)
      if (path.endsWith('.xcconfig') &&
          !path.endsWith('Generated.xcconfig') &&
          (ctx.probe.readFile(path)?.contains('FLUTTER_TARGET') ?? false))
        path,
    if (ctx.pbxproj!.contains('FLUTTER_TARGET')) '${ctx.xcodeprojDir}',
  ];
  if (offenders.isEmpty) {
    return null;
  }
  return Finding(
    id: 'I11',
    severity: Severity.warning,
    summary:
        'FLUTTER_TARGET is hardcoded in: ${offenders.join(', ')}. This makes '
        'test runs open the plain app or hang on "Wait ... to idle".',
    fix:
        'Remove FLUTTER_TARGET (key and value) from *.xcconfig and pbxproj, '
        'then run `flutter build ios --config-only <your test>` to '
        'regenerate it.',
    docsUrl: '$docsBaseUrl#faq-test-stops-wait-for-idle',
  );
}

/// I12: steps that cannot be verified from files, kept to one compact notice.
Finding? manualVerificationNotice(IOSCheckContext ctx) {
  final hasSharedSchemes = ctx.files.any(
    (path) => path.endsWith('.xcscheme'),
  );
  final sandboxingKnown = ctx.pbxproj!.contains(
    'ENABLE_USER_SCRIPT_SANDBOXING',
  );
  final orderCheckable =
      ctx.scriptPhasesOrdered(
        buildScript: _xcodeBackendBuildScript,
        embedScript: _xcodeBackendEmbedScript,
      ) !=
      null;

  final items = [
    'RunnerUITests uses the same Configuration Set as Runner',
    if (!orderCheckable)
      'the two xcode_backend Build Phases are ordered as in the docs',
    if (!sandboxingKnown) 'User Script Sandboxing is set to No',
    if (!hasSharedSchemes)
      'parallel execution is disabled for all schemes (no shared schemes to verify)',
    'for physical devices, see $physicalIosDocsUrl',
  ];

  return Finding(
    id: 'I12',
    severity: Severity.notice,
    summary: 'Verify manually in Xcode: ${items.join('; ')}.',
    docsUrl: '$docsBaseUrl#ios-setup',
  );
}
