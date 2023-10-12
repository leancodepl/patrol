import 'package:devtools_app_shared/ui.dart';
import 'package:flutter/material.dart';
import 'package:patrol_devtools_extension/native_inspector/node.dart';

class NativeInspectorTree extends StatelessWidget {
  const NativeInspectorTree({
    Key? key,
    required this.currentNode,
    required this.roots,
    required this.onNodeTap,
  }) : super(key: key);

  final List<Node> roots;
  final ValueChanged<Node> onNodeTap;
  final Node? currentNode;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return SizedBox(
        height: constraints.maxHeight,
        child: ListView(
          children: roots
              .map(
                (e) => _Node(
                  node: e,
                  onTap: onNodeTap,
                  currentNode: currentNode,
                ),
              )
              .toList(),
        ),
      );
    });
  }
}

class _Node extends StatelessWidget {
  const _Node({
    Key? key,
    required this.currentNode,
    required this.node,
    required this.onTap,
  }) : super(key: key);

  final ValueChanged<Node> onTap;
  final Node? currentNode;
  final Node node;

  @override
  Widget build(BuildContext context) {
    final className = node.nativeView.className ?? '';
    final resourceName = node.nativeView.resourceName ?? '';
    final nodeText =
        '$className${resourceName.isNotEmpty ? '<$resourceName>' : ''}';

    return GestureDetector(
      onTap: () => onTap(node),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: identical(currentNode, node)
                ? Theme.of(context).colorScheme.selectedRowBackgroundColor
                : null,
            child: Text(nodeText),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Column(
                children: node.children
                    .map((e) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: _Node(
                            currentNode: currentNode,
                            node: e,
                            onTap: onTap,
                          ),
                        ))
                    .toList()),
          ),
        ],
      ),
    );
  }
}
