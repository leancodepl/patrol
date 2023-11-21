///
//  swift-format-ignore-file
//
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
    return try await performRequestWithResult(requestName: "listDartTests")
  }

  func runDartTest(request: RunDartTestRequest) async throws -> RunDartTestResponse {
    let body = try JSONEncoder().encode(request)
    return try await performRequestWithResult(requestName: "runDartTest", body: body)
  }

  private func performRequestWithResult<TResult: Decodable>(
      requestName: String, body: Data? = nil
  ) async throws -> TResult {
      let responseData = try await performRequest(requestName: requestName, body: body)
      let object = try JSONDecoder().decode(TResult.self, from: responseData)
      return object
  }

  private func performRequest(requestName: String, body: Data? = nil) async throws -> Data {
    let url = URL(string: "http://\(address):\(port)/\(requestName)")!

    let urlconfig = URLSessionConfiguration.default

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = body

    let session = URLSession(configuration: urlconfig)

    do {
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let message = "Invalid response: \(String(describing: response)) \(String(describing: data))"
            NSLog("Received invalid response: (message)")
            throw PatrolError.internal(message)
        }

        return data
    } catch {
        throw error
    }
  }
}
