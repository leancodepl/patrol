// swift-tools-version: 5.9

import Foundation
import PackageDescription

// PATROL_ENABLED flag must be set here, so OTHER_SWIFT_FLAGS don't work like they do in cocoapods
// and we need to base it on a env flag set in patrol cli.
let patrolEnabled = ProcessInfo.processInfo.environment["PATROL_ENABLED"] == "1"

let patrolSwiftSettings: [SwiftSetting] =
  patrolEnabled
  ? [.define("PATROL_ENABLED")]
  : []

let patrolBaseLinkerSettings: [LinkerSetting] = [
  .linkedFramework("UIKit", .when(platforms: [.iOS])),
  .linkedFramework("AppKit", .when(platforms: [.macOS])),
]

let patrolLinkerSettings: [LinkerSetting] =
  patrolEnabled
  ? patrolBaseLinkerSettings + [.unsafeFlags(["-weak_framework", "XCTest"])]
  : patrolBaseLinkerSettings

let package = Package(
  name: "patrol",
  defaultLocalization: "en",
  platforms: [
    .iOS("13.0"),
    .macOS("10.14"),
  ],
  products: [
    // Flutter derives the product name from the pub package name, so it has to
    // stay `patrol`. Both targets are members of it: that is what makes
    // `PatrolRunner` importable from RunnerUITests, which only ever links
    // `FlutterGeneratedPluginSwiftPackage` (and that in turn depends solely on
    // the `patrol` product).
    .library(name: "patrol", targets: ["patrol", "PatrolRunner"])
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
    // The module Flutter's generated registrants import: `@import patrol;` from
    // ios/Runner/GeneratedPluginRegistrant.m and `import patrol` from
    // macos/Flutter/GeneratedPluginRegistrant.swift. Since the macOS registrant
    // is Swift and calls `PatrolPlugin.register(with:)`, this has to be the
    // Swift target - a Clang module that `@import`s a Swift one is only
    // importable from ObjC, never from Swift. See
    // https://github.com/leancodepl/patrol/issues/3177.
    .target(
      name: "patrol",
      dependencies: [
        // TODO: Add this when Patrol targets Flutter 3.41.0 or higher
        // .product(name: "FlutterFramework", package: "FlutterFramework")
        .product(name: "CocoaAsyncSocket", package: "CocoaAsyncSocket"),
        "HTTPParserC",
      ],
      path: "Sources/patrol",
      resources: [
        .process("Resources/PrivacyInfo.xcprivacy"),
        .process("Resources/en.lproj"),
        .process("Resources/de.lproj"),
        .process("Resources/fr.lproj"),
        .process("Resources/pl.lproj"),
        .process("Resources/ja.lproj"),
      ],
      swiftSettings: patrolSwiftSettings,
      linkerSettings: patrolLinkerSettings
    ),
    // The ObjC runner macros users expand in RunnerUITests.m, plus the
    // extension registry declaration. Deliberately dependency-free: the macro
    // bodies do reference @objc classes from `patrol`, but only once expanded
    // in a translation unit that already did `@import patrol;`. Keeping this
    // module free of any Swift import is what makes it work under SwiftPM.
    .target(
      name: "PatrolRunner",
      path: "Sources/PatrolRunner",
      publicHeadersPath: "include"
    ),
  ]
)
