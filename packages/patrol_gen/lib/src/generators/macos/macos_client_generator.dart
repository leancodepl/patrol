import 'package:patrol_gen/src/generators/ios/ios_config.dart';
import 'package:patrol_gen/src/generators/output_file.dart';
import 'package:patrol_gen/src/schema.dart';

class MacosClientGenerator {
  OutputFile generate(Service service, IOSConfig config) {
    final buffer = StringBuffer()
      ..write(_contentPrefix(config))
      ..write(_createClass(service));

    return OutputFile(
      filename: config.clientFileName(service.name),
      content: buffer.toString(),
    );
  }

  String _contentPrefix(IOSConfig config) {
    return '''
///
//  swift-format-ignore-file
//
//  Generated code. Do not modify.
//  source: schema.dart
//

''';
  }

  String _createClass(Service service) {
    final endpoints = service.endpoints.map(_createEndpoint).join('\n\n');

    const url = r'http://\(address):\(port)/\(requestName)';

    const exceptionMessage =
        r'Invalid response: \(String(describing: response)) \(String(describing: data))';

    return '''
class ${service.name}Client {
  private let port: Int
  private let address: String

  init(port: Int, address: String) {
    self.port = port
    self.address = address
  }

$endpoints

  private func performRequestWithResult<TResult: Decodable>(
      requestName: String, body: Data? = nil
  ) async throws -> TResult {
      let responseData = try await performRequest(requestName: requestName, body: body)
      let object = try JSONDecoder().decode(TResult.self, from: responseData)
      return object
  }

  private func performRequest(requestName: String, body: Data? = nil) async throws -> Data {
    let url = URL(string: "$url")!

    let urlconfig = URLSessionConfiguration.default

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = body

    let session = URLSession(configuration: urlconfig)

    do {
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let message = "$exceptionMessage"
            NSLog("Received invalid response: (message)")
            throw PatrolError.internal(message)
        }

        return data
    } catch {
        throw error
    }
  }
}
''';
  }

  String _createEndpoint(Endpoint endpoint) {
    final requestDef =
        endpoint.request != null ? 'request: ${endpoint.request!.name}' : '';

    final completionDef = 'async throws -> ${endpoint.response!.name}';

    final parameters = '($requestDef) $completionDef';

    final arguments = [
      'requestName: "${endpoint.name}"',
      if (endpoint.request != null) 'body: body',
    ].join(', ');

    const performRequest = 'performRequestWithResult';

    final bodyCode = endpoint.request != null
        ? '''
    let body = try JSONEncoder().encode(request)
    return try await $performRequest($arguments)'''
        : '    return try await $performRequest($arguments)';

    return '''
  func ${endpoint.name}$parameters {
$bodyCode
  }''';
  }
}
