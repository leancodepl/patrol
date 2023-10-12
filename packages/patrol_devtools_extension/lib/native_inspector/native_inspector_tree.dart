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

class _Node extends StatefulWidget {
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
  State<_Node> createState() => _NodeState();
}

class _NodeState extends State<_Node> {
  bool isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final className = widget.node.nativeView.className ?? '';
    final resourceName = widget.node.nativeView.resourceName ?? '';
    final nodeText =
        '$className${resourceName.isNotEmpty ? '<$resourceName>' : ''}';

    return GestureDetector(
      onTap: () => widget.onTap(widget.node),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (widget.node.children.isNotEmpty)
                InkWell(
                  onTap: _toogleIsExpanded,
                  child: AnimatedRotation(
                    turns: isExpanded ? 1 : 6 / 8,
                    duration: const Duration(milliseconds: 150),
                    child: Icon(
                      Icons.expand_more,
                      size: defaultIconSize,
                    ),
                  ),
                ),
              Container(
                color: widget.currentNode == widget.node
                    ? Theme.of(context).colorScheme.selectedRowBackgroundColor
                    : null,
                child: Text(nodeText),
              ),
            ],
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Column(
                  children: widget.node.children
                      .map((e) => Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: _Node(
                              currentNode: widget.currentNode,
                              node: e,
                              onTap: widget.onTap,
                            ),
                          ))
                      .toList()),
            ),
        ],
      ),
    );
  }

  void _toogleIsExpanded() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }
}
