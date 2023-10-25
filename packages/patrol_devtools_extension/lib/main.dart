import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/widgets.dart';
import 'package:patrol_devtools_extension/patrol_devtools_extension.dart';

void main() {
  runApp(const PatrolPackageDevToolsExtension());
}

class PatrolPackageDevToolsExtension extends StatelessWidget {
  const PatrolPackageDevToolsExtension({super.key});

  @override
  Widget build(BuildContext context) {
    return const DevToolsExtension(
      child: PatrolDevToolsExtension(),
    );
  }
}
