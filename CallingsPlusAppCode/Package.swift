// swift-tools-version:5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CallingsPlusAppCode",
    defaultLocalization: "en",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(name: "CallingsPlusAppCode", targets: ["CallingsPlusAppCode"])
    ],
    dependencies: [
        .package(name: "Common", path: "../Common"),
        .package(name: "Members", path: "../Features/Members"),
        .package(name: "Onboarding", path: "../Features/Onboarding"),
        .package(name: "Platform", path: "../Platform"),
        .package(url: "https://github.com/wayfair/vsm-ios", exact: "1.1.1"),
    ],
    targets: [
        .target(
            name: "CallingsPlusAppCode",
            dependencies: [
                .product(name: "ErrorHandling", package: "Platform"),
                .product(name: "FirebaseClient", package: "Common"),
                .product(name: "ExtendedFoundation", package: "Platform"),
                .product(name: "Logging", package: "Platform"),
                .product(name: "MembersProdConfig", package: "Members"),
                .product(name: "OnboardingProdConfig", package: "Onboarding"),
                .product(name: "VSM", package: "vsm-ios"),
            ]
        ),
    ]
)
