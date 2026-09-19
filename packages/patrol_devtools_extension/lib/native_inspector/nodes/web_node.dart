part of 'node.dart';

final class WebNode extends Node {
  WebNode({required this.view, this.parent}) {
    children = view.children
        .map((view) => WebNode(view: view, parent: this))
        .toList();

    // Prefer whatever a web selector would actually match on: the test id, then
    // the DOM id, then the accessible label. Falling back to the tag name alone
    // makes a Flutter web tree read as a wall of identical FLT-SEMANTICS nodes.
    final label = view.testId ?? view.id ?? view.ariaLabel ?? view.text;

    fullNodeName = createNodeName(view.tagName.toLowerCase(), label);

    shortNodeName = fullNodeName;

    initialCharacter = createInitialCharacter(view.tagName);
  }

  final WebNativeView view;

  @override
  late final List<WebNode> children;

  @override
  final WebNode? parent;

  @override
  late final String fullNodeName;

  @override
  late final String initialCharacter;

  @override
  late final String shortNodeName;
}
