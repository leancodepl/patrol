import Flutter
import UIKit

// Note: BrowserStackTestHelper framework must be linked in Xcode
// Import is conditional to allow building locally without the framework
#if canImport(BrowserStackTestHelper)
import BrowserStackTestHelper
#endif

/// Flutter plugin for BrowserStack Camera Image Injection.
///
/// This plugin handles method channel calls from Flutter to inject images
/// into the camera when running on BrowserStack infrastructure.
///
/// Usage from Flutter:
/// ```dart
/// final result = await BrowserStackCameraInjection.injectImage('my_image.png');
/// ```
public class BrowserStackCameraInjectionPlugin: NSObject, FlutterPlugin {
    
    private static let channelName = "com.browserstack.camera_injection"
    
    #if canImport(BrowserStackTestHelper)
    private var injector: (any NSObject & InjectorProtocol)?
    #endif
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: channelName,
            binaryMessenger: registrar.messenger()
        )
        let instance = BrowserStackCameraInjectionPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public override init() {
        super.init()
        #if canImport(BrowserStackTestHelper)
        // Initialize the BrowserStack injector
        injector = InjectorFactory.createInstance()
        #endif
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "injectImage":
            handleInjectImage(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func handleInjectImage(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let imageName = args["imageName"] as? String else {
            result([
                "success": false,
                "statusCode": -1,
                "message": "Invalid arguments: imageName is required"
            ] as [String: Any])
            return
        }
        
        #if canImport(BrowserStackTestHelper)
        guard let injector = injector else {
            result([
                "success": false,
                "statusCode": -1,
                "message": "BrowserStack injector not initialized"
            ] as [String: Any])
            return
        }
        
        injector.injectImage(imageName: imageName) { response in
            DispatchQueue.main.async {
                result([
                    "success": response.isSuccess,
                    "statusCode": response.statusCode,
                    "message": response.message
                ] as [String: Any])
            }
        }
        #else
        // BrowserStackTestHelper not available (local development)
        result([
            "success": false,
            "statusCode": -1,
            "message": "BrowserStackTestHelper framework not available. This feature only works on BrowserStack."
        ] as [String: Any])
        #endif
    }
}

