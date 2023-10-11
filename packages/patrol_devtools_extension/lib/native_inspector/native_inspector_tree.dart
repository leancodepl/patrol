import 'package:devtools_app_shared/ui.dart';
import 'package:flutter/material.dart';
import 'package:patrol_devtools_extension/api/contracts.dart';

class NativeInspectorTree extends StatelessWidget {
  const NativeInspectorTree({
    Key? key,
    required this.currentNativeView,
    required this.roots,
    required this.onNodeTap,
  }) : super(key: key);

  final List<NativeView> roots;
  final ValueChanged<NativeView> onNodeTap;
  final NativeView? currentNativeView;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return SizedBox(
        height: constraints.maxHeight,
        child: ListView(
          children: roots
              .map(
                (e) => _Node(
                  nativeView: e,
                  onTap: onNodeTap,
                  currentNativeView: currentNativeView,
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
    required this.currentNativeView,
    required this.nativeView,
    required this.onTap,
  }) : super(key: key);

  final ValueChanged<NativeView> onTap;
  final NativeView? currentNativeView;
  final NativeView nativeView;

  @override
  Widget build(BuildContext context) {
    final className = nativeView.className ?? '';
    final resourceName = nativeView.resourceName ?? '';
    final nodeText =
        '$className${resourceName.isNotEmpty ? '<$resourceName>' : ''}';

    return GestureDetector(
      onTap: () => onTap(nativeView),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: identical(currentNativeView, nativeView)
                ? Theme.of(context).colorScheme.selectedRowBackgroundColor
                : null,
            child: Text(nodeText),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Column(
                children: nativeView.children
                    .map((e) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: _Node(
                            currentNativeView: currentNativeView,
                            nativeView: e,
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
