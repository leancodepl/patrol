// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

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
                .linkedFramework("UIKit", .when(platforms: [.iOS])),
                .linkedFramework("AppKit", .when(platforms: [.macOS]))
            ]
        )
    ]
)
