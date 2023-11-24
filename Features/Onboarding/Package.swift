// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Onboarding",
    defaultLocalization: "en",
    platforms: [.iOS(.v16), .macOS(.v13), .macCatalyst(.v16)],
    products: [
        .library(name: "Onboarding", targets: ["Onboarding"]),
        .library(name: "OnboardingAppCode", targets: ["OnboardingAppCode"]),
        .library(name: "OnboardingProdConfig", targets: ["OnboardingProdConfig"]),
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
            .product(name: "ExtendedFoundation", package: "Platform"),
            .product(name: "Logging", package: "Platform"),
            .product(name: "VSM", package: "vsm-ios"),
        ]),
        .target(name: "OnboardingAppCode", dependencies: [
            .product(name: "ErrorHandling", package: "Platform"),
            .product(name: "ExtendedFoundation", package: "Platform"),
            "OnboardingMockConfig",
        ]),
        .target(name: "OnboardingMockConfig", dependencies: [
            "Onboarding"
        ]),
        .target(name: "OnboardingProdConfig", dependencies: [
            .product(name: "ErrorHandling", package: "Platform"),
            .product(name: "FirebaseDataServices", package: "Common"),
            .product(name: "ExtendedFoundation", package: "Platform"),
            .product(name: "Logging", package: "Platform"),
            "Onboarding"
        ]),
        .testTarget(name: "OnboardingTests", dependencies: [
            "Onboarding"
        ])
    ]
)
