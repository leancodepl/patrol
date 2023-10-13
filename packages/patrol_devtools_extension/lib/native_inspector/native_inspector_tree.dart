import 'package:devtools_app_shared/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:patrol_devtools_extension/native_inspector/node.dart';

class NodeProps {
  final Node? currentNode;
  final ValueChanged<Node> onNodeTap;
  final bool fullNodeName;

  NodeProps({
    required this.currentNode,
    required this.onNodeTap,
    required this.fullNodeName,
  });
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

class _Node extends HookWidget {
  const _Node({
    Key? key,
    required this.node,
    required this.props,
  }) : super(key: key);

  final NodeProps props;
  final Node node;

  @override
  Widget build(BuildContext context) {
    final isExpanded = useState(true);

    return GestureDetector(
      onTap: () => props.onNodeTap(node),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (node.children.isNotEmpty)
                InkWell(
                  onTap: () => isExpanded.value = !isExpanded.value,
                  child: AnimatedRotation(
                    turns: isExpanded.value ? 1 : 6 / 8,
                    duration: const Duration(milliseconds: 150),
                    child: Icon(
                      Icons.expand_more,
                      size: defaultIconSize,
                    ),
                  ),
                ),
              Container(
                color: props.currentNode == node
                    ? Theme.of(context).colorScheme.selectedRowBackgroundColor
                    : null,
                child: Text(props.fullNodeName
                    ? node.fullNodeName
                    : node.shortNodeName),
              ),
            ],
          ),
          if (isExpanded.value)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Column(
                  children: node.children
                      .map((e) => Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: _Node(
                              props: props,
                              node: e,
                            ),
                          ))
                      .toList()),
            ),
        ],
      ),
    );
  }
}
