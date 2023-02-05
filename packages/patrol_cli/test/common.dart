import 'package:patrol_cli/src/common/tool_exit.dart';
import 'package:test/test.dart';

final throwsToolExit = throwsA(isToolExit);
const isToolExit = TypeMatcher<ToolExit>();
