import GRPC

typealias Empty = Patrol_Empty
typealias DefaultResponse = Patrol_DefaultResponse

final class NativeAutomatorServer: Patrol_NativeAutomatorAsyncProvider {
  private let automation = PatrolAutomation()
  
  // MARK: General
  
  func pressHome(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return await runCatching {
      try automation.pressHome()
    }
  }
  
  func pressBack(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    throw PatrolError.generic("pressBack() is not supported on iOS")
  }
  
  func pressRecentApps(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return await runCatching {
      try automation.openAppSwitcher()
    }
  }
  
  func doublePressRecentApps(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    throw PatrolError.generic("doublePressRecentApps() is not supported on iOS")
  }
  
  func openApp(
    request: Patrol_OpenAppRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return await runCatching {
      try automation.openApp(request.appID)
    }
  }
  
  func openQuickSettings(
    request: Patrol_OpenQuickSettingsRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return await runCatching {
      try automation.openControlCenter()
    }
  }
  
  // MARK: General UI interaction
  
  func getNativeViews(
    request: Patrol_GetNativeViewsRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Patrol_GetNativeViewsResponse {
    throw PatrolError.generic("getNativeViews() is not supported on iOS")
  }
  
  func tap(
    request: Patrol_TapRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return await runCatching {
      try automation.tap(on: request.selector.text, inApp: request.appID)
    }
  }
  
  func doubleTap(
    request: Patrol_TapRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return await runCatching {
      try automation.doubleTap(on: request.selector.text, inApp: request.appID)
    }
  }
  
  func enterText(
    request: Patrol_EnterTextRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return await runCatching {
      switch request.findBy {
      case .index(let index):
        try automation.enterText(request.data, by: Int(index), inApp: request.appID)
      case .selector(let selector):
        try automation.enterText(request.data, by: selector.text, inApp: request.appID)
      default:
        throw PatrolError.generic("enterText(): neither index nor selector are set")
      }
    }
  }
  
  func swipe(
    request: Patrol_SwipeRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    throw PatrolError.generic("swipe() is not supported on iOS")
  }
  
  // MARK: Services
  
  func enableAirplaneMode(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    try automation.enableAirplaneMode()
    return DefaultResponse()
  }
  
  func disableAirplaneMode(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return await runCatching {
      try automation.disableAirplaneMode()
    }
  }
  
  func enableWiFi(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return await runCatching {
      try automation.enableWiFi()
    }
  }
  
  func disableWiFi(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return await runCatching {
      try automation.disableWiFi()
    }
  }
  
  func enableCellular(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return await runCatching {
      try automation.enableCellular()
    }
  }
  
  func disableCellular(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return await runCatching {
      try automation.disableCellular()
    }
  }
  
  func enableBluetooth(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return await runCatching {
      try automation.enableBluetooth()
    }
  }
  
  func disableBluetooth(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return await runCatching {
      try automation.disableBluetooth()
    }
  }
  
  func enableDarkMode(
    request: Patrol_DarkModeRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return await runCatching {
      try automation.enableDarkMode(request.appID)
    }
  }
  
  func disableDarkMode(
    request: Patrol_DarkModeRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return await runCatching {
      try automation.disableDarkMode(request.appID)
    }
  }
  
  // MARK: Notifications
  
  func openNotifications(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return await runCatching {
      try automation.openNotifications()
    }
  }
  
  func closeNotifications(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return await runCatching {
      try automation.closeNotifications()
    }
  }
  
  func closeHeadsUpNotification(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return await runCatching {
      try await automation.closeHeadsUpNotification()
    }
  }
  
  func getNotifications(
    request: Patrol_GetNotificationsRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Patrol_GetNotificationsResponse {
    let notifications = try automation.getNotifications()
    return Patrol_GetNotificationsResponse.with {
      $0.notifications = notifications
    }
  }
  
  func tapOnNotification(
    request: Patrol_TapOnNotificationRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return await runCatching {
      switch request.findBy {
        case .index(let index):
          try automation.tapOnNotification(by: Int(index))
        case .selector(let selector):
          try automation.tapOnNotification(by: selector.textContains)
        default:
          throw PatrolError.generic("tapOnNotification(): neither index nor selector are set")
      }
    }
  }
  
  // MARK: Permissions
  
  func handlePermissionDialog(
    request: Patrol_HandlePermissionRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return await runCatching {
      switch request.code {
      case .whileUsing:
        try automation.allowPermissionWhileUsingApp()
      case .onlyThisTime:
        try automation.allowPermissionOnce()
      case .denied:
        try automation.denyPermission()
      case .UNRECOGNIZED:
        throw PatrolError.generic("handlePermissionDialog(): bad permission code")
      }
    }
  }
  
  func setLocationAccuracy(
    request: Patrol_SetLocationAccuracyRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return await runCatching {
      switch request.locationAccuracy {
      case .coarse:
        try automation.selectCoarseLocation()
      case .fine:
        try automation.selectFineLocation()
      case .UNRECOGNIZED:
        throw PatrolError.generic("unrecognized location accuracy")
      }
    }
  }
  
  func debug(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> DefaultResponse {
    return await runCatching {
      try automation.debug()
    }
  }
  
  private func runCatching(_ block: () async throws -> Void) async -> DefaultResponse {
    do {
      try await block()
      return DefaultResponse()
    } catch let err as PatrolError {
      return DefaultResponse.with {
        $0.errorMessage = err.description
      }
    } catch let err {
      return DefaultResponse.with {
        $0.errorMessage = err.localizedDescription
      }
    }
  }
}
