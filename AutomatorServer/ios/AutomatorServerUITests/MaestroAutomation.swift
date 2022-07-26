import XCTest

class MaestroAutomation {
    private lazy var app: XCUIApplication = {
        return XCUIApplication()
    }()
    
    private lazy var device: XCUIDevice = {
        return XCUIDevice.shared
    }()
    
    func pressHome() {
        device.press(XCUIDevice.Button.home)
    }
}
