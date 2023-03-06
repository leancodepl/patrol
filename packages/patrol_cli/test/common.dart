import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:test/test.dart';

final throwsToolExit = throwsA(isToolExit);
const isToolExit = TypeMatcher<ToolExit>();
