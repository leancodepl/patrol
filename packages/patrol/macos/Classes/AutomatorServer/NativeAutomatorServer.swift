///
//  Generated code. Do not modify.
//  source: schema.dart
//

import FlyingFox

protocol NativeAutomatorServer {
    func initialize() async throws
    func configure(request: ConfigureRequest) async throws
    func pressHome() async throws
    func pressBack() async throws
    func pressRecentApps() async throws
    func doublePressRecentApps() async throws
    func openApp(request: OpenAppRequest) async throws
    func openQuickSettings(request: OpenQuickSettingsRequest) async throws
    func getNativeViews(request: GetNativeViewsRequest) async throws -> GetNativeViewsResponse
    func tap(request: TapRequest) async throws
    func doubleTap(request: TapRequest) async throws
    func enterText(request: EnterTextRequest) async throws
    func swipe(request: SwipeRequest) async throws
    func waitUntilVisible(request: WaitUntilVisibleRequest) async throws
    func enableAirplaneMode() async throws
    func disableAirplaneMode() async throws
    func enableWiFi() async throws
    func disableWiFi() async throws
    func enableCellular() async throws
    func disableCellular() async throws
    func enableBluetooth() async throws
    func disableBluetooth() async throws
    func enableDarkMode(request: DarkModeRequest) async throws
    func disableDarkMode(request: DarkModeRequest) async throws
    func openNotifications() async throws
    func closeNotifications() async throws
    func closeHeadsUpNotification() async throws
    func getNotifications(request: GetNotificationsRequest) async throws -> GetNotificationsResponse
    func tapOnNotification(request: TapOnNotificationRequest) async throws
    func isPermissionDialogVisible(request: PermissionDialogVisibleRequest) async throws -> PermissionDialogVisibleResponse
    func handlePermissionDialog(request: HandlePermissionRequest) async throws
    func setLocationAccuracy(request: SetLocationAccuracyRequest) async throws
    func debug() async throws
    func markPatrolAppServiceReady() async throws
}

