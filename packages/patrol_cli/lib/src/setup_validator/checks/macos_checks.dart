import 'package:patrol_cli/src/setup_validator/checks/darwin_common.dart';
import 'package:patrol_cli/src/setup_validator/checks/shared_checks.dart';
import 'package:patrol_cli/src/setup_validator/finding.dart';

const _entitlementsFiles = [
  'DebugProfile.entitlements',
  'Release.entitlements',
];

/// macOS project state shared by checks M0-M8. Mirrors the iOS context; the
/// docs describe a CocoaPods setup, but SPM evidence is honored the same way.
class MacOSCheckContext extends DarwinCheckContext {
  MacOSCheckContext({required super.probe}) : super(platformDir: 'macos');
}

/// Runs all macOS checks in catalog order.
List<Finding> macosFindings(MacOSCheckContext ctx) {
  if (ctx.xcodeprojDir == null) {
    return [
      const Finding(
        id: 'M2',
        severity: Severity.error,
        summary:
            'No Xcode project (macos/*.xcodeproj with project.pbxproj) '
            'found, so the macOS setup could not be verified.',
        fix: 'Make sure the Flutter project has a macos/ Xcode project.',
        docsUrl: '$docsBaseUrl#macos-setup',
      ),
    ];
  }

  return [
    checkMacosProjectNaming(ctx),
    checkMacosIntegrationMechanism(ctx),
    checkMacosRunnerUITestsFile(ctx),
    checkMacosRunnerUITestsTarget(ctx),
    checkMacosEmbedding(ctx),
    checkMacosAssembleBuildPhases(ctx),
    checkRunnerEntitlements(ctx),
    checkUITestsEntitlementsCopied(ctx),
    checkCodeSignEntitlements(ctx),
    checkMacosUserScriptSandboxing(ctx),
    checkMacosDeploymentTargets(ctx),
    checkMacosParallelExecution(ctx),
    checkMacosLaunchTestsFileDeleted(ctx),
    macosManualVerificationNotice(ctx),
  ].nonNulls.toList();
}

/// P2: non-standard project name — same rule as on iOS (issue #1878).
Finding? checkMacosProjectNaming(MacOSCheckContext ctx) {
  if (ctx.xcodeprojDir == 'macos/Runner.xcodeproj') {
    return null;
  }
  return Finding(
    id: 'P2',
    severity: Severity.notice,
    summary:
        'Xcode project is ${ctx.xcodeprojDir}, not the standard '
        'macos/Runner.xcodeproj. Validation adapts, but other patrol_cli '
        'commands still assume the name `Runner` '
        '(github.com/leancodepl/patrol/issues/1878).',
  );
}

/// M0: at least one plugin-integration mechanism exists.
Finding? checkMacosIntegrationMechanism(MacOSCheckContext ctx) {
  if (ctx.podfileExists || ctx.spmDetected) {
    return null;
  }
  return const Finding(
    id: 'M0',
    severity: Severity.error,
    summary:
        'Neither CocoaPods (macos/Podfile) nor Swift Package Manager '
        '(FlutterGeneratedPluginSwiftPackage) integration was found.',
    fix:
        'Set up plugin integration: keep the default Podfile, or migrate to '
        'SPM following the Flutter docs.',
    docsUrl: '$docsBaseUrl#macos-setup',
  );
}

/// M1: RunnerUITests.m with the macOS Patrol runner macro exists.
Finding? checkMacosRunnerUITestsFile(MacOSCheckContext ctx) {
  const macro = 'PATROL_INTEGRATION_TEST_MACOS_RUNNER';

  final canonical = ctx.probe.readFile('macos/RunnerUITests/RunnerUITests.m');
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
    id: 'M1',
    severity: Severity.error,
    summary: 'No RunnerUITests.m with the $macro macro found under macos/.',
    fix:
        'Create the RunnerUITests UI Testing Bundle target and replace '
        'RunnerUITests.m contents with the snippet from the docs.',
    docsUrl: '$docsBaseUrl#macos-setup-configure-runner-uitests',
  );
}

