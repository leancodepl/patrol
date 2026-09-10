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
    // Swift implementation (automator, server, …). SwiftPM does not allow
    // mixing Swift and ObjC in a single target, so this stays separate from
    // the public Clang `patrol` module. Linked as a dependency of `patrol`
    // but not `@import`ed into its umbrella — that would make `patrol`
    // unimportable from Swift (Flutter's macOS registrant). See
    // https://github.com/leancodepl/patrol/issues/3177.
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
        .process("Resources/ja.lproj"),
        .process("Resources/ko.lproj"),
      ],
      swiftSettings: patrolImplSwiftSettings,
      linkerSettings: patrolImplLinkerSettings
    ),
    // Public module named `patrol`. Flutter's registrants import this
    // (`@import patrol` on iOS, `import patrol` on macOS) and users
    // `@import patrol` from RunnerUITests. Hosts ObjC PatrolPlugin, runner
    // macros, and ObjC interface stubs for PatrolImpl's @objc types so a
    // single `@import patrol` is enough — without re-exporting the Swift
    // module into the Clang interface.
    .target(
      name: "patrol",
      dependencies: ["PatrolImpl"],
      path: "Sources/patrol",
      publicHeadersPath: "include"
    ),
  ]
)
