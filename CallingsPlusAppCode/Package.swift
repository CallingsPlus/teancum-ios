// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CallingsPlusAppCode",
    defaultLocalization: "en",
    platforms: [.iOS(.v15), .macOS(.v13), .macCatalyst(.v16)],
    products: [
        .library(name: "CallingsPlusAppCode", targets: ["CallingsPlusAppCode"])
    ],
    dependencies: [
        .package(name: "Common", path: "../Common"),
        .package(name: "Features", path: "../Features"),
        .package(name: "Platform", path: "../Platform"),
        .package(url: "https://github.com/wayfair/vsm-ios", exact: "1.1.2"),
    ],
    targets: [
        .target(
            name: "CallingsPlusAppCode",
            dependencies: [
                .product(name: "ErrorHandling", package: "Platform"),
                .product(name: "ExtendedFoundation", package: "Platform"),
                .product(name: "Features", package: "Features"),
                .product(name: "FirebaseDataServices", package: "Common"),
                .product(name: "StubDataServices", package: "Common"),
                .product(name: "Logging", package: "Platform"),
                .product(name: "VSM", package: "vsm-ios"),
            ]
        ),
    ]
)
