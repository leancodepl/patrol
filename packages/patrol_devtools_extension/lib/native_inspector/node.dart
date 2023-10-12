import 'package:patrol_devtools_extension/api/contracts.dart';

class Node {
  Node(this.nativeView)
      : children = nativeView.children.map((e) => Node(e)).toList();

  final NativeView nativeView;
  final List<Node> children;
}
