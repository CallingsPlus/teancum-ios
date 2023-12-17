// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Features",
    defaultLocalization: "en",
    platforms: [.iOS(.v16), .macOS(.v13), .macCatalyst(.v16)],
    products: [
        .library(name: "Features", targets: ["Features"]),
        .library(name: "FeaturesDemoAppCode", targets: ["FeaturesDemoAppCode"]),
    ],
    dependencies: [
        .package(name: "Common", path: "../Common"),
        .package(name: "Platform", path: "../Platform"),
        .package(url: "https://github.com/wayfair/vsm-ios", exact: "1.1.2"),
        .package(url: "https://github.com/pointfreeco/swift-case-paths", exact: "1.1.1")
    ],
    targets: [
        .target(name: "Features", dependencies: [
            .product(name: "Components", package: "Platform"),
            .product(name: "DataServices", package: "Common"),
            .product(name: "ErrorHandling", package: "Platform"),
            .product(name: "ExtendedFoundation", package: "Platform"),
            .product(name: "Logging", package: "Platform"),
            .product(name: "VSM", package: "vsm-ios"),
        ]),
        .target(name: "FeaturesDemoAppCode", dependencies: [
            .product(name: "ErrorHandling", package: "Platform"),
            .product(name: "ExtendedFoundation", package: "Platform"),
            "Features",
            .product(name: "Logging", package: "Platform"),
        ]),
        .testTarget(name: "FeaturesTests", dependencies: [
            "Features"
        ])
    ]
)