/// M2: the RunnerUITests native target exists in the Xcode project.
Finding? checkMacosRunnerUITestsTarget(MacOSCheckContext ctx) {
  final hasTarget = RegExp(
    r'/\* RunnerUITests \*/ = \{\s*isa = PBXNativeTarget',
  ).hasMatch(ctx.pbxproj!);
  if (hasTarget) {
    return null;
  }
  return Finding(
    id: 'M2',
    severity: Severity.error,
    summary:
        'No `RunnerUITests` target found in ${ctx.xcodeprojDir}. Without it '
        'there is nothing for Patrol to run on macOS.',
    fix:
        'In Xcode: File > New > Target... > UI Testing Bundle, product name '
        '`RunnerUITests`, target to be tested `Runner`, language Objective-C.',
    docsUrl: '$docsBaseUrl#macos-setup-create-test-target',
  );
}

/// M3: RunnerUITests is embedded in the plugin-integration mechanism —
/// the Podfile block when CocoaPods is present, the SPM linkage otherwise.
Finding? checkMacosEmbedding(MacOSCheckContext ctx) {
  if (ctx.podfileExists) {
    final podfile = ctx.probe.readFile('macos/Podfile') ?? '';
    final hasTarget = RegExp(
      r'''target\s+['"]RunnerUITests['"]''',
    ).hasMatch(podfile);
    if (hasTarget && podfile.contains('inherit! :complete')) {
      return null;
    }
    return const Finding(
      id: 'M3',
      severity: Severity.error,
      summary:
          'macos/Podfile does not embed RunnerUITests with '
          '`inherit! :complete`.',
      fix:
          "Inside the existing `target 'Runner'` block, nest: "
          "`target 'RunnerUITests' do inherit! :complete end`, then run "
          '`pod install --repo-update` in macos/.',
      docsUrl: '$docsBaseUrl#macos-setup-configure-runner-uitests',
    );
  }

  if (ctx.spmDetected) {
    final linked = ctx.spmLinkedToRunnerUITests;
    if (linked == null || linked) {
      return null;
    }
    return const Finding(
      id: 'M3',
      severity: Severity.error,
      summary:
          'FlutterGeneratedPluginSwiftPackage is not linked to the '
          'RunnerUITests target (SPM integration detected).',
      fix:
          'In Xcode go to RunnerUITests > General > Frameworks and '
          'Libraries, click +, and select FlutterGeneratedPluginSwiftPackage.',
      docsUrl: '$docsBaseUrl#macos-setup-configure-runner-uitests',
    );
  }

  return null; // M0 already reported the missing mechanism.
}

final _macosAssembleBuildScript = RegExp(
  r'macos_assemble\.sh[\\"' "'" r']*\s+build',
);
final _macosAssembleEmbedScript = RegExp(
  r'macos_assemble\.sh[\\"' "'" r']*\s+embed',
);

/// M4: the two macos_assemble Run Script build phases exist on the
/// RunnerUITests target and are ordered as in the docs. Scoped to that
/// target's referenced phases — the standard Runner target has its own
/// macos_assemble phases, so a global probe would always pass.
Finding? checkMacosAssembleBuildPhases(MacOSCheckContext ctx) {
  final scripts = ctx.runnerUITestsScriptPhases;
  if (scripts == null) {
    // M2 reports the missing target.
    return null;
  }
  final hasBuild = scripts.any(_macosAssembleBuildScript.hasMatch);
  final hasEmbed = scripts.any(_macosAssembleEmbedScript.hasMatch);
  if (hasBuild && hasEmbed) {
    final ordered = ctx.scriptPhasesOrdered(
      buildScript: _macosAssembleBuildScript,
      embedScript: _macosAssembleEmbedScript,
    );
    if (ordered == false) {
      return const Finding(
        id: 'M4',
        severity: Severity.warning,
        summary:
            'The macos_assemble Run Script phases of RunnerUITests are in '
            'the wrong order: `macos_assemble build` must run before Compile '
            'Sources and `macos_assemble embed` after Frameworks.',
        fix:
            'Drag the Build Phases into the order shown in the docs '
            'screenshot.',
        docsUrl: '$docsBaseUrl#macos-setup-order-build-phases',
      );
    }
    return null;
  }
  final missing = [
    if (!hasBuild) '`macos_assemble build`',
    if (!hasEmbed) '`macos_assemble embed`',
  ].join(' and ');
  return Finding(
    id: 'M4',
    severity: Severity.error,
    summary:
        'Missing $missing Run Script build phase(s) in the RunnerUITests '
        'target.',
    fix:
        'Add the two Run Script phases calling '
        r'"$FLUTTER_ROOT/packages/flutter_tools/bin/macos_assemble.sh" with '
        '`build` and `embed`, ordered as shown in the docs.',
    docsUrl: '$docsBaseUrl#macos-setup-add-build-phases',
  );
}

