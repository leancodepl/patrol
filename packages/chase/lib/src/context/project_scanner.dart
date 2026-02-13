import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'context_models.dart';

/// Scans a Flutter project to extract structural information.
class ProjectScanner {
  const ProjectScanner({required this.projectRoot});

  final String projectRoot;

  /// Scans the project and returns [ProjectInfo].
  Future<ProjectInfo> scan() async {
    final pubspecFile = File(p.join(projectRoot, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      return ProjectInfo(name: p.basename(projectRoot), rootPath: projectRoot);
    }

    final pubspecContent = await pubspecFile.readAsString();
    final pubspec = loadYaml(pubspecContent) as YamlMap;

    final name = pubspec['name'] as String? ?? p.basename(projectRoot);
    final deps = _parseDependencies(pubspec);
    final stateManagement = _detectStateManagement(deps);
    final router = _detectRouter(deps);

    return ProjectInfo(
      name: name,
      rootPath: projectRoot,
      stateManagement: stateManagement,
      router: router,
      dependencies: deps,
    );
  }

  /// Reads the patrol version from pubspec.yaml.
  Future<String?> getPatrolVersion() async {
    final pubspecFile = File(p.join(projectRoot, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) return null;

    final content = await pubspecFile.readAsString();
    final pubspec = loadYaml(content) as YamlMap;

    final deps = pubspec['dependencies'] as YamlMap?;
    final devDeps = pubspec['dev_dependencies'] as YamlMap?;

    final patrolVersion = deps?['patrol'] ?? devDeps?['patrol'];
    if (patrolVersion is String) return patrolVersion;
    if (patrolVersion is YamlMap) {
      return patrolVersion['version'] as String?;
    }
    return null;
  }

  List<String> _parseDependencies(YamlMap pubspec) {
    final deps = <String>[];
    final dependencies = pubspec['dependencies'] as YamlMap?;
    final devDependencies = pubspec['dev_dependencies'] as YamlMap?;

    if (dependencies != null) {
      deps.addAll(dependencies.keys.cast<String>());
    }
    if (devDependencies != null) {
      deps.addAll(devDependencies.keys.cast<String>());
    }
    return deps;
  }

  String? _detectStateManagement(List<String> deps) {
    if (deps.contains('flutter_bloc') || deps.contains('bloc')) return 'BLoC';
    if (deps.contains('flutter_riverpod') || deps.contains('riverpod')) {
      return 'Riverpod';
    }
    if (deps.contains('provider')) return 'Provider';
    if (deps.contains('get') || deps.contains('get_it')) return 'GetX/GetIt';
    if (deps.contains('mobx') || deps.contains('flutter_mobx')) return 'MobX';
    return null;
  }

  String? _detectRouter(List<String> deps) {
    if (deps.contains('go_router')) return 'GoRouter';
    if (deps.contains('auto_route')) return 'AutoRoute';
    if (deps.contains('beamer')) return 'Beamer';
    return null;
  }
}
