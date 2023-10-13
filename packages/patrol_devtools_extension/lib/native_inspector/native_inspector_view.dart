import 'package:devtools_app_shared/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:patrol_devtools_extension/native_inspector/native_inspector_tree.dart';
import 'package:patrol_devtools_extension/native_inspector/node.dart';
import 'package:patrol_devtools_extension/native_inspector/node_details.dart';

class NativeInspectorView extends HookWidget {
  const NativeInspectorView({
    Key? key,
    required this.onNodeChanged,
    required this.onRefreshPressed,
    required this.roots,
    required this.currentNode,
  }) : super(key: key);

  final List<Node> roots;
  final Node? currentNode;
  final ValueChanged<Node?> onNodeChanged;
  final VoidCallback onRefreshPressed;

  @override
  Widget build(BuildContext context) {
    final fullNodeNames = useState(false);

    final splitAxis = Split.axisFor(context, 0.85);
    final child = Split(
      axis: splitAxis,
      initialFractions: const [0.6, 0.4],
      children: [
        RoundedOutlinedBorder(
          clip: true,
          child: Column(
            children: [
              _InspectorTreeControls(
                onRefreshPressed: onRefreshPressed,
                fullNodeNames: fullNodeNames,
              ),
              Expanded(
                child: NativeInspectorTree(
                  roots: roots,
                  props: NodeProps(
                    currentNode: currentNode,
                    onNodeTap: onNodeChanged,
                    fullNodeName: fullNodeNames.value,
                  ),
                ),
              ),
            ],
          ),
        ),
        RoundedOutlinedBorder(
          child: Column(
            children: [
              _NativeViewDetails(currentNode: currentNode),
            ],
          ),
        ),
      ],
    );

    return child;
  }
}

class _InspectorTreeControls extends StatelessWidget {
  const _InspectorTreeControls(
      {Key? key, required this.onRefreshPressed, required this.fullNodeNames})
      : super(key: key);

  final VoidCallback onRefreshPressed;
  final ValueNotifier<bool> fullNodeNames;

  @override
  Widget build(BuildContext context) {
    return _HeaderDecoration(
      child: Row(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: denseSpacing),
            child: Text('View Tree'),
          ),
          const Spacer(),
          _ControlButton(
              message: 'Full node names',
              onPressed: () {
                fullNodeNames.value = !fullNodeNames.value;
              },
              icon: fullNodeNames.value
                  ? Icons.visibility
                  : Icons.visibility_off),
          const SizedBox(width: 4),
          _ControlButton(
            icon: Icons.refresh,
            message: 'Refresh tree',
            onPressed: onRefreshPressed,
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton(
      {Key? key,
      required this.message,
      required this.onPressed,
      required this.icon})
      : super(key: key);

  final String message;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DevToolsTooltip(
      message: message,
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: onPressed,
        child: Icon(
          icon,
          size: actionsIconSize,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _NativeViewDetails extends StatelessWidget {
  const _NativeViewDetails({Key? key, required this.currentNode})
      : super(key: key);

  final Node? currentNode;

  @override
  Widget build(BuildContext context) {
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _HeaderDecoration(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: denseSpacing),
            child: SizedBox(
              width: double.infinity,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'View details',
                ),
              ),
            ),
          ),
        ),
        currentNode != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: denseSpacing),
                child: NodeDetails(node: currentNode!),
              )
            : const Center(child: Text('Select a node to view its details')),
      ],
    );
  }
}

class _HeaderDecoration extends StatelessWidget {
  const _HeaderDecoration({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: defaultHeaderHeight(isDense: _isDense()),
      decoration: BoxDecoration(
        border: Border(
          bottom: defaultBorderSide(Theme.of(context)),
        ),
      ),
      child: child,
    );
  }

  bool _isDense() {
    return ideTheme.embed;
  }
}
