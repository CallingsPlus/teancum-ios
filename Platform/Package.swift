// swift-tools-version:5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Platform",
    defaultLocalization: "en",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(name: "ErrorHandling", targets: ["ErrorHandling"]),
        .library(name: "FoundationPlus", targets: ["FoundationPlus"]),
        .library(name: "Logging", targets: ["Logging"]),
    ],
    dependencies: [
        /* not allowed */
    ],
    targets: [
        .target(name: "ErrorHandling", dependencies: [ "FoundationPlus", /* others not allowed */ ]),
        .target(name: "FoundationPlus", dependencies: [ /* not allowed */ ]),
        .target(name: "Logging", dependencies: [ "FoundationPlus", /* others not allowed */ ]),
    ]
)
