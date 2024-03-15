#if PATROL_ENABLED

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
        try automator.pressHome()
      }
    }

    func pressBack() throws {
      return try runCatching {
        throw PatrolError.methodNotImplemented("pressBack")
      }
    }

    func pressRecentApps() throws {
      return try runCatching {
        try automator.openAppSwitcher()
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
        try automator.openControlCenter()
      }
    }

    // MARK: General UI interaction

    func getNativeViews(
      request: GetNativeViewsRequest
    ) throws -> GetNativeViewsResponse {
      return try runCatching {
        if let selector = request.selector {
          let nativeViews = try automator.getNativeViews(
            on: selector,
            inApp: request.appId
          )
          return GetNativeViewsResponse(
            nativeViews: nativeViews, iosNativeViews: [], androidNativeViews: [])
        } else if let iosSelector = request.iosSelector {
          let iosNativeViews = try automator.getNativeViews(
            on: iosSelector,
            inApp: request.appId
          )
          return GetNativeViewsResponse(
            nativeViews: [], iosNativeViews: iosNativeViews, androidNativeViews: [])
        } else {
          throw PatrolError.internal("getNativeViews(): neither selector nor iosSelector are set")
        }
      }
    }

    func getNativeUITree(request: GetNativeUITreeRequest) throws -> GetNativeUITreeRespone {
      if request.useNativeViewHierarchy {
        let roots = try automator.getUITreeRoots(installedApps: request.iosInstalledApps ?? [])
        return GetNativeUITreeRespone(iOSroots: [], androidRoots: [], roots: roots)
      } else {
        return try automator.getUITreeRootsV2(installedApps: request.iosInstalledApps ?? [])
      }
    }

    func tap(request: TapRequest) throws {
      return try runCatching {
        if let selector = request.selector {
          return try automator.tap(
            on: selector,
            inApp: request.appId,
            withTimeout: request.timeoutMillis.map { TimeInterval($0 / 1000) }
          )
        } else if let iosSelector = request.iosSelector {
          return try automator.tap(
            on: iosSelector,
            inApp: request.appId,
            withTimeout: request.timeoutMillis.map { TimeInterval($0 / 1000) }
          )
        } else {
          throw PatrolError.internal("tap(): neither selector nor iosSelector are set")
        }
      }
    }

    func doubleTap(request: TapRequest) throws {
      return try runCatching {
        if let selector = request.selector {
          return try automator.doubleTap(
            on: selector,
            inApp: request.appId,
            withTimeout: request.timeoutMillis.map { TimeInterval($0 / 1000) }
          )
        } else if let iosSelector = request.iosSelector {
          return try automator.doubleTap(
            on: iosSelector,
            inApp: request.appId,
            withTimeout: request.timeoutMillis.map { TimeInterval($0 / 1000) }
          )
        } else {
          throw PatrolError.internal("doubleTap(): neither selector nor iosSelector are set")
        }
      }
    }

    func tapAt(request: TapAtRequest) throws {
      return try runCatching {
        try automator.tapAt(
          coordinate: CGVector(dx: request.x, dy: request.y),
          inApp: request.appId
        )
      }
    }

    func enterText(request: EnterTextRequest) throws {
      return try runCatching {
        if let index = request.index {
          try automator.enterText(
            request.data,
            byIndex: Int(index),
            inApp: request.appId,
            dismissKeyboard: request.keyboardBehavior == .showAndDismiss,
            withTimeout: request.timeoutMillis.map { TimeInterval($0 / 1000) }
          )
        } else if let selector = request.selector {
          try automator.enterText(
            request.data,
            on: selector,
            inApp: request.appId,
            dismissKeyboard: request.keyboardBehavior == .showAndDismiss,
            withTimeout: request.timeoutMillis.map { TimeInterval($0 / 1000) }
          )
        } else if let iosSelector = request.iosSelector {
          try automator.enterText(
            request.data,
            on: iosSelector,
            inApp: request.appId,
            dismissKeyboard: request.keyboardBehavior == .showAndDismiss,
            withTimeout: request.timeoutMillis.map { TimeInterval($0 / 1000) }
          )
        } else {
          throw PatrolError.internal("enterText(): neither index nor selector are set")
        }
      }
    }

    func swipe(request: SwipeRequest) throws {
      return try runCatching {
        try automator.swipe(
          from: CGVector(dx: request.startX, dy: request.startY),
          to: CGVector(dx: request.startY, dy: request.endY),
          inApp: request.appId
        )
      }
    }

    func waitUntilVisible(request: WaitUntilVisibleRequest) throws {
      return try runCatching {
        if let selector = request.selector {
          return try automator.waitUntilVisible(
            on: selector,
            inApp: request.appId,
            withTimeout: request.timeoutMillis.map { TimeInterval($0 / 1000) }
          )
        } else if let iosSelector = request.iosSelector {
          return try automator.waitUntilVisible(
            on: iosSelector,
            inApp: request.appId,
            withTimeout: request.timeoutMillis.map { TimeInterval($0 / 1000) }
          )
        } else {
          throw PatrolError.internal("waitUntilVisible(): neither selector nor iosSelector are set")
        }
      }
    }

    // MARK: Services

    func enableAirplaneMode() throws {
      return try runCatching {
        try automator.enableAirplaneMode()
      }
    }

    func disableAirplaneMode() throws {
      return try runCatching {
        try automator.disableAirplaneMode()
      }
    }

    func enableWiFi() throws {
      return try runCatching {
        try automator.enableWiFi()
      }
    }

    func disableWiFi() throws {
      return try runCatching {
        try automator.disableWiFi()
      }
    }

    func enableCellular() throws {
      return try runCatching {
        try automator.enableCellular()
      }
    }

    func disableCellular() throws {
      return try runCatching {
        try automator.disableCellular()
      }
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
        try automator.enableDarkMode(request.appId)
      }
    }

    func disableDarkMode(request: DarkModeRequest) throws {
      return try runCatching {
        try automator.disableDarkMode(request.appId)
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
        try automator.closeNotifications()
      }
    }

    func closeHeadsUpNotification() throws {
      return try runCatching {
        try automator.closeHeadsUpNotification()
      }
    }

    func getNotifications(
      request: GetNotificationsRequest
    ) throws -> GetNotificationsResponse {
      return try runCatching {
        let notifications = try automator.getNotifications()
        return GetNotificationsResponse(notifications: notifications)
      }
    }

    func tapOnNotification(request: TapOnNotificationRequest) throws {
      return try runCatching {
        if let index = request.index {
          try automator.tapOnNotification(
            byIndex: index,
            withTimeout: request.timeoutMillis.map { TimeInterval($0 / 1000) }
          )
        } else if let selector = request.selector {
          try automator.tapOnNotification(
            bySubstring: selector.textContains ?? String(),
            withTimeout: request.timeoutMillis.map { TimeInterval($0 / 1000) }
          )
        } else if let selector = request.iosSelector {
          try automator.tapOnNotification(
            bySubstring: selector.titleContains ?? String(),
            withTimeout: request.timeoutMillis.map { TimeInterval($0 / 1000) }
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
        let visible = try automator.isPermissionDialogVisible(
          timeout: TimeInterval(request.timeoutMillis / 1000)
        )

        return PermissionDialogVisibleResponse(visible: visible)

      }
    }

    func handlePermissionDialog(request: HandlePermissionRequest) throws {
      return try runCatching {
        switch request.code {
        case .whileUsing:
          try automator.allowPermissionWhileUsingApp()
        case .onlyThisTime:
          try automator.allowPermissionOnce()
        case .denied:
          try automator.denyPermission()
        }
      }
    }

    func setLocationAccuracy(request: SetLocationAccuracyRequest) throws {
      return try runCatching {
        switch request.locationAccuracy {
        case .coarse:
          try automator.selectCoarseLocation()
        case .fine:
          try automator.selectFineLocation()
        }
      }
    }

    func debug() throws {
      return try runCatching {
        try automator.debug()
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

#endif
