#if PATROL_ENABLED

import Foundation

final class AutomatorServer: NativeAutomatorServer {
    private let automator: Automator
    
    private let onAppReady: (Bool) -> Void
    
    init(automator: Automator, onAppReady: @escaping (Bool) -> Void) {
        self.automator = automator
        self.onAppReady = onAppReady
    }
    
    func initialize() async throws {}
    
    func configure(request: ConfigureRequest) async throws {
        automator.configure(timeout: TimeInterval(request.findTimeoutMillis / 1000))
    }
    
    // MARK: General
    
    func pressHome() async throws {
        return try await runCatching {
            try await automator.pressHome()
        }
    }
    
    func pressBack() async throws {
        return try await runCatching {
            throw PatrolError.methodNotImplemented("pressBack")
        }
    }
    
    func pressRecentApps() async throws {
        return try await runCatching {
            try await automator.openAppSwitcher()
        }
    }
    
    func doublePressRecentApps() async throws {
        return try await runCatching {
            throw PatrolError.methodNotImplemented("doublePressRecentApps")
        }
    }
    
    func openApp(request: OpenAppRequest) async throws {
        return try await runCatching {
            try await automator.openApp(request.appId)
        }
    }
    
    func openQuickSettings(request: OpenQuickSettingsRequest) async throws {
        return try await runCatching {
            try await automator.openControlCenter()
        }
    }
    
    // MARK: General UI interaction
    
    func getNativeViews(
        request: GetNativeViewsRequest
    ) async throws -> GetNativeViewsResponse {
        return try await runCatching {
            let nativeViews = try await automator.getNativeViews(
                byText: request.selector.text ?? String(),
                inApp: request.appId
            )
            
            return GetNativeViewsResponse(nativeViews: nativeViews)
        }
    }
    
    func tap(request: TapRequest) async throws {
        return try await runCatching {
            try await automator.tap(
                onText: request.selector.text ?? String(),
                inApp: request.appId,
                atIndex: request.selector.instance ?? 0
            )
        }
    }
    
    func doubleTap(request: TapRequest) async throws {
        return try await runCatching {
            try await automator.doubleTap(
                onText: request.selector.text ?? String(),
                inApp: request.appId
            )
        }
    }
    
    func enterText(request: EnterTextRequest) async throws {
        return try await runCatching {
            if let index = request.index {
                try await automator.enterText(
                    request.data,
                    byIndex: Int(index),
                    inApp: request.appId
                )
            } else if let selector = request.selector {
                try await automator.enterText(
                    request.data,
                    byText: selector.text ?? String(),
                    atIndex: selector.instance ?? 0,
                    inApp: request.appId
                )
            } else {
                throw PatrolError.internal("enterText(): neither index nor selector are set")
            }
        }
    }
    
    func swipe(request: SwipeRequest) async throws {
        return try await runCatching {
            throw PatrolError.methodNotImplemented("swipe")
        }
    }
    
    func waitUntilVisible(request: WaitUntilVisibleRequest) async throws {
        return try await runCatching {
            try await automator.waitUntilVisible(
                onText: request.selector.text ?? String(),
                inApp: request.appId
            )
        }
    }
    
    // MARK: Services
    
    func enableAirplaneMode() async throws {
        return try await runCatching {
            try await automator.enableAirplaneMode()
        }
    }
    
    func disableAirplaneMode() async throws {
        return try await runCatching {
            try await automator.disableAirplaneMode()
        }
    }
    
    func enableWiFi() async throws {
        return try await runCatching {
            try await automator.enableWiFi()
        }
    }
    
    func disableWiFi() async throws {
        return try await runCatching {
            try await automator.disableWiFi()
        }
    }
    
    func enableCellular() async throws {
        return try await runCatching {
            try await automator.enableCellular()
        }
    }
    
    func disableCellular() async throws {
        return try await runCatching {
            try await automator.disableCellular()
        }
    }
    
    func enableBluetooth() async throws {
        return try await runCatching {
            try await automator.enableBluetooth()
        }
    }
    
    func disableBluetooth() async throws {
        return try await runCatching {
            try await automator.disableBluetooth()
        }
    }
    
    func enableDarkMode(request: DarkModeRequest) async throws {
        return try await runCatching {
            try await automator.enableDarkMode(request.appId)
        }
    }
    
    func disableDarkMode(request: DarkModeRequest) async throws {
        return try await runCatching {
            try await automator.disableDarkMode(request.appId)
        }
    }
    
    // MARK: Notifications
    
    func openNotifications() async throws {
        return try await runCatching {
            try await automator.openNotifications()
        }
    }
    
    func closeNotifications() async throws {
        return try await runCatching {
            try await automator.closeNotifications()
        }
    }
    
    func closeHeadsUpNotification() async throws {
        return try await runCatching {
            try await automator.closeHeadsUpNotification()
        }
    }
    
    func getNotifications(
        request: GetNotificationsRequest
    ) async throws -> GetNotificationsResponse {
        return try await runCatching {
            let notifications = try await automator.getNotifications()
            return GetNotificationsResponse(notifications: notifications)
        }
    }
    
    func tapOnNotification(request: TapOnNotificationRequest) async throws {
        return try await runCatching {
            if let index = request.index {
                try await automator.tapOnNotification(
                    byIndex: index
                )
            } else if let selector = request.selector {
                try await automator.tapOnNotification(
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
    ) async throws -> PermissionDialogVisibleResponse {
        return try await runCatching {
            let visible = await automator.isPermissionDialogVisible(
                timeout: TimeInterval(request.timeoutMillis / 1000)
            )
            
            return PermissionDialogVisibleResponse(visible: visible)
            
        }
    }
    
    func handlePermissionDialog(request: HandlePermissionRequest) async throws {
        return try await runCatching {
            switch request.code {
            case .whileUsing:
                try await automator.allowPermissionWhileUsingApp()
            case .onlyThisTime:
                try await automator.allowPermissionOnce()
            case .denied:
                try await automator.denyPermission()
            }
        }
    }
    
    func setLocationAccuracy(request: SetLocationAccuracyRequest) async throws {
        return try await runCatching {
            switch request.locationAccuracy {
            case .coarse:
                try await automator.selectCoarseLocation()
            case .fine:
                try await automator.selectFineLocation()
            }
        }
    }
    
    func debug() async throws {
        return try await runCatching {
            try await automator.debug()
        }
    }
    
    private func runCatching<T>(_ block: () async throws -> T) async throws -> T {
        // TODO: Use an interceptor (like on Android)
        // See: https://github.com/grpc/grpc-swift/issues/1148
        do {
            return try await block()
        } catch let err as PatrolError {
            Logger.shared.e(err.description)
            throw err
        } catch let err {
            throw PatrolError.unknown(err)
        }
    }
    
    func markPatrolAppServiceReady() async throws {
        onAppReady(true)
    }
}

#endif
