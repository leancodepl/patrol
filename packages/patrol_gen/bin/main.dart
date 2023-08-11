import 'package:patrol_gen/src/patrol_gen.dart';

void main(List<String> args) {
  if (args.length == 1) {
    PatrolGen().run(args[0]);
  } else {
    print('''
You should only pass one argument (path to schema). Example:
dart run bin/main.dart ../schema.dart
''');
  }
}
