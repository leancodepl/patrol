///
//  swift-format-ignore-file
//
//  Generated code. Do not modify.
//  source: schema.dart
//

import Telegraph

protocol NativeAutomatorServer {
    func initialize() throws
    func configure(request: ConfigureRequest) throws
    func openApp(request: OpenAppRequest) throws
    func markPatrolAppServiceReady() throws
}

extension NativeAutomatorServer {
    private func initializeHandler(request: HTTPRequest) throws -> HTTPResponse {
        try initialize()
        return HTTPResponse(.ok)
    }

    private func configureHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(ConfigureRequest.self, from: request.body)
        try configure(request: requestArg)
        return HTTPResponse(.ok)
    }
    
    private func openAppHandler(request: HTTPRequest) throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(OpenAppRequest.self, from: request.body)
        try openApp(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func markPatrolAppServiceReadyHandler(request: HTTPRequest) throws -> HTTPResponse {
        try markPatrolAppServiceReady()
        return HTTPResponse(.ok)
    }
}

extension NativeAutomatorServer {
    func setupRoutes(server: Server) {
        server.route(.POST, "initialize") {
            request in handleRequest(
                request: request,
                handler: initializeHandler)
        }
        server.route(.POST, "configure") {
            request in handleRequest(
                request: request,
                handler: configureHandler)
        }
        server.route(.POST, "openApp") {
            request in handleRequest(
                request: request,
                handler: openAppHandler)
        }
        server.route(.POST, "markPatrolAppServiceReady") {
            request in handleRequest(
                request: request,
                handler: markPatrolAppServiceReadyHandler)
        }
    }
}


extension NativeAutomatorServer {
    private func handleRequest(request: HTTPRequest, handler: @escaping (HTTPRequest) throws -> HTTPResponse) -> HTTPResponse {
        do {
            return try handler(request)
        } catch let err {
            return HTTPResponse(.badRequest, headers: [:], error: err)
        }
    }
}

