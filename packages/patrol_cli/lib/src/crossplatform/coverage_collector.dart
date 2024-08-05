import 'dart:async';
import 'dart:io';

import 'package:coverage/coverage.dart' as coverage;
import 'package:path/path.dart' as path;
import 'package:patrol_cli/src/base/logger.dart';
import 'package:process/process.dart';
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';

import 'coverage_options.dart';

/// A singleton class responsible for collecting and managing code coverage data.
class CoverageCollector {
  factory CoverageCollector() => _instance;
  CoverageCollector._internal();
  static final CoverageCollector _instance = CoverageCollector._internal();

  late final Logger _logger;
  late final ProcessManager _processManager;
  late final CoverageOptions _options;

  VmService? _service;
  Map<String, coverage.HitMap>? _globalHitmap;
  Set<String>? _libraryNames;
  coverage.Resolver? _resolver;

  bool _isInitialized = false;
  bool _isRunning = false;
  final _completer = Completer<void>();

  String? _currentObservatoryUrlWs;
  String? _currentObservatoryUrlHttp;

  static const String _coverageDir = 'coverage';
  static const String _mergedLcovFile = '$_coverageDir/lcov.info';

  /// Initializes the CoverageCollector with required dependencies.
  Future<void> initialize({
    required Logger logger,
    required ProcessManager processManager,
    CoverageOptions? options,
  }) async {
    if (_isInitialized) {
      return;
    }

    _logger = logger;
    _processManager = processManager;
    _options = options ?? const CoverageOptions();
    _isInitialized = true;
    _libraryNames = await _options.getCoveragePackages();
  }

  /// Starts the coverage collection process.
  Future<void> start(String currentObservatoryUrlHttp) async {
    _ensureInitialized();

    _currentObservatoryUrlHttp = currentObservatoryUrlHttp;
    _currentObservatoryUrlWs =
        _convertToWebSocketUrl(currentObservatoryUrlHttp);

    await _connectToVmService();
    _isRunning = true;

    _setupEventListeners();

    await _setBreakpointsForAllIsolates();

    await _completer.future;
  }

  /// Stops the coverage collection process and writes the collected data.
  Future<void> stop() async {
    if (!_isRunning) {
      return;
    }

    _isRunning = false;
    await _service?.dispose();
    _completer.complete();

    final success = await collectCoverageData(_mergedLcovFile,
        mergeCoverageData: _options.mergeCoverage,);
    _logCoverageResult(success);
  }

  /// Collects coverage data for a specific isolate.
  Future<void> collectCoverage(String isolateId) async {
    _logger
        .detail('Collecting coverage data from $_currentObservatoryUrlHttp...');

    final libraryNamesList = _libraryNames?.toList();
    if (libraryNamesList == null || libraryNamesList.isEmpty) {
      _logger.err('No library names found. Coverage collection aborted.');
      return;
    }

    _logCoverageDetails(libraryNamesList);

    final data = await _collectCoverageData(libraryNamesList);
    await _mergeCoverageData(data);
  }

  /// Finalizes the coverage data and returns it as a formatted string.
  Future<String?> finalizeCoverage({
    String Function(Map<String, coverage.HitMap> hitmap)? formatter,
    coverage.Resolver? resolver,
    Directory? coverageDirectory,
  }) async {
    _logger.detail('Finalizing coverage data...');
    if (_globalHitmap == null) {
      _logger.warn('No coverage data to finalize.');
      return null;
    }

    formatter ??= _createDefaultFormatter(
        await _getResolver(resolver), coverageDirectory,);

    final result = formatter(_globalHitmap!);
    _logger.detail('Coverage data finalized.');

    _globalHitmap = null;
    return result;
  }

  /// Collects and writes coverage data to a file.
  Future<bool> collectCoverageData(String? coveragePath,
      {bool mergeCoverageData = false, Directory? coverageDirectory,}) async {
    final coverageData =
        await finalizeCoverage(coverageDirectory: coverageDirectory);
    if (coverageData == null) {
      return false;
    }

    await _writeCoverageDataToFile(coveragePath!, coverageData);

    if (mergeCoverageData) {
      return _mergeCoverageWithBaseData(coveragePath);
    }

    return true;
  }

  // Private methods

