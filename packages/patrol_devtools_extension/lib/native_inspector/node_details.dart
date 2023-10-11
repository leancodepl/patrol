import 'package:flutter/material.dart';
import 'package:patrol_devtools_extension/api/contracts.dart';

class NodeDetails extends StatelessWidget {
  const NodeDetails({Key? key, required this.node}) : super(key: key);

  final NativeView node;

  @override
  Widget build(BuildContext context) {
    final rows = [
      ['applicationPackage:', '${node.applicationPackage}'],
      ['childCount:', '${node.childCount}'],
      ['className:', '${node.className}'],
      ['contentDescription:', '${node.contentDescription}'],
      ['enabled:', '${node.enabled}'],
      ['focused:', '${node.focused}'],
      ['resourceName:', '${node.resourceName}'],
      ['text:', '${node.text}'],
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
