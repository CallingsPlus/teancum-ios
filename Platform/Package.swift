// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Platform",
    defaultLocalization: "en",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(name: "CodeLocation", targets: ["CodeLocation"]),
        .library(name: "Components", targets: ["Components"]),
        .library(name: "ErrorHandling", targets: ["ErrorHandling"]),
        .library(name: "ExtendedFoundation", targets: ["ExtendedFoundation"]),
        .library(name: "Logging", targets: ["Logging"]),
    ],
    dependencies: [
        /* not allowed */
    ],
    targets: [
        .target(name: "CodeLocation", dependencies: [ "ExtendedFoundation", /* others not allowed */ ]),
        .target(name: "Components", dependencies: [ "ExtendedFoundation", /* others not allowed */ ]),
        .target(name: "ErrorHandling", dependencies: [ "CodeLocation", "ExtendedFoundation", /* others not allowed */ ]),
        .target(name: "ExtendedFoundation", dependencies: [ /* not allowed */ ]),
        .target(name: "Logging", dependencies: [ "CodeLocation", "ExtendedFoundation", /* others not allowed */ ]),
    ]
)
