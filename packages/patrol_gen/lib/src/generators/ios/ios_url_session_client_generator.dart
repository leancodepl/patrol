import 'package:patrol_gen/src/generators/ios/ios_config.dart';
import 'package:patrol_gen/src/generators/output_file.dart';
import 'package:patrol_gen/src/schema.dart';

class IOSURLSessionClientGenerator {
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
  private let timeout: TimeInterval

  init(port: Int, address: String, timeout: TimeInterval) {
    self.port = port
    self.address = address
    self.timeout = timeout
  }

$endpoints

  private func performRequest<TResult: Codable>(
    requestName: String, body: Data? = nil, completion: @escaping (Result<TResult, Error>) -> Void
  ) {
    let url = URL(string: "$url")!

    let urlconfig = URLSessionConfiguration.default
    urlconfig.timeoutIntervalForRequest = timeout
    urlconfig.timeoutIntervalForResource = timeout

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = body
    request.timeoutInterval = timeout

    let session = URLSession(configuration: urlconfig)

    session.dataTask(with: request) { data, response, error in
      if (response as? HTTPURLResponse)?.statusCode == 200 {
        do {
          let object = try JSONDecoder().decode(TResult.self, from: data!)
          completion(.success(object))
        } catch let err {
          completion(.failure(err))
        }
      } else {
        let message =
          "$exceptionMessage"
        completion(.failure(PatrolError.internal(message)))
      }
    }.resume()
  }
}
''';
  }

  String _createEndpoint(Endpoint endpoint) {
    final requestDef =
        endpoint.request != null ? 'request: ${endpoint.request!.name}' : '';

    final completionDef = endpoint.response != null
        ? 'completion: @escaping (Result<${endpoint.response!.name}, Error>) -> Void'
        : 'completion: @escaping (Result<Void, Error>) -> Void';

    final parameters = endpoint.request != null
        ? '$requestDef, $completionDef'
        : completionDef;

    final arguments = [
      'requestName: "${endpoint.name}"',
      if (endpoint.request != null) 'body: body',
      'completion: completion'
    ].join(', ');

    final bodyCode = endpoint.request != null
        ? '''
    do {
      let body = try JSONEncoder().encode(request)
      performRequest($arguments)
    } catch let err {
      completion(.failure(err))
    }'''
        : '    performRequest($arguments)';

    return '''
  func ${endpoint.name}($parameters) {
$bodyCode
  }''';
  }
}
