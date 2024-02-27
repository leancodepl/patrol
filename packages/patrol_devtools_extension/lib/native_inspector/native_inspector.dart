import 'package:devtools_app_shared/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:patrol_devtools_extension/native_inspector/native_view_details.dart';
import 'package:patrol_devtools_extension/native_inspector/native_view_hierarchy.dart';
import 'package:patrol_devtools_extension/native_inspector/nodes/node.dart';

class NativeInspector extends HookWidget {
  const NativeInspector({
    super.key,
    required this.onNodeChanged,
    required this.onRefreshPressed,
    required this.roots,
    required this.currentNode,
  });

  final List<Node> roots;
  final Node? currentNode;
  final ValueChanged<Node?> onNodeChanged;
  final ValueChanged<bool> onRefreshPressed;

  @override
  Widget build(BuildContext context) {
    final fullNodeNames = useState(false);
    final nativeDetails = useState(false);

    final splitAxis = Split.axisFor(context, 0.85);
    final child = Split(
      axis: splitAxis,
      initialFractions: const [0.6, 0.4],
      children: [
        RoundedOutlinedBorder(
          clip: true,
          child: NativeViewHierarchy(
            nativeDetails: nativeDetails,
            fullNodeNames: fullNodeNames,
            onRefreshPressed: () => onRefreshPressed(nativeDetails.value),
            roots: roots,
            props: NodeProps(
              currentNode: currentNode,
              onNodeTap: onNodeChanged,
              fullNodeName: fullNodeNames.value,
              colorScheme: Theme.of(context).colorScheme,
            ),
          ),
        ),
        RoundedOutlinedBorder(
          clip: true,
          child: NativeViewDetails(currentNode: currentNode),
        ),
      ],
    );

    return child;
  }
}