  Future<coverage.Resolver> _getResolver(
      coverage.Resolver? providedResolver,) async {
    if (providedResolver != null) {
      return providedResolver;
    }
    if (_resolver != null) {
      return _resolver!;
    }
    _resolver = await coverage.Resolver.create(
        packagesPath: '.dart_tool/package_config.json',);
    return _resolver!;
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
          'CoverageCollector not initialized. Call initialize() first.',);
    }
  }

  Future<void> _connectToVmService() async {
    final wsUrl = _convertToWebSocketUrl(_currentObservatoryUrlWs!);
    _logger.detail('Connecting to $wsUrl');

    try {
      _service = await vmServiceConnectUri(wsUrl);
      _logger.detail('Connected to VM service');
    } catch (e) {
      _logger.err('Failed to connect to VM service: $e');
      _isRunning = false;
      _completer.complete();
      rethrow;
    }
  }

  void _setupEventListeners() {
    _service?.onIsolateEvent.listen(_handleIsolateEvent);
    _service?.onDebugEvent.listen(_handleDebugEvent);
    _service?.streamListen(EventStreams.kDebug);
    _service?.streamListen(EventStreams.kIsolate);
    _logger.detail('Listening for events...');
  }

  Future<void> _setBreakpointsForAllIsolates() async {
    final vm = await _service?.getVM();
    for (final isolateRef in vm?.isolates ?? []) {
      isolateRef as IsolateRef;
      await _setTestBreakpoints(isolateRef.id!);
    }
  }

  Future<void> _handleIsolateEvent(Event event) async {
    if (!_isRunning) {
      return;
    }

    if (event.kind == EventKind.kIsolateRunnable) {
      _logger.detail('New isolate detected. Setting breakpoints...');
      await _setTestBreakpoints(event.isolate!.id!);
    }
  }

  void _handleDebugEvent(Event event) {
    if (!_isRunning) {
      return;
    }

    if (event.kind == EventKind.kPauseBreakpoint) {
      _handleBreakpoint(event);
    }
  }

  Future<void> _setTestBreakpoints(String isolateId) async {
    if (_service == null) {
      _logger.warn('VM service is not available. Cannot set breakpoints.');
      return;
    }

    try {
      final scripts = await _service!.getScripts(isolateId);

      for (final scriptRef in scripts.scripts!) {
        if (_isIntegrationTestScript(scriptRef.uri!)) {
          await _setBreakpointsInScript(isolateId, scriptRef);
        }
      }
    } catch (e) {
      _logger.warn('Error setting breakpoints: $e');
    }
  }

  bool _isIntegrationTestScript(String uri) {
    return uri.contains('integration_test/') && uri.endsWith('_test.dart');
  }

  Future<void> _setBreakpointsInScript(
      String isolateId, ScriptRef scriptRef,) async {
    _logger.detail('Setting breakpoints in ${scriptRef.uri}');

    final script = await _getScript(isolateId, scriptRef);
    if (script == null) {
      return;
    }

    final lines = script.source!.split('\n');

    for (var i = 0; i < lines.length; i++) {
      if (_isTestFunctionStart(lines[i])) {
        final endLine = _findTestFunctionEnd(lines, i);
        if (endLine != -1) {
          await _addBreakpoint(isolateId, scriptRef.uri!, endLine);
        }
      }
    }
  }

  Future<Script?> _getScript(String isolateId, ScriptRef scriptRef) async {
    try {
      return await _service!.getObject(isolateId, scriptRef.id!) as Script?;
    } catch (e) {
      _logger.warn('Failed to get script object: $e');
      return null;
    }
  }

  bool _isTestFunctionStart(String line) {
    final trimmedLine = line.trim();
    return trimmedLine.startsWith('test(') ||
        trimmedLine.startsWith('testWidgets(') ||
        trimmedLine.startsWith('patrol(') ||
        trimmedLine.startsWith('patrolTest(');
  }

  int _findTestFunctionEnd(List<String> lines, int startLine) {
    var bracketCount = 0;
    var foundOpeningBracket = false;
    for (var i = startLine; i < lines.length; i++) {
      if (!foundOpeningBracket && lines[i].contains('{')) {
        foundOpeningBracket = true;
      }
      if (foundOpeningBracket) {
        bracketCount += '{'.allMatches(lines[i]).length;
        bracketCount -= '}'.allMatches(lines[i]).length;
        if (bracketCount == 0) {
          return i + 1;
        }
      }
    }
    return -1;
  }

  Future<void> _addBreakpoint(
      String isolateId, String scriptUri, int lineNumber,
      ) async {
    try {
      final bp = await _service!.addBreakpointWithScriptUri(
        isolateId,
        scriptUri,
        lineNumber,
      );
      _logger.detail(
          'Breakpoint added: ${bp.id} at line $lineNumber (end of test)',
      );
    } catch (err) {
      _logger.warn('Error adding breakpoint: $err');
    }
  }

  Future<void> _handleBreakpoint(Event event) async {
    if (!_isRunning || _service == null) {
      _logger
          .warn('TestMonitor is not running or VM service is not available.');
      return;
    }

    final isolateId = event.isolate?.id;
    if (isolateId == null) {
      _logger.warn('Warning: Isolate ID is null');
      return;
    }

    _logger
      ..detail('Breakpoint hit in isolate: $isolateId')
      ..detail('Breakpoint ID: ${event.breakpoint?.id ?? 'Unknown'}');

    try {
      await _logBreakpointLocation(event, isolateId);
      _logger.detail('Collecting coverage...');
      await collectCoverage(isolateId);
    } catch (e) {
      _logger.err('Error handling breakpoint: $e');
    }
  }

  Future<void> _logBreakpointLocation(Event event, String isolateId) async {
    if (event.topFrame?.location?.script == null) {
      _logger.warn('Warning: Script information is not available');
      return;
    }

    final scriptRef = event.topFrame!.location!.script!;
    final script =
        await _service!.getObject(isolateId, scriptRef.id!) as Script?;

    if (script != null) {
      final lineNumber = event.topFrame?.location?.line ?? 'Unknown';
      _logger.detail('Paused at ${script.uri}:$lineNumber (end of test)');
    } else {
      _logger.warn('Warning: Unable to retrieve script information');
    }
  }

  void _logCoverageDetails(List<String> libraryNamesList) {
    _logger
      ..detail('library names: ${libraryNamesList.join(',')}')
      ..detail('branchCoverage: ${_options.branchCoverage}')
      ..detail('functionCoverage: ${_options.functionCoverage}');
  }

  Future<Map<String, dynamic>> _collectCoverageData(
      List<String> libraryNamesList,) async {
    return coverage.collect(
      Uri.parse(_currentObservatoryUrlHttp!),
      true,
      false,
      false,
      libraryNamesList.toSet(),
      branchCoverage: _options.branchCoverage,
      functionCoverage: _options.functionCoverage,
      timeout: const Duration(minutes: 5),
    );
  }

  Future<void> _mergeCoverageData(Map<String, dynamic> data) async {
    _logger.detail('Collected coverage data; merging...');

    _addHitmap(
      await coverage.HitMap.parseJson(
        data['coverage'] as List<Map<String, dynamic>>,
        packagePath: Directory.current.path,
        checkIgnoredLines: true,
      ),
    );

    _logger.detail('Done merging coverage data into global coverage map.');
  }

  void _addHitmap(Map<String, coverage.HitMap> hitmap) {
    if (_globalHitmap == null) {
      _globalHitmap = hitmap;
    } else {
      _globalHitmap!.merge(hitmap);
    }
  }

  String Function(Map<String, coverage.HitMap>) _createDefaultFormatter(
    coverage.Resolver resolver,
    Directory? coverageDirectory,
  ) {
    return (hitmap) {
      final packagePath = Directory.current.path;
      final libraryPaths = _libraryNames
          ?.map((e) => resolver.resolve('package:$e'))
          .whereType<String>()
          .toList();

      final reportOn = coverageDirectory == null
          ? libraryPaths
          : <String>[coverageDirectory.path];

      _logger
        ..detail('Coverage report on: ${reportOn!.join(', ')}')
        ..detail('Coverage package path: $packagePath');

      return hitmap.formatLcov(resolver,
          reportOn: reportOn, basePath: packagePath,);
    };
  }

  Future<void> _writeCoverageDataToFile(
      String coveragePath, String coverageData,) async {
    File(coveragePath)
      ..createSync(recursive: true)
      ..writeAsStringSync(coverageData, flush: true);
    _logger.detail(
        'Wrote coverage data to $coveragePath (size=${coverageData.length})',);
  }

  Future<bool> _mergeCoverageWithBaseData(String coveragePath) async {
    const baseCoverageData = 'coverage/lcov.base.info';
    if (!File(baseCoverageData).existsSync()) {
      _logger
          .err('Missing "$baseCoverageData". Unable to merge coverage data.');
      return false;
    }

    if (!await _isLcovInstalled()) {
      return false;
    }

    return _executeLcovMerge(coveragePath, baseCoverageData);
  }

  Future<bool> _isLcovInstalled() async {
    final lcovResult = await _processManager.run(['which', 'lcov']);
    if (lcovResult.exitCode != 0) {
      _logger.err(
          'Missing "lcov" tool. Unable to merge coverage data.\n${_getLcovInstallMessage()}',);
      return false;
    }
    return true;
  }

  String _getLcovInstallMessage() {
    if (Platform.isLinux) {
      return 'Consider running "sudo apt-get install lcov".';
    } else if (Platform.isMacOS) {
      return 'Consider running "brew install lcov".';
    }
    return 'Please install lcov.';
  }

  Future<bool> _executeLcovMerge(
      String coveragePath, String baseCoverageData,) async {
    final tempDir = Directory.systemTemp.createTempSync('patrol_coverage.');
    try {
      final sourceFile = File(coveragePath)
          .copySync(path.join(tempDir.path, 'lcov.source.info'));
      final result = await _processManager.run(<String>[
        'lcov',
        '--add-tracefile',
        baseCoverageData,
        '--add-tracefile',
        sourceFile.path,
        '--output-file',
        coveragePath,
      ]);
      return result.exitCode == 0;
    } finally {
      tempDir.deleteSync(recursive: true);
    }
  }

  void _logCoverageResult(bool success) {
    if (success) {
      _logger.detail('Coverage data written to $_mergedLcovFile');
    } else {
      _logger.err('Failed to write coverage data to $_mergedLcovFile');
    }
  }

  String _convertToWebSocketUrl(String observatoryUri) {
    var observatoryUriWs = observatoryUri.replaceFirst('http://', 'ws://');
    if (!observatoryUriWs.endsWith('/ws')) {
      observatoryUriWs += 'ws';
    }
    return observatoryUriWs;
  }
}
