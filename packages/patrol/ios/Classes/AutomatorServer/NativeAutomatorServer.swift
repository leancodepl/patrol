///
//  Generated code. Do not modify.
//  source: schema.dart
//

import Telegraph

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
        return HTTPResponse(.ok)
    }

    private func configureHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(ConfigureRequest.self, from: request.body)
        try await configure(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func pressHomeHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try await pressHome()
        return HTTPResponse(.ok)
    }

    private func pressBackHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try await pressBack()
        return HTTPResponse(.ok)
    }

    private func pressRecentAppsHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try await pressRecentApps()
        return HTTPResponse(.ok)
    }

    private func doublePressRecentAppsHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try await doublePressRecentApps()
        return HTTPResponse(.ok)
    }

    private func openAppHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(OpenAppRequest.self, from: request.body)
        try await openApp(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func openQuickSettingsHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(OpenQuickSettingsRequest.self, from: request.body)
        try await openQuickSettings(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func getNativeViewsHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(GetNativeViewsRequest.self, from: request.body)
        let response = try await getNativeViews(request: requestArg)
        let body = try JSONEncoder().encode(response)
        return HTTPResponse(.ok, body: body)
    }

    private func tapHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(TapRequest.self, from: request.body)
        try await tap(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func doubleTapHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(TapRequest.self, from: request.body)
        try await doubleTap(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func enterTextHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(EnterTextRequest.self, from: request.body)
        try await enterText(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func swipeHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(SwipeRequest.self, from: request.body)
        try await swipe(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func waitUntilVisibleHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(WaitUntilVisibleRequest.self, from: request.body)
        try await waitUntilVisible(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func enableAirplaneModeHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try await enableAirplaneMode()
        return HTTPResponse(.ok)
    }

    private func disableAirplaneModeHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try await disableAirplaneMode()
        return HTTPResponse(.ok)
    }

    private func enableWiFiHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try await enableWiFi()
        return HTTPResponse(.ok)
    }

    private func disableWiFiHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try await disableWiFi()
        return HTTPResponse(.ok)
    }

    private func enableCellularHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try await enableCellular()
        return HTTPResponse(.ok)
    }

    private func disableCellularHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try await disableCellular()
        return HTTPResponse(.ok)
    }

    private func enableBluetoothHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try await enableBluetooth()
        return HTTPResponse(.ok)
    }

    private func disableBluetoothHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try await disableBluetooth()
        return HTTPResponse(.ok)
    }

    private func enableDarkModeHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(DarkModeRequest.self, from: request.body)
        try await enableDarkMode(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func disableDarkModeHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(DarkModeRequest.self, from: request.body)
        try await disableDarkMode(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func openNotificationsHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try await openNotifications()
        return HTTPResponse(.ok)
    }

    private func closeNotificationsHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try await closeNotifications()
        return HTTPResponse(.ok)
    }

    private func closeHeadsUpNotificationHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try await closeHeadsUpNotification()
        return HTTPResponse(.ok)
    }

    private func getNotificationsHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(GetNotificationsRequest.self, from: request.body)
        let response = try await getNotifications(request: requestArg)
        let body = try JSONEncoder().encode(response)
        return HTTPResponse(.ok, body: body)
    }

    private func tapOnNotificationHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(TapOnNotificationRequest.self, from: request.body)
        try await tapOnNotification(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func isPermissionDialogVisibleHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(PermissionDialogVisibleRequest.self, from: request.body)
        let response = try await isPermissionDialogVisible(request: requestArg)
        let body = try JSONEncoder().encode(response)
        return HTTPResponse(.ok, body: body)
    }

    private func handlePermissionDialogHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(HandlePermissionRequest.self, from: request.body)
        try await handlePermissionDialog(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func setLocationAccuracyHandler(request: HTTPRequest) async throws -> HTTPResponse {
        let requestArg = try JSONDecoder().decode(SetLocationAccuracyRequest.self, from: request.body)
        try await setLocationAccuracy(request: requestArg)
        return HTTPResponse(.ok)
    }

    private func debugHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try await debug()
        return HTTPResponse(.ok)
    }

    private func markPatrolAppServiceReadyHandler(request: HTTPRequest) async throws -> HTTPResponse {
        try await markPatrolAppServiceReady()
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
        server.route(.POST, "pressHome") {
            request in handleRequest(
                request: request,
                handler: pressHomeHandler)
        }
        server.route(.POST, "pressBack") {
            request in handleRequest(
                request: request,
                handler: pressBackHandler)
        }
        server.route(.POST, "pressRecentApps") {
            request in handleRequest(
                request: request,
                handler: pressRecentAppsHandler)
        }
        server.route(.POST, "doublePressRecentApps") {
            request in handleRequest(
                request: request,
                handler: doublePressRecentAppsHandler)
        }
        server.route(.POST, "openApp") {
            request in handleRequest(
                request: request,
                handler: openAppHandler)
        }
        server.route(.POST, "openQuickSettings") {
            request in handleRequest(
                request: request,
                handler: openQuickSettingsHandler)
        }
        server.route(.POST, "getNativeViews") {
            request in handleRequest(
                request: request,
                handler: getNativeViewsHandler)
        }
        server.route(.POST, "tap") {
            request in handleRequest(
                request: request,
                handler: tapHandler)
        }
        server.route(.POST, "doubleTap") {
            request in handleRequest(
                request: request,
                handler: doubleTapHandler)
        }
        server.route(.POST, "enterText") {
            request in handleRequest(
                request: request,
                handler: enterTextHandler)
        }
        server.route(.POST, "swipe") {
            request in handleRequest(
                request: request,
                handler: swipeHandler)
        }
        server.route(.POST, "waitUntilVisible") {
            request in handleRequest(
                request: request,
                handler: waitUntilVisibleHandler)
        }
        server.route(.POST, "enableAirplaneMode") {
            request in handleRequest(
                request: request,
                handler: enableAirplaneModeHandler)
        }
        server.route(.POST, "disableAirplaneMode") {
            request in handleRequest(
                request: request,
                handler: disableAirplaneModeHandler)
        }
        server.route(.POST, "enableWiFi") {
            request in handleRequest(
                request: request,
                handler: enableWiFiHandler)
        }
        server.route(.POST, "disableWiFi") {
            request in handleRequest(
                request: request,
                handler: disableWiFiHandler)
        }
        server.route(.POST, "enableCellular") {
            request in handleRequest(
                request: request,
                handler: enableCellularHandler)
        }
        server.route(.POST, "disableCellular") {
            request in handleRequest(
                request: request,
                handler: disableCellularHandler)
        }
        server.route(.POST, "enableBluetooth") {
            request in handleRequest(
                request: request,
                handler: enableBluetoothHandler)
        }
        server.route(.POST, "disableBluetooth") {
            request in handleRequest(
                request: request,
                handler: disableBluetoothHandler)
        }
        server.route(.POST, "enableDarkMode") {
            request in handleRequest(
                request: request,
                handler: enableDarkModeHandler)
        }
        server.route(.POST, "disableDarkMode") {
            request in handleRequest(
                request: request,
                handler: disableDarkModeHandler)
        }
        server.route(.POST, "openNotifications") {
            request in handleRequest(
                request: request,
                handler: openNotificationsHandler)
        }
        server.route(.POST, "closeNotifications") {
            request in handleRequest(
                request: request,
                handler: closeNotificationsHandler)
        }
        server.route(.POST, "closeHeadsUpNotification") {
            request in handleRequest(
                request: request,
                handler: closeHeadsUpNotificationHandler)
        }
        server.route(.POST, "getNotifications") {
            request in handleRequest(
                request: request,
                handler: getNotificationsHandler)
        }
        server.route(.POST, "tapOnNotification") {
            request in handleRequest(
                request: request,
                handler: tapOnNotificationHandler)
        }
        server.route(.POST, "isPermissionDialogVisible") {
            request in handleRequest(
                request: request,
                handler: isPermissionDialogVisibleHandler)
        }
        server.route(.POST, "handlePermissionDialog") {
            request in handleRequest(
                request: request,
                handler: handlePermissionDialogHandler)
        }
        server.route(.POST, "setLocationAccuracy") {
            request in handleRequest(
                request: request,
                handler: setLocationAccuracyHandler)
        }
        server.route(.POST, "debug") {
            request in handleRequest(
                request: request,
                handler: debugHandler)
        }
        server.route(.POST, "markPatrolAppServiceReady") {
            request in handleRequest(
                request: request,
                handler: markPatrolAppServiceReadyHandler)
        }
    }
}

fileprivate class Box<ResultType> {
    var result: Result<ResultType, Error>? = nil
}

extension NativeAutomatorServer {
    private func handleRequest(request: HTTPRequest, handler: @escaping (HTTPRequest) async throws -> HTTPResponse) -> HTTPResponse {
        do {
            return try unsafeWait {
                return try await handler(request)
            }
        } catch let err {
            return HTTPResponse(.badRequest, headers: [:], error: err)
        }
    }
    
    private func unsafeWait<ResultType>(_ f: @escaping () async throws -> ResultType) throws -> ResultType {
        let box = Box<ResultType>()
        let sema = DispatchSemaphore(value: 0)
        Task {
            do {
                let val = try await f()
                box.result = .success(val)
            } catch {
                box.result = .failure(error)
            }
            sema.signal()
        }
        sema.wait()
        return try box.result!.get()
    }
}
