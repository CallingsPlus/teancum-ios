// swift-tools-version:5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Onboarding",
    defaultLocalization: "en",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(name: "Onboarding", targets: ["Onboarding"]),
        .library(name: "OnboardingConfig", targets: ["OnboardingConfig"]),
        .library(name: "OnboardingMockConfig", targets: ["OnboardingMockConfig"]),
    ],
    dependencies: [
        .package(name: "Common", path: "../../Common"),
        .package(name: "Platform", path: "../../Platform"),
        .package(url: "https://github.com/wayfair/vsm-ios", exact: "1.1.1"),
    ],
    targets: [
        .target(name: "Onboarding", dependencies: [
            .product(name: "ErrorHandling", package: "Platform"),
            .product(name: "FoundationPlus", package: "Platform"),
            .product(name: "Logging", package: "Platform"),
            .product(name: "VSM", package: "vsm-ios"),
        ]),
        .target(name: "OnboardingConfig", dependencies: [
            .product(name: "ErrorHandling", package: "Platform"),
            .product(name: "FirebaseClient", package: "Common"),
            .product(name: "FoundationPlus", package: "Platform"),
            .product(name: "Logging", package: "Platform"),
            .target(name: "Onboarding"),
        ]),
        .target(name: "OnboardingMockConfig", dependencies: [
            .product(name: "ErrorHandling", package: "Platform"),
            .product(name: "FoundationPlus", package: "Platform"),
            .product(name: "Logging", package: "Platform"),
            .target(name: "Onboarding"),
        ]),
    ]
)
