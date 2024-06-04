part of 'node.dart';

final class NativeViewNode extends Node {
  NativeViewNode({
    required this.view,
    this.parent,
    required this.androidNode,
  }) {
    children = view.children
        .map(
          (e) => NativeViewNode(
            view: e,
            parent: this,
            androidNode: androidNode,
          ),
        )
        .toList();

    fullNodeName = createNodeName(view.className, view.resourceName);

    shortNodeName = _shortNodeName(
      view.className,
      view.resourceName,
    );

    initialCharacter = createInitialCharacter(shortNodeName);
  }

  final NativeView view;
  final bool androidNode;

  @override
  late final List<NativeViewNode> children;

  @override
  final NativeViewNode? parent;

  @override
  late final String fullNodeName;

  @override
  late final String initialCharacter;

  @override
  late final String shortNodeName;

  static List<String> ignoreTypePrefixes = ['android.widget.', 'android.view.'];

  String _shortNodeName(String? type, String? resourceName) {
    var typeName = type ?? '';

    if (androidNode && typeName.isNotEmpty) {
      for (final prefix in ignoreTypePrefixes) {
        if (typeName.startsWith(prefix)) {
          typeName = typeName.substring(prefix.length);
          break;
        }
      }
    }

    return createNodeName(typeName, resourceName);
  }
}
