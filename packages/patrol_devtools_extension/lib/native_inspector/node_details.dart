import 'package:devtools_app_shared/ui.dart';
import 'package:flutter/material.dart';
import 'package:patrol_devtools_extension/native_inspector/node.dart';

class NodeDetails extends StatelessWidget {
  const NodeDetails({Key? key, required this.node}) : super(key: key);

  final Node node;

  @override
  Widget build(BuildContext context) {
    final view = node.nativeView;
    final rows = [
      _KeyValueItem('applicationPackage:', '${view.applicationPackage}',
          view.applicationPackage != null),
      _KeyValueItem(
          'childCount:', '${view.childCount}', view.childCount != null),
      _KeyValueItem('className:', '${view.className}', view.className != null),
      _KeyValueItem('contentDescription:', '${view.contentDescription}',
          view.contentDescription != null),
      _KeyValueItem('enabled:', '${view.enabled}', true),
      _KeyValueItem('focused:', '${view.focused}', true),
      _KeyValueItem(
          'resourceName:', '${view.resourceName}', view.resourceName != null),
      _KeyValueItem('text:', '${view.text}', view.text != null),
    ];

    final unimportantTextStyle = TextStyle(
        color: Theme.of(context).colorScheme.isLight
            ? Colors.grey.shade500
            : Colors.grey.shade600);

    return SelectionArea(
      child: Table(
        columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
        children: rows
            .map(
              (e) => TableRow(
                children: [
                  Text(e.key),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      e.value,
                      style: e.important ? null : unimportantTextStyle,
                    ),
                  )
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

class _KeyValueItem {
  const _KeyValueItem(this.key, this.value, this.important);
  final String key;
  final String value;
  final bool important;
}
