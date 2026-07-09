// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "patrol_axe",
  platforms: [
    .iOS("13.0"),
  ],
  products: [
    .library(name: "patrol_axe", targets: ["patrol_axe"]),
  ],
  dependencies: [
    .package(path: "../../packages/patrol/darwin/patrol"),
    .package(path: "axe-devtools-ios"),
  ],
  targets: [
    .target(
      name: "PatrolAxeObjC",
      dependencies: [
        .product(name: "patrol", package: "patrol"),
        .product(name: "axeDevToolsXCUI", package: "axe-devtools-ios"),
      ],
      path: "patrol_axe/Sources/PatrolAxe",
      sources: ["AxeBridge.m", "AxeServerExtensionRegistration.m"],
      publicHeadersPath: ".",
    ),
    .target(
      name: "patrol_axe",
      dependencies: [
        "PatrolAxeObjC",
        .product(name: "patrol", package: "patrol"),
        .product(name: "axeDevToolsXCUI", package: "axe-devtools-ios"),
      ],
      path: "patrol_axe/Sources/PatrolAxe",
      sources: ["AxeAutomator.swift", "AxeServerExtension.swift", "PatrolAxePlugin.swift"],
      swiftSettings: [
        .define("PATROL_ENABLED"),
      ],
      linkerSettings: [
        .linkedFramework("XCTest", .when(platforms: [.iOS])),
      ],
    ),
  ]
)
