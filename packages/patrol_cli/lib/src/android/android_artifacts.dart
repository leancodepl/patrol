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
      metadataRoot: rootDirectory
          .childDirectory('build')
          .childDirectory('app')
          .childDirectory('outputs')
          .childDirectory('apk'),
      expectedVariant: _variantName(buildMode, flavor),
    );
  }

  AndroidArtifact test({
    required AndroidTestLayout layout,
    required BuildMode buildMode,
    required String? flavor,
  }) {
    final selfInstrumenting = layout == AndroidTestLayout.selfInstrumenting;
    var metadataRoot = rootDirectory
        .childDirectory('build')
        .childDirectory(selfInstrumenting ? 'patrolTest' : 'app')
        .childDirectory('outputs')
        .childDirectory('apk');
    if (!selfInstrumenting) {
      metadataRoot = metadataRoot.childDirectory('androidTest');
    }
    return _resolve(
      metadataRoot: metadataRoot,
      expectedVariant:
          '${_variantName(buildMode, flavor)}'
          '${selfInstrumenting ? '' : 'AndroidTest'}',
    );
  }

  AndroidArtifact _resolve({
    required Directory metadataRoot,
    required String expectedVariant,
  }) {
    if (!metadataRoot.existsSync()) {
      throwToolExit(
        'No Android APK outputs found under ${metadataRoot.path}. '
        'Build the requested variant first.',
      );
    }

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

    throwToolExit(
      'Could not resolve Android APK for variant $expectedVariant under '
      '${metadataRoot.path}. Build that variant first.',
    );
  }

  String _variantName(BuildMode mode, String? flavor) {
    final prefix = flavor ?? '';
    final buildMode = mode.androidName;
    return '$prefix$buildMode';
  }
}
