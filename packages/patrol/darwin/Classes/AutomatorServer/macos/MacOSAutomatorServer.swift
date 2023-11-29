// #if PATROL_ENABLED

import Foundation
import FlyingFox

final class MacOSAutomatorServer: NativeAutomatorServer {
    private let automator: Automator
    
    private let onAppReady: (Bool) -> Void
    
    init(automator: Automator, onAppReady: @escaping (Bool) -> Void) {
        self.automator = automator
        self.onAppReady = onAppReady
    }
    
    func initialize() throws {}
    
    func configure(request: ConfigureRequest) throws {
        automator.configure(timeout: TimeInterval(request.findTimeoutMillis / 1000))
    }
    
    // MARK: General
    
    func pressHome() throws {
        return try runCatching {
            throw PatrolError.methodNotImplemented("pressHome")
        }
    }
    
    func pressBack() throws {
        return try runCatching {
            throw PatrolError.methodNotImplemented("pressBack")
        }
    }
    
    func pressRecentApps() throws {
        return try runCatching {
            throw PatrolError.methodNotImplemented("pressRecentApps")
        }
    }
    
    func doublePressRecentApps() throws {
        return try runCatching {
            throw PatrolError.methodNotImplemented("doublePressRecentApps")
        }
    }
    
    func openApp(request: OpenAppRequest) throws {
        return try runCatching {
            try automator.openApp(request.appId)
        }
    }
    
    func openQuickSettings(request: OpenQuickSettingsRequest) throws {
        return try runCatching {
            throw PatrolError.methodNotImplemented("openQuickSettings")
        }
    }
    
    // MARK: General UI interaction
    
    func getNativeViews(
        request: GetNativeViewsRequest
    ) throws -> GetNativeViewsResponse {
        return try runCatching {
            throw PatrolError.methodNotImplemented("getNativeViews")
        }
    }
    
    func tap(request: TapRequest) throws {
        return try runCatching {
            throw PatrolError.methodNotImplemented("tap")
        }
    }
    
    func doubleTap(request: TapRequest) throws {
        return try runCatching {
            throw PatrolError.methodNotImplemented("doubleTap")
        }
    }
    
    func enterText(request: EnterTextRequest) throws {
        return try runCatching {
            throw PatrolError.methodNotImplemented("enterText")
        }
    }
    
    func swipe(request: SwipeRequest) throws {
        return try runCatching {
            throw PatrolError.methodNotImplemented("swipe")
        }
    }
    
    func waitUntilVisible(request: WaitUntilVisibleRequest) throws {
        return try runCatching {
            throw PatrolError.methodNotImplemented("waitUntilVisible")
        }
    }
    
    // MARK: Services
    
    func enableAirplaneMode() throws {
        return try runCatching {
            throw PatrolError.methodNotImplemented("enableAirplaneMode")
        }
    }
    
    func disableAirplaneMode() throws {
        return try runCatching {
            throw PatrolError.methodNotImplemented("disableAirplaneMode")
        }
    }
    
    func enableWiFi() throws {
        return try runCatching {
            throw PatrolError.methodNotImplemented("enableWiFi")
        }
    }
    
    func disableWiFi() throws {
        return try runCatching {
            throw PatrolError.methodNotImplemented("disableWiFi")
        }
    }
    
    func enableCellular() throws {
        return try runCatching {
            throw PatrolError.methodNotImplemented("enableCellular")
        }
    }
    
    func disableCellular() throws {
        return try runCatching {
            throw PatrolError.methodNotImplemented("disableCellular")
        }
    }
    
    func getNativeUITree(request: GetNativeUITreeRequest) throws -> GetNativeUITreeRespone {
        //TODO: Implement
        return GetNativeUITreeRespone(roots: [])
    }
    
    func enableBluetooth() throws {
        return try runCatching {
            try automator.enableBluetooth()
        }
    }
    
    func disableBluetooth() throws {
        return try runCatching {
            try automator.disableBluetooth()
        }
    }
    
    func enableDarkMode(request: DarkModeRequest) throws {
        return try runCatching {
            throw PatrolError.methodNotImplemented("enableDarkMode")
        }
    }
    
    func disableDarkMode(request: DarkModeRequest) throws {
        return try runCatching {
            throw PatrolError.methodNotImplemented("disableDarkMode")
        }
    }
    
    // MARK: Notifications
    
    func openNotifications() throws {
        return try runCatching {
            try automator.openNotifications()
        }
    }
    
    func closeNotifications() throws {
        return try runCatching {
            throw PatrolError.methodNotImplemented("closeNotifications")
        }
    }
    
