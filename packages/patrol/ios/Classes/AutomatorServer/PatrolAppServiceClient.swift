///
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

  func listDartTests() async throws -> ListDartTestsResponse {
    return try await performRequest(requestName: "listDartTests")
  }

  func runDartTest(request: RunDartTestRequest) async throws -> RunDartTestResponse {
    let body = try JSONEncoder().encode(request)
    return try await performRequest(requestName: "runDartTest", body: body)
  }

  private func performRequest<TResult: Codable>(requestName: String, body: Data? = nil) async throws -> TResult {
    let url = URL(string: "http://\(address):\(port)/\(requestName)")!

    let urlconfig = URLSessionConfiguration.default
    urlconfig.timeoutIntervalForRequest = timeout
    urlconfig.timeoutIntervalForResource = timeout

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = body
    request.timeoutInterval = timeout

    let (data, response) = try await URLSession(configuration: urlconfig).data(for: request)
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
        throw PatrolError.internal("Invalid response: \(response) \(data)")
    }
    
    return try JSONDecoder().decode(TResult.self, from: data)
  }
}
