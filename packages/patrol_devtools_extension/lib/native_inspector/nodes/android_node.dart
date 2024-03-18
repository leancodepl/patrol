part of 'node.dart';

final class AndroidNode extends Node {
  AndroidNode({required this.view, this.parent}) {
    children = view.children
        .map((view) => AndroidNode(view: view, parent: this))
        .toList();

    fullNodeName = createNodeName(view.className, view.resourceName);

    shortNodeName = _shortNodeName(
      view.className,
      view.resourceName,
    );

    initialCharacter = createInitialCharacter(shortNodeName);
  }

  final AndroidNativeView view;

  @override
  late final List<AndroidNode> children;

  @override
  final AndroidNode? parent;

  @override
  late final String fullNodeName;

  @override
  late final String initialCharacter;

  @override
  late final String shortNodeName;

  static final List<String> _ignoreTypePrefixes = [
    'android.widget.',
    'android.view.',
  ];

  String _shortNodeName(String? type, String? resourceName) {
    var typeName = type ?? '';

    if (typeName.isNotEmpty) {
      for (final prefix in _ignoreTypePrefixes) {
        if (typeName.startsWith(prefix)) {
          typeName = typeName.substring(prefix.length);
          break;
        }
      }
    }

    return createNodeName(typeName, resourceName);
  }
}
