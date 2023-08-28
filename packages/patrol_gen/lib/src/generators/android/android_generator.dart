import 'package:patrol_gen/src/generators/android/android_config.dart';
import 'package:patrol_gen/src/generators/android/android_contracts_generator.dart';
import 'package:patrol_gen/src/generators/output_file.dart';
import 'package:patrol_gen/src/schema.dart';

class AndroidGenerator {
  List<OutputFile> generate(Schema schema, AndroidConfig config) {
    final result = [
      AndroidContractsGenerator().generate(schema, config),
    ];

    return result;
  }
}
