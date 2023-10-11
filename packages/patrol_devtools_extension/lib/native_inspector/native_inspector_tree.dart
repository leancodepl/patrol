import 'package:flutter/widgets.dart';
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
    return Column(
      children: roots.map((e) => _Root(root: e, onTap: onNodeTap)).toList(),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root({Key? key, required this.root, required this.onTap})
      : super(key: key);

  final NativeView root;
  final ValueChanged<NativeView> onTap;

  @override
  Widget build(BuildContext context) {
    final name = root.applicationPackage ?? 'root';
    return GestureDetector(
      onTap: () => onTap(root),
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
