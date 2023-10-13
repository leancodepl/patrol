import 'package:devtools_app_shared/ui.dart';
import 'package:flutter/material.dart';
import 'package:patrol_devtools_extension/native_inspector/node.dart';

class NodeProps {
  final Node? currentNode;
  final ValueChanged<Node> onNodeTap;

  NodeProps({required this.currentNode, required this.onNodeTap});
}

class NativeInspectorTree extends StatelessWidget {
  const NativeInspectorTree({
    Key? key,
    required this.roots,
    required this.props,
  }) : super(key: key);

  final List<Node> roots;
  final NodeProps props;

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
                  props: props,
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
    required this.node,
    required this.props,
  }) : super(key: key);

  final NodeProps props;
  final Node node;

  @override
  State<_Node> createState() => _NodeState();
}

class _NodeState extends State<_Node> {
  bool isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.props.onNodeTap(widget.node),
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
                color: widget.props.currentNode == widget.node
                    ? Theme.of(context).colorScheme.selectedRowBackgroundColor
                    : null,
                child: Text(widget.node.fullNodeName),
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
                              props: widget.props,
                              node: e,
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
