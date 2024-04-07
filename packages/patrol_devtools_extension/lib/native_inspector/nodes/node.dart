import 'package:patrol_devtools_extension/api/contracts.dart';

part 'android_node.dart';
part 'ios_node.dart';
part 'native_view_node.dart';

sealed class Node {
  List<Node> get children;
  Node? get parent;
  String get initialCharacter;
  String get fullNodeName;
  String get shortNodeName;

  String createNodeName(String? typeName, String? keyName) {
    if (keyName == null || keyName.isEmpty) {
      return '$typeName';
    }
    return "$typeName-[<'$keyName'>]";
  }

  String createInitialCharacter(String nodeName) {
    return nodeName.isNotEmpty ? nodeName[0].toUpperCase() : '';
  }
}
