// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

// Resolve the Xcode developer directory to locate platform-specific frameworks (e.g., XCTest).
// This is needed because SPM's unsafeFlags don't support Xcode build setting variables like $(PLATFORM_DIR).
let xcodeDevDir: String = {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/xcode-select")
    task.arguments = ["-p"]
    let pipe = Pipe()
    task.standardOutput = pipe
    try? task.run()
    task.waitUntilExit()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
        ?? "/Applications/Xcode.app/Contents/Developer"
}()

let package = Package(
    name: "patrol",
    defaultLocalization: "en",
    platforms: [
        .iOS("13.0"),
        .macOS("10.14")
    ],
    products: [
        .library(name: "patrol", targets: ["patrol"])
    ],
    dependencies: [
        // TODO: Add this when Patrol targets Flutter 3.41.0 or higher
        // .package(name: "FlutterFramework", path: "../FlutterFramework")
        .package(url: "https://github.com/robbiehanson/CocoaAsyncSocket", from: "7.6.4")
    ],
    targets: [
        .target(
            name: "HTTPParserC",
            dependencies: [],
            path: "Sources/HTTPParserC",
            publicHeadersPath: "include"
        ),
        .target(
            name: "patrol",
            dependencies: [
                // TODO: Add this when Patrol targets Flutter 3.41.0 or higher
                // .product(name: "FlutterFramework", package: "FlutterFramework")
                .product(name: "CocoaAsyncSocket", package: "CocoaAsyncSocket"),
                "HTTPParserC"
            ],
            resources: [
                .process("Resources/PrivacyInfo.xcprivacy"),
                .process("Resources/en.lproj"),
                .process("Resources/de.lproj"),
                .process("Resources/fr.lproj"),
                .process("Resources/pl.lproj"),
            ],
            linkerSettings: [
                .unsafeFlags([
                    // Framework search paths for XCTest.framework
                    "-F", "\(xcodeDevDir)/Platforms/iPhoneSimulator.platform/Developer/Library/Frameworks",
                    "-F", "\(xcodeDevDir)/Platforms/iPhoneOS.platform/Developer/Library/Frameworks",
                    "-F", "\(xcodeDevDir)/Platforms/MacOSX.platform/Developer/Library/Frameworks",
                    // Library search paths for libXCTestSwiftSupport.dylib
                    "-L", "\(xcodeDevDir)/Platforms/iPhoneSimulator.platform/Developer/usr/lib",
                    "-L", "\(xcodeDevDir)/Platforms/iPhoneOS.platform/Developer/usr/lib",
                    "-L", "\(xcodeDevDir)/Platforms/MacOSX.platform/Developer/usr/lib",
                    "-weak_framework", "XCTest",
                ]),
                .linkedFramework("UIKit", .when(platforms: [.iOS])),
                .linkedFramework("AppKit", .when(platforms: [.macOS]))
            ]
        )
    ]
)
