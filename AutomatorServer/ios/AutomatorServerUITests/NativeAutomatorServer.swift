import GRPC

typealias Empty = Patrol_Empty

final class NativeAutomatorServer: Patrol_NativeAutomatorAsyncProvider {
  private let automation = PatrolAutomation()
  
  func pressHome(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    automation.pressHome()
    return Empty()
  }
  
  func pressBack(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    throw PatrolError.generic("pressBack() is not supported on iOS")
  }
  
  func pressRecentApps(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    automation.openAppSwitcher()
    return Empty()
  }
  
  func doublePressRecentApps(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    throw PatrolError.generic("doublePressRecentApps() is not supported on iOS")
  }
  
  func openApp(
    request: Patrol_OpenAppRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    automation.openApp(request.appID)
    return Empty()
  }
  
  func openNotifications(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    automation.openNotifications()
    return Empty()
  }
  
  func closeNotifications(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    automation.closeNotifications()
    return Empty()
  }
  
  func closeHeadsUpNotification(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    try await automation.closeHeadsUpNotification()
    return Empty()
  }
  
  func openQuickSettings(
    request: Patrol_OpenQuickSettingsRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    automation.openControlCenter()
    return Empty()
  }
  
  func enableDarkMode(
    request: Patrol_DarkModeRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    automation.enableDarkMode(request.appID)
    return Empty()
  }
  
  func disableDarkMode(
    request: Patrol_DarkModeRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    automation.disableDarkMode(request.appID)
    return Empty()
  }
  
  func enableAirplaneMode(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    try automation.enableAirplaneMode()
    return Empty()
  }
  
  func disableAirplaneMode(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    try automation.disableAirplaneMode()
    return Empty()
  }
  
  func enableCellular(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    try automation.enableCellular()
    return Empty()
  }
  
  func disableCellular(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    try automation.disableCellular()
    return Empty()
  }
  
  func enableWiFi(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    try automation.enableWiFi()
    return Empty()
  }
  
  func disableWiFi(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    try automation.disableWiFi()
    return Empty()
  }
  
  func enableBluetooth(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    try automation.enableBluetooth()
    return Empty()
  }
  
  func disableBluetooth(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    try automation.disableBluetooth()
    return Empty()
  }
  
  func getNativeViews(
    request: Patrol_GetNativeViewsRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Patrol_GetNativeViewsResponse {
    throw PatrolError.generic("getNativeViews() is not supported on iOS")
  }
  
  func getNotifications(
    request: Patrol_GetNotificationsRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Patrol_GetNotificationsResponse {
    let notifications = automation.getNotifications()
    return Patrol_GetNotificationsResponse.with {
      $0.notifications = notifications
    }
  }
  
  func tap(
    request: Patrol_TapRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    automation.tap(on: request.selector.text, inApp: request.appID)
    return Empty()
  }
  
  func doubleTap(
    request: Patrol_TapRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    automation.doubleTap(on: request.selector.text, inApp: request.appID)
    return Empty()
  }
  
  func enterText(
    request: Patrol_EnterTextRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    switch request.findBy {
    case .index(let index):
      automation.enterText(request.data, by: Int(index), inApp: request.appID)
    case .selector(let selector):
      automation.enterText(request.data, by: selector.text, inApp: request.appID)
    default:
      throw PatrolError.generic("enterText(): neither index nor selector are set")
    }
    
    return Empty()
  }
  
  func swipe(
    request: Patrol_SwipeRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    throw PatrolError.generic("swipe() is not supported on iOS")
  }
  
  func handlePermissionDialog(
    request: Patrol_HandlePermissionRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    switch request.code {
    case .whileUsing:
      automation.allowPermissionWhileUsingApp()
    case .onlyThisTime:
      automation.allowPermissionOnce()
    case .denied:
      automation.denyPermission()
    case .UNRECOGNIZED:
      throw PatrolError.generic("handlePermissionDialog(): bad permission code")
    }

    return Empty()
  }
  
  func setLocationAccuracy(
    request: Patrol_SetLocationAccuracyRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    switch request.locationAccuracy {
    case .coarse:
      automation.selectCoarseLocation()
    case .fine:
      automation.selectFineLocation()
    case .UNRECOGNIZED:
      throw PatrolError.generic("unrecognized location accuracy")
    }
    
    return Empty()
  }
  
  func tapOnNotification(
    request: Patrol_TapOnNotificationRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    switch request.findBy {
    case .index(let index):
      automation.tapOnNotification(by: Int(index))
    case .selector(let selector):
      automation.tapOnNotification(by: selector.textContains)
    default:
      throw PatrolError.generic("tapOnNotification(): neither index nor selector are set")
    }
    
    return Empty()
  }
  
  func debug(
    request: Empty,
    context: GRPCAsyncServerCallContext
  ) async throws -> Empty {
    try automation.debug()
    return Empty()
  }
}