bool _plistBoolTrue(String plist, String key) => RegExp(
  '<key>${RegExp.escape(key)}</key>\\s*<true\\s*/>',
).hasMatch(plist);

/// M5: with App Sandbox enabled, the Runner entitlements must allow network
/// client and server connections — Patrol's test server needs them. Files
/// without the sandbox key (sandbox off) have nothing to restrict.
Finding? checkRunnerEntitlements(MacOSCheckContext ctx) {
  for (final name in _entitlementsFiles) {
    final path = 'macos/Runner/$name';
    final contents = ctx.probe.readFile(path);
    if (contents == null) {
      continue;
    }
    if (!_plistBoolTrue(contents, 'com.apple.security.app-sandbox')) {
      continue;
    }
    final missing = [
      if (!_plistBoolTrue(contents, 'com.apple.security.network.client'))
        'Outgoing Connections (Client)',
      if (!_plistBoolTrue(contents, 'com.apple.security.network.server'))
        'Incoming Connections (Server)',
    ];
    if (missing.isNotEmpty) {
      return Finding(
        id: 'M5',
        severity: Severity.error,
        summary: '$path does not allow: ${missing.join(', ')}.',
        fix:
            'In Xcode go to Runner > Signing & Capabilities and check both '
            'network checkboxes in all App Sandbox sections.',
        docsUrl: '$docsBaseUrl#macos-setup-enable-app-sandbox-connections',
      );
    }
  }
  return null;
}

/// M6: the entitlements files are copied to macos/RunnerUITests/.
Finding? checkUITestsEntitlementsCopied(MacOSCheckContext ctx) {
  final missing = _entitlementsFiles
      .where((name) => !ctx.probe.fileExists('macos/RunnerUITests/$name'))
      .toList();
  if (missing.isEmpty) {
    return null;
  }
  return Finding(
    id: 'M6',
    severity: Severity.error,
    summary:
        'Missing in macos/RunnerUITests/: ${missing.join(', ')}.',
    fix:
        'Copy DebugProfile.entitlements and Release.entitlements from '
        'macos/Runner/ to macos/RunnerUITests/.',
    docsUrl: '$docsBaseUrl#macos-setup-copy-entitlements',
  );
}

/// M7: CODE_SIGN_ENTITLEMENTS points at the copied RunnerUITests files.
Finding? checkCodeSignEntitlements(MacOSCheckContext ctx) {
  final configured = RegExp(
    'CODE_SIGN_ENTITLEMENTS = "?RunnerUITests/',
  ).hasMatch(ctx.pbxproj!);
  if (configured) {
    return null;
  }
  return const Finding(
    id: 'M7',
    severity: Severity.warning,
    summary:
        'CODE_SIGN_ENTITLEMENTS does not point at RunnerUITests/ '
        'entitlements files.',
    fix:
        'In RunnerUITests Build Settings set Code Signing Entitlements to '
        'RunnerUITests/DebugProfile.entitlements (Debug/Profile) and '
        'RunnerUITests/Release.entitlements (Release).',
    docsUrl: '$docsBaseUrl#macos-setup-set-signing-entitlements',
  );
}

