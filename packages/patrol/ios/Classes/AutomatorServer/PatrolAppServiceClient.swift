///
//  swift-format-ignore-file
//
//  Generated code. Do not modify.
//  source: schema.dart
//

class PatrolAppServiceClient {
  private let port: Int
  private let address: String
  private let timeout: TimeInterval

  init(port: Int, address: String, timeout: TimeInterval) {
    self.port = port
    self.address = address
    self.timeout = timeout
  }

  func listDartTests(completion: @escaping (Result<ListDartTestsResponse, Error>) -> Void) {
    performRequest(requestName: "listDartTests", completion: completion)
  }

  func runDartTest(request: RunDartTestRequest, completion: @escaping (Result<RunDartTestResponse, Error>) -> Void) {
    do {
      let body = try JSONEncoder().encode(request)
      performRequest(requestName: "runDartTest", body: body, completion: completion)
    } catch let err {
      completion(.failure(err))
    }
  }

  private func performRequest<TResult: Codable>(
    requestName: String, body: Data? = nil, completion: @escaping (Result<TResult, Error>) -> Void
  ) {
    let url = URL(string: "http://\(address):\(port)/\(requestName)")!

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
          "Invalid response: \(String(describing: response)) \(String(describing: data))"
        completion(.failure(PatrolError.internal(message)))
      }
    }.resume()
  }
}
