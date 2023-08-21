import 'package:patrol_gen/src/generators/ios/ios_config.dart';
import 'package:patrol_gen/src/generators/output_file.dart';
import 'package:patrol_gen/src/schema.dart';

class IOSURLSessionClientGenerator {
  OutputFile generate(Service service, IOSConfig config) {
    final buffer = StringBuffer()..write(_contentPrefix(config));

    return OutputFile(
      filename: config.clientFileName(service.name),
      content: buffer.toString(),
    );
  }

  String _contentPrefix(IOSConfig config) {
    return '''
///
//  Generated code. Do not modify.
//  source: schema.dart
//

''';
  }
}
