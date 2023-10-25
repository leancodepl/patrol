import 'package:devtools_app_shared/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:patrol_devtools_extension/native_inspector/node.dart';

class NodeDetails extends StatelessWidget {
  const NodeDetails({super.key, required this.node});

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
      child: ListView(
        children: rows
            .map(
              (item) => HookBuilder(
                builder: (context) {
                  final displayCopyButton = useState(false);

                  return MouseRegion(
                    onEnter: (e) {
                      displayCopyButton.value = true;
                    },
                    onExit: (e) {
                      displayCopyButton.value = false;
                    },
                    child: Row(
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.key),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  item.value,
                                  style: item.important
                                      ? null
                                      : unimportantTextStyle,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Opacity(
                          opacity: displayCopyButton.value ? 1 : 0,
                          child: IconButton(
                            iconSize: defaultIconSize,
                            onPressed: displayCopyButton.value
                                ? () {
                                    Clipboard.setData(
                                      ClipboardData(text: item.copyValue),
                                    );
                                  }
                                : null,
                            icon: const Icon(Icons.copy),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
            .toList(),
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
