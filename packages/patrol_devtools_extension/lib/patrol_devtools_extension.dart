import 'dart:async';
import 'dart:convert';

import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/material.dart';
import 'package:vm_service/vm_service.dart';

class PatrolDevToolsExtension extends StatefulWidget {
  const PatrolDevToolsExtension({Key? key}) : super(key: key);

  @override
  State<PatrolDevToolsExtension> createState() =>
      _PatrolDevToolsExtensionState();
}

class _PatrolDevToolsExtensionState extends State<PatrolDevToolsExtension> {
  final runner = _Runner();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<_State>(
        valueListenable: runner,
        builder: (context, state, child) {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: () {
                    runner.checkConnection();
                  },
                  child: const Text('Check app connection'),
                ),
                Text('Connection status: ${state.appConnectedDesc}'),
                TextButton(
                  onPressed:
                      state.appConnected ? () => runner.getRootWidget() : null,
                  child: const Text('getRootWidget'),
                ),
                Text(state.getRootWidgetRespone),
                TextButton(
                  onPressed: state.appConnected
                      ? () => runner.getRootWidgetSummaryTree()
                      : null,
                  child: const Text('getRootWidgetSummaryTree'),
                ),
                Text(state.getRootWidgetSummaryTreeResponse),
                TextButton(
                  onPressed: state.appConnected
                      ? () => runner.getRootWidgetSummaryTreeWithPreviews()
                      : null,
                  child: const Text('getRootWidgetSummaryTreeWithPreviews'),
                ),
                Text(state.getRootWidgetSummaryTreeWithPreviewsResponse),
              ],
            ),
          );
        });
  }
}

class _Runner extends ValueNotifier<_State> {
  _Runner() : super(_State());

  void checkConnection() {
    final app = serviceManager.connectedApp;
    if (app != null) {
      value.appConnectedDesc = '''App connected.
OperatingSystem: ${app.operatingSystem}
      ''';
      value.appConnected = true;
    } else {
      value.appConnected = false;
      value.appConnectedDesc = 'No connection';
    }

    notifyListeners();
  }

  Future<void> getRootWidget() async {
    final res = await Tree().invokeServiceMethodReturningNode(
        WidgetInspectorServiceExtensions.getRootWidget.name);

    if (res is InstanceRef) {
      value.getRootWidgetRespone =
          const JsonEncoder.withIndent('  ').convert(res.toJson());
    } else {
      value.getRootWidgetRespone = res?.toString() ?? ':(';
    }

    notifyListeners();
  }

  Future<void> getRootWidgetSummaryTreeWithPreviews() async {
    const groupName = 'debugName_0';
    final res = await Tree().invokeServiceMethodDaemonParams(
      WidgetInspectorServiceExtensions
          .getRootWidgetSummaryTreeWithPreviews.name,
      {'groupName': groupName},
    );

    if (res is Map<String, dynamic>) {
      value.getRootWidgetSummaryTreeWithPreviewsResponse =
          const JsonEncoder.withIndent('  ').convert(res);
    } else {
      value.getRootWidgetSummaryTreeWithPreviewsResponse = ':(';
    }

    notifyListeners();
  }

  Future<void> getRootWidgetSummaryTree() async {
    final res = await Tree().invokeServiceMethodDaemon(
        WidgetInspectorServiceExtensions.getRootWidgetSummaryTree.name);

    if (res is Map<String, dynamic>) {
      value.getRootWidgetSummaryTreeResponse =
          const JsonEncoder.withIndent('  ').convert(res);
    } else {
      value.getRootWidgetSummaryTreeResponse = ':(';
    }

    notifyListeners();
  }
}

class _State {
  bool appConnected = false;
  String appConnectedDesc = '';
  String getRootWidgetRespone = '';
  String getRootWidgetSummaryTreeResponse = '';
  String getRootWidgetSummaryTreeWithPreviewsResponse = '';
}

class Tree {
  static const inspectorLibraryUri =
      'package:flutter/src/widgets/widget_inspector.dart';
  static const serviceExtensionPrefix = 'ext.flutter.inspector';

  final EvalOnDartLibrary inspectorLibrary =
      EvalOnDartLibrary(libraryName: inspectorLibraryUri);

  Future<Object?> invokeServiceMethodReturningNode(
    String methodName,
  ) async {
    const groupName = 'debugName_0';
    return _invokeServiceMethodObservatory1(methodName, groupName);
  }

  Future<Object?> invokeServiceMethodDaemon(String methodName) {
    const groupName = 'debugName_0';

    return invokeServiceMethodDaemonParams(
      methodName,
      {'objectGroup': groupName},
    );
  }

  Future<Object?> invokeServiceMethodDaemonParams(
      String methodName, Map<String, Object?> params) async {
    final callMethodName = '$serviceExtensionPrefix.$methodName';
    if (!serviceManager.serviceExtensionManager
        .isServiceExtensionAvailable(callMethodName)) {
      final available = await serviceManager.serviceExtensionManager
          .waitForServiceExtensionAvailable(callMethodName);
      if (!available) return null;
    }

    return await _callServiceExtension(callMethodName, params);
  }

  Future<InstanceRef?> _invokeServiceMethodObservatory1(
    String methodName,
    String arg1,
  ) {
    return inspectorLibrary.eval(
      "WidgetInspectorService.instance.$methodName('$arg1')",
    );
  }

  Future<Object?> _callServiceExtension(
    String extension,
    Map<String, Object?> args,
  ) async {
    final r = await serviceManager.service!.callServiceExtension(
      extension,
      isolateId: inspectorLibrary.isolateRef!.id,
      args: args,
    );

    final json = r.json!;
    if (json['errorMessage'] != null) {
      throw Exception('$extension -- ${json['errorMessage']}');
    }
    return json['result'];
  }
}

class EvalOnDartLibrary {
  final String libraryName;

  EvalOnDartLibrary({required this.libraryName});

  Future<InstanceRef?> eval(String expression) async {
    await _init();
    return _eval(expression);
  }

  Future<void> _init() async {
    final Isolate? isolate =
        await serviceManager.isolateManager.isolateState(isolateRef!).isolate;
    _isolateRef = isolate;

    for (LibraryRef library in isolate?.libraries ?? []) {
      if (libraryName == library.uri) {
        _libraryRef = library;
        return;
      }
    }
  }

  IsolateRef? get isolateRef =>
      serviceManager.isolateManager.selectedIsolate.value;
  IsolateRef? _isolateRef;

  Future<InstanceRef?> _eval(String expression) async {
    try {
      final result = await serviceManager.service!.evaluate(
        _isolateRef!.id!,
        _libraryRef!.id!,
        expression,
        scope: null,
        disableBreakpoints: null,
      );
      if (result is Sentinel) {
        return null;
      }
      if (result is ErrorRef) {
        throw result;
      }
      return result as FutureOr<InstanceRef?>;
    } catch (e) {
      print('$e - $expression');
    }
    return null;
  }

  LibraryRef? _libraryRef;
}
