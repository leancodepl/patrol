import 'dart:async';

import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/material.dart';
import 'package:patrol_devtools_extension/api/patrol_service_extension_api.dart';
import 'package:patrol_devtools_extension/native_inspector/native_inspector_view.dart';
import 'package:patrol_devtools_extension/native_inspector/node.dart';

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
    return ValueListenableBuilder(
        valueListenable: runner,
        builder: (context, state, child) {
          return NativeInspectorView(
            roots: state.roots,
            currentNode: state.currentNode,
            onNodeChanged: runner.changeNode,
            onRefreshPressed: runner.getNativeUITree,
          );
        });
  }
}

class _Runner extends ValueNotifier<_State> {
  _Runner() : super(_State());

  bool get isAndroidApp =>
      serviceManager.connectedApp?.operatingSystem == 'android';

  void changeNode(Node? node) {
    value.currentNode = node;
    notifyListeners();
  }

  Future<void> getNativeUITree() async {
    value.roots = [];
    value.currentNode = null;

    final api = PatrolServiceExtensionApi(
      service: serviceManager.service!,
      isolate: serviceManager.isolateManager.mainIsolate,
    );

    final res = await api.getNativeUITree();

    switch (res) {
      case ApiSuccess(:final data):
        value.roots =
            data.roots.map((e) => Node(e, isAndroidApp, null)).toList();
      case ApiFailure(:final error, :final stackTrace):
      //TODO
    }

    notifyListeners();
  }
}

class _State {
  List<Node> roots = [];
  Node? currentNode;
}
