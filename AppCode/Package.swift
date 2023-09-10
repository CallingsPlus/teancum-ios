// swift-tools-version:5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppCode",
    defaultLocalization: "en",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(name: "AppCode", targets: ["AppCode"])
    ],
    dependencies: [
        .package(name: "Common", path: "../Common"),
        .package(name: "Onboarding", path: "../Features/Onboarding"),
        .package(name: "Platform", path: "../Platform"),
        .package(url: "https://github.com/wayfair/vsm-ios", exact: "1.1.1"),
    ],
    targets: [
        .target(
            name: "AppCode",
            dependencies: [
                .product(name: "ErrorHandling", package: "Platform"),
                .product(name: "FirebaseClient", package: "Common"),
                .product(name: "FoundationPlus", package: "Platform"),
                .product(name: "Logging", package: "Platform"),
                .product(name: "OnboardingConfig", package: "Onboarding"),
                .product(name: "VSM", package: "vsm-ios"),
            ]
        ),
    ]
)