    func closeHeadsUpNotification() throws {
        return try runCatching {
            throw PatrolError.methodNotImplemented("closeHeadsUpNotification")
        }
    }
    
    func getNotifications(
        request: GetNotificationsRequest
    ) throws -> GetNotificationsResponse {
        return try runCatching {
            throw PatrolError.methodNotImplemented("getNotifications")
        }
    }
    
    func tapOnNotification(request: TapOnNotificationRequest) throws {
        return try runCatching {
            if let index = request.index {
                try automator.tapOnNotification(
                    byIndex: index
                )
            } else if let selector = request.selector {
                try automator.tapOnNotification(
                    bySubstring: selector.textContains ?? String()
                )
            } else {
                throw PatrolError.internal("tapOnNotification(): neither index nor selector are set")
            }
        }
    }
    
    // MARK: Permissions
    
    func isPermissionDialogVisible(
        request: PermissionDialogVisibleRequest
    ) throws -> PermissionDialogVisibleResponse {
        return try runCatching {
            let visible = automator.isPermissionDialogVisible(
                timeout: TimeInterval(request.timeoutMillis / 1000)
            )
            
            return PermissionDialogVisibleResponse(visible: visible)
        }
    }
    
    func handlePermissionDialog(request: HandlePermissionRequest) throws {
        return try runCatching {
            throw PatrolError.methodNotImplemented("handlePermissionDialog")
        }
    }
    
    func setLocationAccuracy(request: SetLocationAccuracyRequest) throws {
        return try runCatching {
            throw PatrolError.methodNotImplemented("setLocationAccuracy")
        }
    }
    
    func debug() throws {
        return try runCatching {
            throw PatrolError.methodNotImplemented("debug")
        }
    }
    
    private func runCatching<T>(_ block: () throws -> T) throws -> T {
        // TODO: Use an interceptor (like on Android)
        // See: https://github.com/grpc/grpc-swift/issues/1148
        do {
            return try block()
        } catch let err as PatrolError {
            Logger.shared.e(err.description)
            throw err
        } catch let err {
            throw PatrolError.unknown(err)
        }
    }
    
    func markPatrolAppServiceReady() throws {
        onAppReady(true)
    }
}

// #endif

extension NativeAutomatorServer {
    private func initializeHandler(request: HTTPRequest) throws -> HTTPResponse {
        try initialize()
        return HTTPResponse(statusCode: .ok)
    }

