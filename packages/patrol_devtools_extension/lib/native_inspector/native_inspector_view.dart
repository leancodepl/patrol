import 'package:devtools_app_shared/ui.dart';
import 'package:flutter/material.dart';
import 'package:patrol_devtools_extension/api/contracts.dart';
import 'package:patrol_devtools_extension/native_inspector/native_inspector_tree.dart';
import 'package:patrol_devtools_extension/native_inspector/node_details.dart';

class NativeInspectorView extends StatelessWidget {
  const NativeInspectorView({
    Key? key,
    required this.onNodeChanged,
    required this.onRefreshPressed,
    required this.roots,
    required this.currentNode,
  }) : super(key: key);

  final List<NativeView> roots;
  final NativeView? currentNode;
  final ValueChanged<NativeView?> onNodeChanged;
  final VoidCallback onRefreshPressed;

  @override
  Widget build(BuildContext context) {
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
              ),
              Expanded(
                child: NativeInspectorTree(
                  roots: roots,
                  currentNativeView: currentNode,
                  onNodeTap: onNodeChanged,
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
  const _InspectorTreeControls({Key? key, required this.onRefreshPressed})
      : super(key: key);

  final VoidCallback onRefreshPressed;

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
          DevToolsTooltip(
            message: 'Refresh Tree',
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: onRefreshPressed,
              child: Icon(
                Icons.refresh,
                size: actionsIconSize,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NativeViewDetails extends StatelessWidget {
  const _NativeViewDetails({Key? key, required this.currentNode})
      : super(key: key);

  final NativeView? currentNode;

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
