import 'package:devtools_app_shared/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:patrol_devtools_extension/native_inspector/node.dart';
import 'package:patrol_devtools_extension/native_inspector/widgets/overflowing_flex.dart';

class NativeViewDetails extends StatelessWidget {
  const NativeViewDetails({super.key, required this.currentNode});

  final Node? currentNode;

  @override
  Widget build(BuildContext context) {
    return Column(
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
                  padding: const EdgeInsets.symmetric(horizontal: denseSpacing),
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
    );
  }
}

class _HeaderDecoration extends StatelessWidget {
  const _HeaderDecoration({required this.child});

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

class _NodeDetails extends StatelessWidget {
  const _NodeDetails({required this.node});

  final Node node;

  @override
  Widget build(BuildContext context) {
    final view = node.nativeView;
    final rows = [
      _KeyValueItem('applicationPackage:', view.applicationPackage),
      _KeyValueItem('childCount:', view.childCount),
      _KeyValueItem('className:', view.className),
      _KeyValueItem('contentDescription:', view.contentDescription),
      _KeyValueItem('enabled:', view.enabled),
      _KeyValueItem('focused:', view.focused),
      _KeyValueItem('resourceName:', view.resourceName),
      _KeyValueItem('text:', view.text),
    ];

    final unimportantTextStyle = TextStyle(
      color: Theme.of(context).colorScheme.isLight
          ? Colors.grey.shade500
          : Colors.grey.shade600,
    );

    return SelectionArea(
      child: OverflowingFlex(
        direction: Axis.horizontal,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...rows.map(
                (kvItem) => Container(
                  height: 32,
                  alignment: Alignment.center,
                  child: HookBuilder(
                    builder: (context) {
                      final displayCopyButton = useState(false);

                      return MouseRegion(
                        onEnter: (_) => displayCopyButton.value = true,
                        onExit: (_) => displayCopyButton.value = false,
                        child: Text(
                          kvItem.key,
                          style: kvItem.important ? null : unimportantTextStyle,
                          maxLines: 1,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...rows.map(
                  (kvItem) => HookBuilder(
                    builder: (context) {
                      final displayCopyButton = useState(false);

                      return SizedBox(
                        height: 32,
                        child: MouseRegion(
                          onEnter: (_) => displayCopyButton.value = true,
                          onExit: (_) => displayCopyButton.value = false,
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
                                  opacity: displayCopyButton.value ? 1 : 0,
                                  child: IconButton(
                                    iconSize: defaultIconSize,
                                    onPressed: displayCopyButton.value
                                        ? () {
                                            Clipboard.setData(
                                              ClipboardData(
                                                text: kvItem.copyValue,
                                              ),
                                            );
                                          }
                                        : null,
                                    icon: const Icon(Icons.copy),
                                  ),
                                ),
                              ),
                            ],
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
