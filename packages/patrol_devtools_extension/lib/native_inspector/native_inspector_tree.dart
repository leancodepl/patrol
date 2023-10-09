import 'package:flutter/widgets.dart';
import 'package:patrol_devtools_extension/api/contracts.dart';

class NativeInspectorTree extends StatelessWidget {
  const NativeInspectorTree({Key? key, required this.roots}) : super(key: key);

  final List<NativeView> roots;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: roots.map((e) => _Root(root: e)).toList(),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root({Key? key, required this.root}) : super(key: key);

  final NativeView root;

  @override
  Widget build(BuildContext context) {
    final name = root.applicationPackage ?? 'root';
    return Container(
      child: Text('[$name]'),
    );
  }
}

// class _Expandable extends StatelessWidget {
//   const _Expandable({Key? key, required this.root, required this.nativeView})
//       : super(key: key);

//   final bool root;
//   final NativeView nativeView;

//   @override
//   Widget build(BuildContext context) {
//     return Container(child: Text(context.));
//   }
// }
