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
    performRequestWithResult(requestName: "listDartTests", completion: completion)
  }

  func runDartTest(request: RunDartTestRequest, completion: @escaping (Result<RunDartTestResponse, Error>) -> Void) {
    do {
      let body = try JSONEncoder().encode(request)
      performRequestWithResult(requestName: "runDartTest", body: body, completion: completion)
    } catch let err {
      completion(.failure(err))
    }
  }

  private func performRequestWithResult<TResult: Decodable>(
    requestName: String, body: Data? = nil, completion: @escaping (Result<TResult, Error>) -> Void
  ) {
    performRequest(requestName: requestName, body: body) { result in
      switch result {
        case .success(let data):
          do {
            let object = try JSONDecoder().decode(TResult.self, from: data)
            completion(.success(object))
          } catch let err {
            completion(.failure(err))
          }
        case .failure(let error):
          completion(.failure(error))
      }
    }
  }

  private func performRequestWithEmptyResult(
    requestName: String, body: Data? = nil, completion: @escaping (Error?) -> Void
  ) {
    performRequest(requestName: requestName, body: body) { result in
      switch result {
        case .success(_):
          completion(nil)
        case .failure(let error):
          completion(error)
      }
    }
  }

  private func performRequest(
    requestName: String, body: Data? = nil, completion: @escaping (Result<Data, Error>) -> Void
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
        completion(.success(data!))
      } else {
        let message =
          "Invalid response: \(String(describing: response)) \(String(describing: data))"
        completion(.failure(PatrolError.internal(message)))
      }
    }.resume()
  }
}
