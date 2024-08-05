import 'dart:convert';
import 'dart:io';

import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:yaml/yaml.dart';


class CoverageOptions {
  const CoverageOptions({
    this.coverage = false,
    this.host = '127.0.0.1',
    this.port = 8181,
    this.out = 'coverage/lcov.info',
    this.connectTimeout = 10,
    this.scopeOutput = const [],
    this.waitPaused = false,
    this.resumeIsolates = true,
    this.includeDart = false,
    this.functionCoverage = true,
    this.branchCoverage = false,
    this.mergeCoverage = false,
    this.coveragePath,
    this.packagesRegExps = const [],
    this.appName = '',
  });

  final bool coverage;
  final String host;
  final int port;
  final String out;
  final int connectTimeout;
  final List<String> scopeOutput;
  final bool waitPaused;
  final bool resumeIsolates;
  final bool includeDart;
  final bool functionCoverage;
  final bool branchCoverage;
  final bool mergeCoverage;
  final String? coveragePath;
  final List<String> packagesRegExps;
  final String appName;

  /// Returns the coverage packages to include in the coverage report.
  Future<Set<String>> getCoveragePackages(
  ) async {
    final packagesToInclude = <String>{
      if (packagesRegExps.isEmpty) await _getProjectName(),
    };

    try {
      for (final regExpStr in packagesRegExps) {
        final regExp = RegExp(regExpStr);
        final packagesNames = await _getPackagesNamesFromPackageConfig();
        packagesToInclude.addAll(
          packagesNames
              .where(regExp.hasMatch),
        );
      }
    } on FormatException catch (e) {
      throwToolExit('Regular expression syntax is invalid. $e');
    }
    return packagesToInclude;
  }

  Future<String> _getProjectName() async {
    try {
      final pubspecFile = File('pubspec.yaml');
      final pubspecContent = await pubspecFile.readAsString();
      final pubspec = loadYaml(pubspecContent);
      // ignore: avoid_dynamic_calls
      return pubspec['name'] as String;
    } on FileSystemException catch (e) {
      throwToolExit('Failed to read pubspec.yaml. $e');
    } on YamlException catch (e) {
      throwToolExit('Failed to parse pubspec.yaml. $e');
    } 
  }

  Future<List<String>> _getPackagesNamesFromPackageConfig() async {
    try {
      final packagesConfig = File('.dart_tool/package_config.json').readAsStringSync();
      final packageJson = jsonDecode(packagesConfig) as Map<String, dynamic>;
      final packagesNames = <String>[];

      for (final package in packageJson['packages'] as List) {
        // ignore: avoid_dynamic_calls
        packagesNames.add(package['name'] as String);
      }

      return packagesNames;
    } catch (err) {
      throwToolExit('Failed to read package_config.json. $err');
    }
  }

  Future<String> getPackageConfigData() async {
    try {
      final packagesConfig = File('.dart_tool/package_config.json').readAsStringSync();
      return packagesConfig;
    } catch (err) {
      throwToolExit('Failed to read package_config.json. $err');
    }
  }
}
