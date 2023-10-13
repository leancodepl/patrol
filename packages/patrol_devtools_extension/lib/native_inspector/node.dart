import 'package:patrol_devtools_extension/api/contracts.dart';

class Node {
  Node(this.nativeView, this.androidNode, this.parent) {
    children =
        nativeView.children.map((e) => Node(e, androidNode, this)).toList();
    fullNodeName = _nodeName(nativeView.className, nativeView.resourceName);
    shortNodeName =
        _shortNodeName(nativeView.className, nativeView.resourceName);
  }

  final bool androidNode;
  final NativeView nativeView;
  final Node? parent;

  late final List<Node> children;
  late final String fullNodeName;
  late final String shortNodeName;

  static List<String> ignoreTypePrefixes = ['android.widget.', 'android.view.'];

  String _shortNodeName(String? type, String? resourceName) {
    String typeName = type ?? '';

    if (androidNode && typeName.isNotEmpty) {
      for (final prefix in ignoreTypePrefixes) {
        if (typeName.startsWith(prefix)) {
          typeName = typeName.substring(prefix.length);
          break;
        }
      }
    }

    return _nodeName(typeName, resourceName);
  }

  String _nodeName(String? type, String? resourceName) {
    if (resourceName == null || resourceName.isEmpty) {
      return '$type';
    }
    return "$type-[<'$resourceName'>]";
  }
}
