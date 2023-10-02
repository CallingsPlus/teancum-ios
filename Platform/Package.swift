// swift-tools-version:5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Platform",
    defaultLocalization: "en",
    platforms: [.iOS(.v16), .macOS(.v12)],
    products: [
        .library(name: "Components", targets: ["Components"]),
        .library(name: "ErrorHandling", targets: ["ErrorHandling"]),
        .library(name: "ExtendedFoundation", targets: ["ExtendedFoundation"]),
        .library(name: "Logging", targets: ["Logging"]),
    ],
    dependencies: [
        /* not allowed */
    ],
    targets: [
        .target(name: "Components", dependencies: [ "ExtendedFoundation", /* others not allowed */ ]),
        .target(name: "ErrorHandling", dependencies: [ "ExtendedFoundation", /* others not allowed */ ]),
        .target(name: "ExtendedFoundation", dependencies: [ /* not allowed */ ]),
        .target(name: "Logging", dependencies: [ "ExtendedFoundation", /* others not allowed */ ]),
    ]
)
