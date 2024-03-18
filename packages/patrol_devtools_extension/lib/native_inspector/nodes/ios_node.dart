part of 'node.dart';

final class IOSNode extends Node {
  IOSNode({required this.view, this.parent}) {
    children =
        view.children.map((view) => IOSNode(view: view, parent: this)).toList();

    fullNodeName = createNodeName(view.elementType.name, view.identifier);

    initialCharacter = createInitialCharacter(fullNodeName);
  }

  final IOSNativeView view;

  @override
  late final List<IOSNode> children;

  @override
  final IOSNode? parent;

  @override
  late final String fullNodeName;

  @override
  late final String initialCharacter;

  @override
  String get shortNodeName => fullNodeName;
}
