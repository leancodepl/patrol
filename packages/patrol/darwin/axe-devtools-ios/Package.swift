// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "axeDevTools",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "axeDevToolsXCUI",
            targets: ["axeDevToolsXCUI"])
    ],
    targets: [
        .binaryTarget(
            name: "axeDevToolsXCUI",
            path: "axeDevToolsXCUI.xcframework"
        )
    ]
)
