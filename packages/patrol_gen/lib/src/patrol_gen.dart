import 'package:patrol_gen/src/resolve_schema.dart';

class PatrolGenOptions {}

class PatrolGen {
  Future<void> run(String schemaPath) async {
    await resolveSchema(schemaPath);
  }
}
