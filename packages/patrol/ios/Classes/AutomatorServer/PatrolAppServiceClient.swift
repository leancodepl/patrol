///
//  Generated code. Do not modify.
//  source: schema.dart
//

class PatrolAppServiceClient {
  private let port: Int
  private let address: String

  init(port: Int, address: String) {
    self.port = port
    self.address = address
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

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = body

    let (data, response) = try await URLSession.shared.data(for: request)
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
        throw PatrolError.internal("Invalid response: \(response) \(data)")
    }
    
    return try JSONDecoder().decode(TResult.self, from: data)
  }
}
