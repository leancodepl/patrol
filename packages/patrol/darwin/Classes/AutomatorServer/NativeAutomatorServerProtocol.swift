protocol NativeAutomatorServer {
    func initialize() throws
    func configure(request: ConfigureRequest) throws
    func pressHome() throws
    func pressBack() throws
    func pressRecentApps() throws
    func doublePressRecentApps() throws
    func openApp(request: OpenAppRequest) throws
    func openQuickSettings(request: OpenQuickSettingsRequest) throws
    func getNativeUITree(request: GetNativeUITreeRequest) throws -> GetNativeUITreeRespone
    func getNativeViews(request: GetNativeViewsRequest) throws -> GetNativeViewsResponse
    func tap(request: TapRequest) throws
    func doubleTap(request: TapRequest) throws
    func enterText(request: EnterTextRequest) throws
    func swipe(request: SwipeRequest) throws
    func waitUntilVisible(request: WaitUntilVisibleRequest) throws
    func enableAirplaneMode() throws
    func disableAirplaneMode() throws
    func enableWiFi() throws
    func disableWiFi() throws
    func enableCellular() throws
    func disableCellular() throws
    func enableBluetooth() throws
    func disableBluetooth() throws
    func enableDarkMode(request: DarkModeRequest) throws
    func disableDarkMode(request: DarkModeRequest) throws
    func openNotifications() throws
    func closeNotifications() throws
    func closeHeadsUpNotification() throws
    func getNotifications(request: GetNotificationsRequest) throws -> GetNotificationsResponse
    func tapOnNotification(request: TapOnNotificationRequest) throws
    func isPermissionDialogVisible(request: PermissionDialogVisibleRequest) throws -> PermissionDialogVisibleResponse
    func handlePermissionDialog(request: HandlePermissionRequest) throws
    func setLocationAccuracy(request: SetLocationAccuracyRequest) throws
    func debug() throws
    func markPatrolAppServiceReady() throws
}