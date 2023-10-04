import 'dart:async';
import 'dart:convert';

import 'package:devtools_app_shared/service.dart';
import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
                TextButton(
                  onPressed: state.rootWidgetId.isNotEmpty
                      ? () => runner.getRootWidgetObject()
                      : null,
                  child: const Text('getRootWidgetObject'),
                ),
                Text(state.getRootWidgetObjectResponse),
                Text(state.rootWidgetValueAsJson),
                Text(state.getRootWidgetRespone),
                TextButton(
                  onPressed:
                      state.appConnected ? () => runner.getNativeViews() : null,
                  child: const Text('getNativeViews'),
                ),
                Text(state.getNativeViewsResponse),
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
                TextButton(
                  onPressed: state.appConnected
                      ? () => runner.debugDumpRenderTree()
                      : null,
                  child: const Text('debugDumpRenderTree'),
                ),
                Text(state.debugDumpRenderTreeResponse),
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
    final res = await Api(serviceExtensionPrefix: 'ext.flutter.inspector')
        .invokeServiceMethodReturningNode(
            WidgetInspectorServiceExtensions.getRootWidget.name);

    if (res is InstanceRef) {
      value.getRootWidgetRespone =
          const JsonEncoder.withIndent('  ').convert(res.toJson());
      value.rootWidgetId = res.id!;
    } else {
      value.getRootWidgetRespone = res?.toString() ?? ':(';
    }

    notifyListeners();
  }

  Future<void> getRootWidgetObject() async {
    try {
      final obj = await Api(serviceExtensionPrefix: 'ext.flutter.inspector')
          .getObject(value.rootWidgetId);
      value.getRootWidgetObjectResponse =
          const JsonEncoder.withIndent('  ').convert(obj.toJson());

      final valueAsString = obj.json!['valueAsString'];
      value.rootWidgetValueAsJson =
          const JsonEncoder.withIndent('  ').convert(jsonDecode(valueAsString));
    } catch (e) {
      value.getRootWidgetObjectResponse = ':( $e';
    }

    notifyListeners();
  }

  Future<void> getRootWidgetSummaryTreeWithPreviews() async {
    const groupName = 'debugName_0';
    final res = await Api(serviceExtensionPrefix: 'ext.flutter.inspector')
        .invokeServiceMethodDaemonParams(
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

  Future<void> getNativeViews() async {
    final stopwatch = Stopwatch()..start();
    final res = await Api(serviceExtensionPrefix: 'ext.flutter')
        .invokeServiceMethodDaemon('PatrolDevToolsGetNativeViews');

    if (res is Map<String, dynamic>) {
      value.getNativeViewsResponse =
          const JsonEncoder.withIndent('  ').convert(res);
    } else {
      value.getNativeViewsResponse = ':(';
    }

    stopwatch.stop();

    value.getNativeViewsResponse =
        stopwatch.elapsed.toString() + value.getNativeViewsResponse;

    print(value.getNativeViewsResponse);
    notifyListeners();
  }

  Future<void> getRootWidgetSummaryTree() async {
    final res = await Api(serviceExtensionPrefix: 'ext.flutter.inspector')
        .invokeServiceMethodDaemon(
            WidgetInspectorServiceExtensions.getRootWidgetSummaryTree.name);

    if (res is Map<String, dynamic>) {
      value.getRootWidgetSummaryTreeResponse =
          const JsonEncoder.withIndent('  ').convert(res);
    } else {
      value.getRootWidgetSummaryTreeResponse = ':(';
    }

    notifyListeners();
  }

  Future<void> debugDumpRenderTree() async {
    final res = await ExtensionApi().debugDumpRenderTree();

    value.debugDumpRenderTreeResponse =
        const JsonEncoder.withIndent('  ').convert(res.json).substring(0, 1000);

    notifyListeners();
  }
}

class _State {
  bool appConnected = false;
  String appConnectedDesc = '';
  String rootWidgetId = '';
  String getRootWidgetObjectResponse = '';
  String rootWidgetValueAsJson = '';
  String getRootWidgetRespone = '';
  String getRootWidgetSummaryTreeResponse = '';
  String getNativeViewsResponse = '';
  String getRootWidgetSummaryTreeWithPreviewsResponse = '';
  String debugDumpRenderTreeResponse = '';
}

class ExtensionApi {
  static const _flutterExtensionPrefix = 'ext.flutter.';

  Future<Response> debugDumpRenderTree() async {
    final name =
        '$_flutterExtensionPrefix${RenderingServiceExtensions.debugDumpRenderTree.name}';
    return serviceManager.callServiceExtensionOnMainIsolate(name);
  }
}

class Api {
  static const inspectorLibraryUri =
      'package:flutter/src/widgets/widget_inspector.dart';

  final String serviceExtensionPrefix;
  Api({
    required this.serviceExtensionPrefix,
  });

  final inspectorLibrary = EvalOnDartLibrary(
    inspectorLibraryUri,
    serviceManager.service!,
    serviceManager: serviceManager,
  );

  Future<Obj> getObject(String objectId) {
    return serviceManager.service!
        .getObject(inspectorLibrary.isolateRef!.id!, objectId);
  }

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
      isAlive: null,
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
