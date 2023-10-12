import 'package:flutter/material.dart';
import 'package:patrol_devtools_extension/native_inspector/node.dart';

class NodeDetails extends StatelessWidget {
  const NodeDetails({Key? key, required this.node}) : super(key: key);

  final Node node;

  @override
  Widget build(BuildContext context) {
    final rows = [
      ['applicationPackage:', '${node.nativeView.applicationPackage}'],
      ['childCount:', '${node.nativeView.childCount}'],
      ['className:', '${node.nativeView.className}'],
      ['contentDescription:', '${node.nativeView.contentDescription}'],
      ['enabled:', '${node.nativeView.enabled}'],
      ['focused:', '${node.nativeView.focused}'],
      ['resourceName:', '${node.nativeView.resourceName}'],
      ['text:', '${node.nativeView.text}'],
    ]
        .map(
          (e) => TableRow(
            children: [
              Text(e[0]),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(e[1]),
              )
            ],
          ),
        )
        .toList();

    return SelectionArea(
      child: Table(
        columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
        children: rows,
      ),
    );
  }
}
