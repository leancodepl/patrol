// #if PATROL_ENABLED

import Foundation

final class AutomatorServer: NativeAutomatorServer {
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
