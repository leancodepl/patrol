import 'package:collection/collection.dart';
import 'package:devtools_app_shared/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:patrol_devtools_extension/api/contracts.dart';
import 'package:patrol_devtools_extension/native_inspector/nodes/node.dart';
import 'package:patrol_devtools_extension/native_inspector/widgets/overflowing_flex.dart';

class NativeViewDetails extends StatelessWidget {
  const NativeViewDetails({super.key, required this.currentNode});

  final Node? currentNode;

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      child: Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _HeaderDecoration(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: denseSpacing),
                child: SizedBox(
                  width: double.infinity,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Native view details',
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: currentNode != null
                  ? Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: denseSpacing),
                      child: _NodeDetails(node: currentNode!),
                    )
                  : Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(densePadding),
                      child: const Text(
                        'Select a node to view its details',
                        textAlign: TextAlign.center,
                        maxLines: 4,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderDecoration extends StatelessWidget {
  const _HeaderDecoration({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: defaultHeaderHeight,
      decoration: BoxDecoration(
        border: Border(
          bottom: defaultBorderSide(Theme.of(context)),
        ),
      ),
      child: child,
    );
  }
}

class _NodeDetails extends HookWidget {
  const _NodeDetails({required this.node});

  final Node node;

  void _onCopyClick(BuildContext context, _KeyValueItem kvItem) {
    Clipboard.setData(ClipboardData(text: kvItem.copyValue));

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied ${kvItem.copyValue}', maxLines: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hoveredIndex = useState<int?>(null);

    final items = switch (node) {
      final NativeViewNode n => [
          ('pkg:', n.view.applicationPackage),
          ('childCount:', n.view.childCount),
          ('className:', n.view.className),
          ('contentDescription:', n.view.contentDescription),
          ('enabled:', n.view.enabled),
          ('focused:', n.view.focused),
          ('resourceId:', n.view.resourceName),
          ('text:', n.view.text),
        ],
      final AndroidNode n => [
          ('text:', n.view.text),
          ('className:', n.view.className),
          ('resourceName:', n.view.resourceName),
          ('contentDescription:', n.view.contentDescription),
          ('applicationPackage:', n.view.applicationPackage),
          ('childCount:', n.view.childCount),
          ('isCheckable:', n.view.isCheckable),
          ('isChecked:', n.view.isChecked),
          ('isClickable:', n.view.isClickable),
          ('isEnabled:', n.view.isEnabled),
          ('isFocusable:', n.view.isFocusable),
          ('isFocused:', n.view.isFocused),
          ('isLongClickable:', n.view.isLongClickable),
          ('isScrollable:', n.view.isScrollable),
          ('isSelected:', n.view.isSelected),
          ('visibleBounds:', n.view.visibleBounds._toDisplayValue()),
          ('visibleCenter:', n.view.visibleCenter._toDisplayValue()),
        ],
      final IOSNode n => [
          ('elementType:', n.view.elementType.name),
          ('identifier:', n.view.identifier),
          ('isEnabled:', n.view.isEnabled),
          ('isSelected:', n.view.isSelected),
          ('hasFocus:', n.view.hasFocus),
          ('label:', n.view.label),
          ('title:', n.view.title),
          ('placeholderValue:', n.view.placeholderValue),
          ('value:', n.view.value),
          ('frame:', n.view.frame._toDisplayValue()),
        ]
    };

    final rows = items.map((e) => _KeyValueItem(e.$1, e.$2)).toList();

    final unimportantTextStyle = TextStyle(
      color: Theme.of(context).colorScheme.isLight
          ? Colors.grey.shade500
          : Colors.grey.shade600,
    );

    return SelectionArea(
      child: OverflowingFlex(
        direction: Axis.horizontal,
        children: [
          IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...rows.mapIndexed(
                  (index, kvItem) => Builder(
                    builder: (context) {
                      final hovered = hoveredIndex.value == index;

                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _onCopyClick(context, kvItem),
                        child: MouseRegion(
                          onEnter: (_) => hoveredIndex.value = index,
                          onExit: (_) => hoveredIndex.value = null,
                          child: Container(
                            height: 32,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(8),
                              ),
                              color: hovered
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                  : null,
                            ),
                            child: Text(
                              kvItem.key,
                              style: kvItem.important
                                  ? null
                                  : unimportantTextStyle,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...rows.mapIndexed(
                  (index, kvItem) => Builder(
                    builder: (context) {
                      final hovered = hoveredIndex.value == index;

                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _onCopyClick(context, kvItem),
                        child: Container(
                          height: 32,
                          padding: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(8),
                            ),
                            color: hovered
                                ? Theme.of(context).colorScheme.primaryContainer
                                : null,
                          ),
                          child: MouseRegion(
                            onEnter: (_) => hoveredIndex.value = index,
                            onExit: (_) => hoveredIndex.value = null,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      kvItem.value,
                                      maxLines: 1,
                                      style: kvItem.important
                                          ? null
                                          : unimportantTextStyle,
                                    ),
                                    SizedBox(width: defaultIconSize * 2),
                                  ],
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Opacity(
                                    opacity: hovered ? 1 : 0,
                                    child: const Icon(Icons.copy),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension _RectangleExtension on Rectangle {
  String _toDisplayValue() {
    return 'minX: ${minX.toInt()}, minY: ${minY.toInt()}, maxX: ${maxX.toInt()}, maxY: ${maxY.toInt()}';
  }
}

extension _Point2DExtension on Point2D {
  String _toDisplayValue() {
    return 'x: ${x.toInt()}, y: ${y.toInt()}';
  }
}

class _KeyValueItem {
  _KeyValueItem(this.key, Object? val) : important = val != null {
    value = switch (val) {
      null => 'null',
      final String v => '"$v"',
      _ => val.toString(),
    };

    copyValue = '$key $value';
  }

  final String key;
  late final String value;
  late final String copyValue;
  final bool important;
}