    private func configureHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try await JSONDecoder().decode(ConfigureRequest.self, from: request.bodyData)
        try configure(request: requestArg)
        return HTTPResponse(statusCode: .ok)
    }

    private func pressHomeHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try pressHome()
        return HTTPResponse(statusCode: .ok)
    }

    private func pressBackHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try pressBack()
        return HTTPResponse(statusCode: .ok)
    }

    private func pressRecentAppsHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try pressRecentApps()
        return HTTPResponse(statusCode: .ok)
    }

    private func doublePressRecentAppsHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try doublePressRecentApps()
        return HTTPResponse(statusCode: .ok)
    }

    private func openAppHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try await JSONDecoder().decode(OpenAppRequest.self, from: request.bodyData)
        try openApp(request: requestArg)
        return HTTPResponse(statusCode: .ok)
    }

    private func openQuickSettingsHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try await JSONDecoder().decode(OpenQuickSettingsRequest.self, from: request.bodyData)
        try openQuickSettings(request: requestArg)
        return HTTPResponse(statusCode: .ok)
    }

    private func getNativeUITreeHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try await JSONDecoder().decode(GetNativeUITreeRequest.self, from: request.bodyData)
        let response = try getNativeUITree(request: requestArg)
        let body = try JSONEncoder().encode(response)
        return HTTPResponse(statusCode: .ok, body: body)
    }

    private func getNativeViewsHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try await JSONDecoder().decode(GetNativeViewsRequest.self, from: request.bodyData)
        let response = try getNativeViews(request: requestArg)
        let body = try JSONEncoder().encode(response)
        return HTTPResponse(statusCode: .ok, body: body)
    }

    private func tapHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try await JSONDecoder().decode(TapRequest.self, from: request.bodyData)
        try tap(request: requestArg)
        return HTTPResponse(statusCode: .ok)
    }

    private func doubleTapHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try await JSONDecoder().decode(TapRequest.self, from: request.bodyData)
        try doubleTap(request: requestArg)
        return HTTPResponse(statusCode: .ok)
    }

    private func enterTextHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try await JSONDecoder().decode(EnterTextRequest.self, from: request.bodyData)
        try enterText(request: requestArg)
        return HTTPResponse(statusCode: .ok)
    }

    private func swipeHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try await JSONDecoder().decode(SwipeRequest.self, from: request.bodyData)
        try swipe(request: requestArg)
        return HTTPResponse(statusCode: .ok)
    }

    private func waitUntilVisibleHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try await JSONDecoder().decode(WaitUntilVisibleRequest.self, from: request.bodyData)
        try waitUntilVisible(request: requestArg)
        return HTTPResponse(statusCode: .ok)
    }

    private func enableAirplaneModeHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try enableAirplaneMode()
        return HTTPResponse(statusCode: .ok)
    }

    private func disableAirplaneModeHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try disableAirplaneMode()
        return HTTPResponse(statusCode: .ok)
    }

    private func enableWiFiHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try enableWiFi()
        return HTTPResponse(statusCode: .ok)
    }

    private func disableWiFiHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try disableWiFi()
        return HTTPResponse(statusCode: .ok)
    }

    private func enableCellularHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try enableCellular()
        return HTTPResponse(statusCode: .ok)
    }

    private func disableCellularHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try disableCellular()
        return HTTPResponse(statusCode: .ok)
    }

    private func enableBluetoothHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try enableBluetooth()
        return HTTPResponse(statusCode: .ok)
    }

    private func disableBluetoothHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try disableBluetooth()
        return HTTPResponse(statusCode: .ok)
    }

    private func enableDarkModeHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try await JSONDecoder().decode(DarkModeRequest.self, from: request.bodyData)
        try enableDarkMode(request: requestArg)
        return HTTPResponse(statusCode: .ok)
    }

    private func disableDarkModeHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try await JSONDecoder().decode(DarkModeRequest.self, from: request.bodyData)
        try disableDarkMode(request: requestArg)
        return HTTPResponse(statusCode: .ok)
    }

    private func openNotificationsHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try openNotifications()
        return HTTPResponse(statusCode: .ok)
    }

    private func closeNotificationsHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try closeNotifications()
        return HTTPResponse(statusCode: .ok)
    }

    private func closeHeadsUpNotificationHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try closeHeadsUpNotification()
        return HTTPResponse(statusCode: .ok)
    }

    private func getNotificationsHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try await JSONDecoder().decode(GetNotificationsRequest.self, from: request.bodyData)
        let response = try getNotifications(request: requestArg)
        let body = try JSONEncoder().encode(response)
        return HTTPResponse(statusCode: .ok, body: body)
    }

    private func tapOnNotificationHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try await JSONDecoder().decode(TapOnNotificationRequest.self, from: request.bodyData)
        try tapOnNotification(request: requestArg)
        return HTTPResponse(statusCode: .ok)
    }

    private func isPermissionDialogVisibleHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try await JSONDecoder().decode(PermissionDialogVisibleRequest.self, from: request.bodyData)
        let response = try isPermissionDialogVisible(request: requestArg)
        let body = try JSONEncoder().encode(response)
        return HTTPResponse(statusCode: .ok, body: body)
    }

    private func handlePermissionDialogHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try await JSONDecoder().decode(HandlePermissionRequest.self, from: request.bodyData)
        try handlePermissionDialog(request: requestArg)
        return HTTPResponse(statusCode: .ok)
    }

    private func setLocationAccuracyHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try await JSONDecoder().decode(SetLocationAccuracyRequest.self, from: request.bodyData)
        try setLocationAccuracy(request: requestArg)
        return HTTPResponse(statusCode: .ok)
    }

    private func debugHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try debug()
        return HTTPResponse(statusCode: .ok)
    }

    private func markPatrolAppServiceReadyHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try markPatrolAppServiceReady()
        return HTTPResponse(statusCode: .ok)
    }
}

