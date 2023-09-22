import 'dart:async';

import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/material.dart';
import 'package:vm_service/vm_service.dart';
import 'package:flutter/src/widgets/widget_inspector.dart';

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
          return Column(
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
                onPressed: state.appConnected
                    ? () {
                        runner.showTree();
                      }
                    : null,
                child: const Text('Show widget tree'),
              ),
              Text(state.root),
            ],
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

  Future<void> showTree() async {
    final tree = Tree();

    final res = await tree.invokeServiceMethodReturningNode(
        WidgetInspectorServiceExtensions.getRootWidget.name);

    if (res is InstanceRef) {
      value.root = res.valueAsString ?? ':((';
    } else {
      value.root = res?.toString() ?? ':(';
    }

    notifyListeners();
  }
}

class _State {
  bool appConnected = false;
  String appConnectedDesc = '';
  String root = '';
}

class Tree {
  bool get useDaemonApi => serviceManager.isMainIsolatePaused;
  static const inspectorLibraryUri =
      'package:flutter/src/widgets/widget_inspector.dart';
  final EvalOnDartLibrary inspectorLibrary =
      EvalOnDartLibrary(libraryName: inspectorLibraryUri);

  Future<Object?> invokeServiceMethodReturningNode(
    String methodName,
  ) async {
    const groupName = 'debugName_0';
    return invokeServiceMethodObservatory1(methodName, groupName);
  }

  Future<InstanceRef?> invokeServiceMethodObservatory1(
    String methodName,
    String arg1,
  ) {
    return inspectorLibrary.eval(
      "WidgetInspectorService.instance.$methodName('$arg1')",
    );
  }
}

class EvalOnDartLibrary {
  final String libraryName;

  EvalOnDartLibrary({required this.libraryName});

  Future<InstanceRef?> eval(String expression) async {
    await init();
    return _eval(expression);
  }

  Future<void> init() async {
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
    } catch (e, stack) {
      print('$e - $expression');
    }
    return null;
  }

  LibraryRef? _libraryRef;
}
