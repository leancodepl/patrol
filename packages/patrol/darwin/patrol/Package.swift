// swift-tools-version: 5.9

import Foundation
import PackageDescription

// PATROL_ENABLED flag must be set here, so OTHER_SWIFT_FLAGS don't work like they do in cocoapods
// and we need to base it on a env flag set in patrol cli.
let patrolEnabled = ProcessInfo.processInfo.environment["PATROL_ENABLED"] == "1"

let patrolImplSwiftSettings: [SwiftSetting] =
  patrolEnabled
  ? [.define("PATROL_ENABLED")]
  : []

let patrolImplBaseLinkerSettings: [LinkerSetting] = [
  .linkedFramework("UIKit", .when(platforms: [.iOS])),
  .linkedFramework("AppKit", .when(platforms: [.macOS])),
]

let patrolImplLinkerSettings: [LinkerSetting] =
  patrolEnabled
  ? patrolImplBaseLinkerSettings + [.unsafeFlags(["-weak_framework", "XCTest"])]
  : patrolImplBaseLinkerSettings

let package = Package(
  name: "patrol",
  defaultLocalization: "en",
  platforms: [
    .iOS("13.0"),
    .macOS("10.14"),
  ],
  products: [
    .library(name: "patrol", targets: ["patrol"])
  ],
  dependencies: [
    // TODO: Add this when Patrol targets Flutter 3.41.0 or higher
    // .package(name: "FlutterFramework", path: "../FlutterFramework"),
    .package(url: "https://github.com/robbiehanson/CocoaAsyncSocket", from: "7.6.4")
  ],
  targets: [
    .target(
      name: "HTTPParserC",
      dependencies: [],
      path: "Sources/HTTPParserC",
      publicHeadersPath: "include"
    ),
    // Swift implementation. SwiftPM does not allow mixing Swift and ObjC in a
    // single target, so the Swift code lives here and the ObjC runner macros
    // live in the `patrol` Clang target below, which re-exports this module.
    .target(
      name: "PatrolImpl",
      dependencies: [
        // TODO: Add this when Patrol targets Flutter 3.41.0 or higher
        // .product(name: "FlutterFramework", package: "FlutterFramework")
        .product(name: "CocoaAsyncSocket", package: "CocoaAsyncSocket"),
        "HTTPParserC",
      ],
      path: "Sources/PatrolImpl",
      resources: [
        .process("Resources/PrivacyInfo.xcprivacy"),
        .process("Resources/en.lproj"),
        .process("Resources/de.lproj"),
        .process("Resources/fr.lproj"),
        .process("Resources/pl.lproj"),
      ],
      swiftSettings: patrolImplSwiftSettings,
      linkerSettings: patrolImplLinkerSettings
    ),
    // Public module named `patrol`. This is the module Flutter's generated
    // registrant imports and the module users `@import` from RunnerUITests.
    // It hosts the ObjC runner macros (Sources/patrol/include) and re-exports
    // PatrolImpl (via include/patrol.h + `export *` in module.modulemap), so a
    // single `@import patrol` exposes both the macro and the Swift @objc API.
    .target(
      name: "patrol",
      dependencies: ["PatrolImpl"],
      path: "Sources/patrol",
      publicHeadersPath: "include"
    ),
  ]
)