extension NativeAutomatorServer {
    func setupRoutes(server: HTTPServer) async {
        await server.appendRoute("/initialize") { request in
            return await handleRequest(
                request: request,
                handler: initializeHandler)
        }
        await server.appendRoute("/configure") { request in
            return await handleRequest(
                request: request,
                handler: configureHandler)
        }
        await server.appendRoute("/pressHome") { request in
            return await handleRequest(
                request: request,
                handler: pressHomeHandler)
        }
        await server.appendRoute("/pressBack") { request in
            return await handleRequest(
                request: request,
                handler: pressBackHandler)
        }
        await server.appendRoute("/pressRecentApps") { request in
            return await handleRequest(
                request: request,
                handler: pressRecentAppsHandler)
        }
        await server.appendRoute("/doublePressRecentApps") { request in
            return await handleRequest(
                request: request,
                handler: doublePressRecentAppsHandler)
        }
        await server.appendRoute("/openApp") { request in
            return await handleRequest(
                request: request,
                handler: openAppHandler)
        }
        await server.appendRoute("/openQuickSettings") { request in
            return await handleRequest(
                request: request,
                handler: openQuickSettingsHandler)
        }
        await server.appendRoute("/getNativeUITree") { request in
            return await handleRequest(
                request: request,
                handler: getNativeUITreeHandler)
        }
        await server.appendRoute("/getNativeViews") { request in
            return await handleRequest(
                request: request,
                handler: getNativeViewsHandler)
        }
        await server.appendRoute("/tap") { request in
            return await handleRequest(
                request: request,
                handler: tapHandler)
        }
        await server.appendRoute("/doubleTap") { request in
            return await handleRequest(
                request: request,
                handler: doubleTapHandler)
        }
        await server.appendRoute("/enterText") { request in
            return await handleRequest(
                request: request,
                handler: enterTextHandler)
        }
        await server.appendRoute("/swipe") { request in
            return await handleRequest(
                request: request,
                handler: swipeHandler)
        }
        await server.appendRoute("/waitUntilVisible") { request in
            return await handleRequest(
                request: request,
                handler: waitUntilVisibleHandler)
        }
        await server.appendRoute("/enableAirplaneMode") { request in
            return await handleRequest(
                request: request,
                handler: enableAirplaneModeHandler)
        }
        await server.appendRoute("/disableAirplaneMode") { request in
            return await handleRequest(
                request: request,
                handler: disableAirplaneModeHandler)
        }
        await server.appendRoute("/enableWiFi") { request in
            return await handleRequest(
                request: request,
                handler: enableWiFiHandler)
        }
        await server.appendRoute("/disableWiFi") { request in
            return await handleRequest(
                request: request,
                handler: disableWiFiHandler)
        }
        await server.appendRoute("/enableCellular") { request in
            return await handleRequest(
                request: request,
                handler: enableCellularHandler)
        }
        await server.appendRoute("/disableCellular") { request in
            return await handleRequest(
                request: request,
                handler: disableCellularHandler)
        }
        await server.appendRoute("/enableBluetooth") { request in
            return await handleRequest(
                request: request,
                handler: enableBluetoothHandler)
        }
        await server.appendRoute("/disableBluetooth") { request in
            return await handleRequest(
                request: request,
                handler: disableBluetoothHandler)
        }
        await server.appendRoute("/enableDarkMode") { request in
            return await handleRequest(
                request: request,
                handler: enableDarkModeHandler)
        }
        await server.appendRoute("/disableDarkMode") { request in
            return await handleRequest(
                request: request,
                handler: disableDarkModeHandler)
        }
        await server.appendRoute("/openNotifications") { request in
            return await handleRequest(
                request: request,
                handler: openNotificationsHandler)
        }
        await server.appendRoute("/closeNotifications") { request in
            return await handleRequest(
                request: request,
                handler: closeNotificationsHandler)
        }
        await server.appendRoute("/closeHeadsUpNotification") { request in
            return await handleRequest(
                request: request,
                handler: closeHeadsUpNotificationHandler)
        }
        await server.appendRoute("/getNotifications") { request in
            return await handleRequest(
                request: request,
                handler: getNotificationsHandler)
        }
        await server.appendRoute("/tapOnNotification") { request in
            return await handleRequest(
                request: request,
                handler: tapOnNotificationHandler)
        }
        await server.appendRoute("/isPermissionDialogVisible") { request in
            return await handleRequest(
                request: request,
                handler: isPermissionDialogVisibleHandler)
        }
        await server.appendRoute("/handlePermissionDialog") { request in
            return await handleRequest(
                request: request,
                handler: handlePermissionDialogHandler)
        }
        await server.appendRoute("/setLocationAccuracy") { request in
            return await handleRequest(
                request: request,
                handler: setLocationAccuracyHandler)
        }
        await server.appendRoute("/debug") { request in
            return await handleRequest(
                request: request,
                handler: debugHandler)
        }
        await server.appendRoute("/markPatrolAppServiceReady") { request in
            return await handleRequest(
                request: request,
                handler: markPatrolAppServiceReadyHandler)
        }
    }
}

extension NativeAutomatorServer {
    private func handleRequest(request: HTTPRequest, handler: @escaping (HTTPRequest) async throws -> HTTPResponse) async -> HTTPResponse {
        do {
            return try await handler(request)
        } catch let err {
            return HTTPResponse(statusCode: .badRequest, headers: [:], body: err.localizedDescription.utf8Data)
        }
    }
}

extension String {
  var utf8Data: Data {
    return data(using: .utf8)!
  }
}