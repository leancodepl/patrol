import 'package:devtools_app_shared/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:patrol_devtools_extension/native_inspector/node.dart';

class NodeProps {
  NodeProps({
    required this.currentNode,
    required this.onNodeTap,
    required this.fullNodeName,
    required this.colorScheme,
  });
  final Node? currentNode;
  final ValueChanged<Node> onNodeTap;
  final bool fullNodeName;
  final ColorScheme colorScheme;
}

class NativeInspectorTree extends StatelessWidget {
  const NativeInspectorTree({
    super.key,
    required this.roots,
    required this.props,
  });

  final List<Node> roots;
  final NodeProps props;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
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
      },
    );
  }
}

class _Node extends HookWidget {
  const _Node({
    required this.node,
    required this.props,
  });

  final NodeProps props;
  final Node node;

  @override
  Widget build(BuildContext context) {
    final iconSize = defaultIconSize;
    final nodeNeedsLines = (node.parent?.children.length ?? 0) > 1;

    final isExpanded = useState(true);

    final child = Padding(
      padding: EdgeInsets.only(left: iconSize),
      child: LayoutBuilder(
        builder: (context, constraints) => Column(
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
                        size: iconSize,
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: iconSize,
                    height: iconSize,
                  ),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  width: iconSize,
                  height: iconSize,
                  child: Center(
                    child: Text(
                      node.initialCharacter,
                      style: DefaultTextStyle.of(context).style.copyWith(
                            fontSize: iconSize * 0.7,
                            color: props.colorScheme.background,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => props.onNodeTap(node),
                  child: SizedBox(
                    width: (constraints.maxWidth - iconSize - iconSize - 4)
                        .clamp(0, double.infinity),
                    height: iconSize + 4,
                    child: OverflowBox(
                      child: Text(
                        props.fullNodeName
                            ? node.fullNodeName
                            : node.shortNodeName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (isExpanded.value)
              Column(
                children: node.children
                    .map(
                      (e) => _Node(
                        props: props,
                        node: e,
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );

    return nodeNeedsLines
        ? CustomPaint(
            painter: _LinesPainter(
              colorScheme: props.colorScheme,
              iconSize: iconSize,
              lastChildren: node == node.parent?.children.last,
              hasExpandMoreIcon: node.children.isNotEmpty,
            ),
            child: child,
          )
        : child;
  }
}

class _LinesPainter extends CustomPainter {
  _LinesPainter({
    required this.iconSize,
    required this.lastChildren,
    required this.colorScheme,
    required this.hasExpandMoreIcon,
  });

  final ColorScheme colorScheme;
  final double iconSize;
  final bool hasExpandMoreIcon;
  final bool lastChildren;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = _defaultLinePaint(colorScheme);
    final halfOfIconSize = iconSize / 2;

    final yEnd = lastChildren ? halfOfIconSize : size.height;

    canvas.drawLine(
      Offset(halfOfIconSize, 0),
      Offset(halfOfIconSize, yEnd),
      paint,
    );

    canvas.drawLine(
      Offset(halfOfIconSize, halfOfIconSize),
      Offset(
        hasExpandMoreIcon ? iconSize : (iconSize + halfOfIconSize),
        halfOfIconSize,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(_LinesPainter oldDelegate) =>
      oldDelegate.colorScheme.isLight != colorScheme.isLight;
}

Paint _defaultLinePaint(ColorScheme colorScheme) => Paint()
  ..color = colorScheme.isLight
      ? Colors.black54
      : const Color.fromARGB(255, 200, 200, 200)
  ..strokeWidth = 1.0;