/// M8: User Script Sandboxing must be off (same rule as iOS).
Finding? checkMacosUserScriptSandboxing(MacOSCheckContext ctx) {
  if (!ctx.pbxproj!.contains('ENABLE_USER_SCRIPT_SANDBOXING = YES')) {
    return null;
  }
  return const Finding(
    id: 'M8',
    severity: Severity.warning,
    summary: 'ENABLE_USER_SCRIPT_SANDBOXING is set to YES in the project.',
    fix:
        'Set User Script Sandboxing to No in Build Settings for the '
        'RunnerUITests (and Runner) targets.',
    docsUrl: '$docsBaseUrl#macos-setup-disable-script-sandboxing',
  );
}

/// M8: the RunnerUITests deployment target should match Runner's — same
/// flavor-aware rule as iOS I9.
Finding? checkMacosDeploymentTargets(MacOSCheckContext ctx) {
  final targets = ctx.deploymentTargets('MACOSX_DEPLOYMENT_TARGET');
  if (targets.uiTests.isEmpty ||
      targets.app.isEmpty ||
      targets.app.containsAll(targets.uiTests)) {
    return null;
  }
  return Finding(
    id: 'M8',
    severity: Severity.warning,
    summary:
        'RunnerUITests uses macOS deployment target '
        '${(targets.uiTests.toList()..sort()).join(', ')}, but the app '
        'targets use ${(targets.app.toList()..sort()).join(', ')}. '
        'RunnerUITests must match Runner.',
    fix:
        'Align the macOS Deployment Target of RunnerUITests with Runner in '
        'Build Settings.',
    docsUrl: '$docsBaseUrl#macos-setup-set-min-macos-version',
  );
}

/// M8: parallel execution breaks Patrol; checkable only in shared schemes.
Finding? checkMacosParallelExecution(MacOSCheckContext ctx) {
  final schemes = ctx.files.where((path) => path.endsWith('.xcscheme'));
  for (final path in schemes) {
    final contents = ctx.probe.readFile(path) ?? '';
    if (RegExp(r'parallelizable\s*=\s*"YES"').hasMatch(contents)) {
      return Finding(
        id: 'M8',
        severity: Severity.warning,
        summary:
            'Scheme $path has parallel test execution enabled, which breaks '
            'Patrol.',
        fix: 'Disable parallel execution for all schemes.',
        docsUrl: '$docsBaseUrl#macos-setup-disable-parallel-execution',
      );
    }
  }
  return null;
}

/// M8: the auto-generated RunnerUITestsLaunchTests.m should be deleted.
Finding? checkMacosLaunchTestsFileDeleted(MacOSCheckContext ctx) {
  final present = ctx.files.any(
    (path) => path.endsWith('RunnerUITestsLaunchTests.m'),
  );
  if (!present) {
    return null;
  }
  return const Finding(
    id: 'M8',
    severity: Severity.warning,
    summary:
        'macos RunnerUITestsLaunchTests.m still exists — the docs say to '
        'delete it.',
    fix: 'Delete it through Xcode (right click > Move to Trash).',
    docsUrl: '$docsBaseUrl#macos-setup-delete-launch-tests',
  );
}

/// M8: steps that cannot be verified from files, one compact notice.
Finding? macosManualVerificationNotice(MacOSCheckContext ctx) {
  final hasSharedSchemes = ctx.files.any((path) => path.endsWith('.xcscheme'));
  final sandboxingKnown = ctx.pbxproj!.contains(
    'ENABLE_USER_SCRIPT_SANDBOXING',
  );
  final orderCheckable =
      ctx.scriptPhasesOrdered(
        buildScript: _macosAssembleBuildScript,
        embedScript: _macosAssembleEmbedScript,
      ) !=
      null;

  final items = [
    'RunnerUITests uses the same Configuration Set as Runner',
    if (!orderCheckable)
      'the two macos_assemble Build Phases are ordered as in the docs',
    if (!sandboxingKnown) 'User Script Sandboxing is set to No',
    if (!hasSharedSchemes)
      'parallel execution is disabled for all schemes (no shared schemes to verify)',
  ];

  return Finding(
    id: 'M8',
    severity: Severity.notice,
    summary: 'Verify manually in Xcode: ${items.join('; ')}.',
    docsUrl: '$docsBaseUrl#macos-setup',
  );
}