extension NativeAutomatorServer {
    private func initializeHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try await initialize()
        return HTTPResponse(statusCode: .ok)
    }

    private func configureHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try await JSONDecoder().decode(ConfigureRequest.self, from: request.bodyData)
        try await configure(request: requestArg)
        return HTTPResponse(statusCode: .ok)
    }

    private func pressHomeHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try await pressHome()
        return HTTPResponse(statusCode: .ok)
    }

    private func pressBackHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try await pressBack()
        return HTTPResponse(statusCode: .ok)
    }

    private func pressRecentAppsHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try await pressRecentApps()
        return HTTPResponse(statusCode: .ok)
    }

    private func doublePressRecentAppsHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try await doublePressRecentApps()
        return HTTPResponse(statusCode: .ok)
    }

    private func openAppHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try await JSONDecoder().decode(OpenAppRequest.self, from: request.bodyData)
        try await openApp(request: requestArg)
        return HTTPResponse(statusCode: .ok)
    }

    private func openQuickSettingsHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try await JSONDecoder().decode(OpenQuickSettingsRequest.self, from: request.bodyData)
        try await openQuickSettings(request: requestArg)
        return HTTPResponse(statusCode: .ok)
    }

    private func getNativeViewsHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try await JSONDecoder().decode(GetNativeViewsRequest.self, from: request.bodyData)
        let response = try await getNativeViews(request: requestArg)
        let body = try JSONEncoder().encode(response)
        return HTTPResponse(statusCode: .ok, body: body)
    }

    private func tapHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try await JSONDecoder().decode(TapRequest.self, from: request.bodyData)
        try await tap(request: requestArg)
        return HTTPResponse(statusCode: .ok)
    }

    private func doubleTapHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try await JSONDecoder().decode(TapRequest.self, from: request.bodyData)
        try await doubleTap(request: requestArg)
        return HTTPResponse(statusCode: .ok)
    }

    private func enterTextHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try await JSONDecoder().decode(EnterTextRequest.self, from: request.bodyData)
        try await enterText(request: requestArg)
        return HTTPResponse(statusCode: .ok)
    }

    private func swipeHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try await JSONDecoder().decode(SwipeRequest.self, from: request.bodyData)
        try await swipe(request: requestArg)
        return HTTPResponse(statusCode: .ok)
    }

    private func waitUntilVisibleHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try await JSONDecoder().decode(WaitUntilVisibleRequest.self, from: request.bodyData)
        try await waitUntilVisible(request: requestArg)
        return HTTPResponse(statusCode: .ok)
    }

    private func enableAirplaneModeHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try await enableAirplaneMode()
        return HTTPResponse(statusCode: .ok)
    }

    private func disableAirplaneModeHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try await disableAirplaneMode()
        return HTTPResponse(statusCode: .ok)
    }

    private func enableWiFiHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try await enableWiFi()
        return HTTPResponse(statusCode: .ok)
    }

    private func disableWiFiHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try await disableWiFi()
        return HTTPResponse(statusCode: .ok)
    }

    private func enableCellularHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try await enableCellular()
        return HTTPResponse(statusCode: .ok)
    }

    private func disableCellularHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try await disableCellular()
        return HTTPResponse(statusCode: .ok)
    }

    private func enableBluetoothHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try await enableBluetooth()
        return HTTPResponse(statusCode: .ok)
    }

    private func disableBluetoothHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try await disableBluetooth()
        return HTTPResponse(statusCode: .ok)
    }

    private func enableDarkModeHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try await JSONDecoder().decode(DarkModeRequest.self, from: request.bodyData)
        try await enableDarkMode(request: requestArg)
        return HTTPResponse(statusCode: .ok)
    }

    private func disableDarkModeHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try await JSONDecoder().decode(DarkModeRequest.self, from: request.bodyData)
        try await disableDarkMode(request: requestArg)
        return HTTPResponse(statusCode: .ok)
    }

    private func openNotificationsHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try await openNotifications()
        return HTTPResponse(statusCode: .ok)
    }

    private func closeNotificationsHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try await closeNotifications()
        return HTTPResponse(statusCode: .ok)
    }

    private func closeHeadsUpNotificationHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try await closeHeadsUpNotification()
        return HTTPResponse(statusCode: .ok)
    }

    private func getNotificationsHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try await JSONDecoder().decode(GetNotificationsRequest.self, from: request.bodyData)
        let response = try await getNotifications(request: requestArg)
        let body = try JSONEncoder().encode(response)
        return HTTPResponse(statusCode: .ok, body: body)
    }

    private func tapOnNotificationHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try await JSONDecoder().decode(TapOnNotificationRequest.self, from: request.bodyData)
        try await tapOnNotification(request: requestArg)
        return HTTPResponse(statusCode: .ok)
    }

    private func isPermissionDialogVisibleHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try await JSONDecoder().decode(PermissionDialogVisibleRequest.self, from: request.bodyData)
        let response = try await isPermissionDialogVisible(request: requestArg)
        let body = try JSONEncoder().encode(response)
        return HTTPResponse(statusCode: .ok, body: body)
    }

    private func handlePermissionDialogHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try await JSONDecoder().decode(HandlePermissionRequest.self, from: request.bodyData)
        try await handlePermissionDialog(request: requestArg)
        return HTTPResponse(statusCode: .ok)
    }

    private func setLocationAccuracyHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try await JSONDecoder().decode(SetLocationAccuracyRequest.self, from: request.bodyData)
        try await setLocationAccuracy(request: requestArg)
        return HTTPResponse(statusCode: .ok)
    }

    private func debugHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try await debug()
        return HTTPResponse(statusCode: .ok)
    }

    private func markPatrolAppServiceReadyHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try await markPatrolAppServiceReady()
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
