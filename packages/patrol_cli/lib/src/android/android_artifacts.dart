import 'dart:convert';

import 'package:file/file.dart';
import 'package:patrol_cli/src/android/android_test_layout.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';

class AndroidArtifact {
  const AndroidArtifact({required this.apk, required this.applicationId});

  final File apk;
  final String applicationId;
}

/// Resolves built Android artifacts from AGP's output metadata.
class AndroidArtifactResolver {
  const AndroidArtifactResolver(this.rootDirectory);

  final Directory rootDirectory;

  AndroidArtifact app({required BuildMode buildMode, required String? flavor}) {
    return _resolve(
      metadataRoots: _apkOutputRoots('app'),
      expectedVariant: _variantName(buildMode, flavor),
    );
  }

  AndroidArtifact test({
    required AndroidTestLayout layout,
    required BuildMode buildMode,
    required String? flavor,
  }) {
    final selfInstrumenting = layout == AndroidTestLayout.selfInstrumenting;
    final roots = [
      for (final root in _apkOutputRoots(
        selfInstrumenting ? 'patrolTest' : 'app',
      ))
        if (selfInstrumenting) root else root.childDirectory('androidTest'),
    ];
    return _resolve(
      metadataRoots: roots,
      expectedVariant:
          '${_variantName(buildMode, flavor)}'
          '${selfInstrumenting ? '' : 'AndroidTest'}',
    );
  }

  /// Flutter's usual `rootProject.buildDir = '../build'` puts some outputs
  /// under `<flutterRoot>/build/<project>/`. Gradle 8 / newer AGP still write
  /// `outputs/apk` next to the module at `android/<project>/build/`.
  List<Directory> _apkOutputRoots(String project) {
    return [
      rootDirectory
          .childDirectory('build')
          .childDirectory(project)
          .childDirectory('outputs')
          .childDirectory('apk'),
      rootDirectory
          .childDirectory('android')
          .childDirectory(project)
          .childDirectory('build')
          .childDirectory('outputs')
          .childDirectory('apk'),
    ];
  }

  AndroidArtifact _resolve({
    required List<Directory> metadataRoots,
    required String expectedVariant,
  }) {
    final existing = [
      for (final root in metadataRoots)
        if (root.existsSync()) root,
    ];
    if (existing.isEmpty) {
      throwToolExit(
        'No Android APK outputs found under '
        '${metadataRoots.map((root) => root.path).join(' or ')}. '
        'Build the requested variant first.',
      );
    }

    for (final metadataRoot in existing) {
      final artifact = _resolveIn(metadataRoot, expectedVariant);
      if (artifact != null) {
        return artifact;
      }
    }

    throwToolExit(
      'Could not resolve Android APK for variant $expectedVariant under '
      '${existing.map((root) => root.path).join(' or ')}. '
      'Build that variant first.',
    );
  }

  AndroidArtifact? _resolveIn(Directory metadataRoot, String expectedVariant) {
    final metadataFiles =
        metadataRoot
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.basename == 'output-metadata.json')
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));

    for (final metadataFile in metadataFiles) {
      try {
        final metadata =
            jsonDecode(metadataFile.readAsStringSync()) as Map<String, dynamic>;
        final variantName = metadata['variantName'] as String?;
        if (variantName?.toLowerCase() != expectedVariant.toLowerCase()) {
          continue;
        }
        final applicationId = metadata['applicationId'] as String?;
        final elements = metadata['elements'] as List<dynamic>?;
        if (applicationId == null ||
            applicationId.isEmpty ||
            elements == null) {
          continue;
        }
        final outputs = elements
            .whereType<Map<String, dynamic>>()
            .where((element) {
              final filters = element['filters'] as List<dynamic>?;
              return filters == null || filters.isEmpty;
            })
            .map((element) => element['outputFile'])
            .whereType<String>()
            .toList();
        if (outputs.length != 1) {
          continue;
        }
        final apk = metadataFile.parent.childFile(outputs.single);
        if (apk.existsSync()) {
          return AndroidArtifact(apk: apk, applicationId: applicationId);
        }
      } on FormatException {
        // Ignore unrelated or partially written metadata files.
      }
    }
    return null;
  }

  String _variantName(BuildMode mode, String? flavor) {
    final prefix = flavor ?? '';
    final buildMode = mode.androidName;
    return '$prefix$buildMode';
  }
}
