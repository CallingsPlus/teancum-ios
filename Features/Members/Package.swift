// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Members",
    defaultLocalization: "en",
    platforms: [.iOS(.v16), .macOS(.v13), .macCatalyst(.v16)],
    products: [
        .library(name: "Members", targets: ["Members"]),
        .library(name: "MembersAppCode", targets: ["MembersAppCode"]),
        .library(name: "MembersProdConfig", targets: ["MembersProdConfig"]),
        .library(name: "MembersMockConfig", targets: ["MembersMockConfig"]),
    ],
    dependencies: [
        .package(name: "Common", path: "../../Common"),
        .package(name: "Platform", path: "../../Platform"),
        .package(url: "https://github.com/wayfair/vsm-ios", exact: "1.1.1"),
    ],
    targets: [
        .target(name: "Members", dependencies: [
            .product(name: "Components", package: "Platform"),
            .product(name: "ErrorHandling", package: "Platform"),
            .product(name: "ExtendedFoundation", package: "Platform"),
            .product(name: "Logging", package: "Platform"),
            .product(name: "VSM", package: "vsm-ios"),
        ]),
        .target(name: "MembersAppCode", dependencies: [
            .product(name: "ErrorHandling", package: "Platform"),
            .product(name: "ExtendedFoundation", package: "Platform"),
            "MembersMockConfig",
        ]),
        .target(name: "MembersMockConfig", dependencies: [
            "Members"
        ]),
        .target(name: "MembersProdConfig", dependencies: [
            .product(name: "ErrorHandling", package: "Platform"),
            .product(name: "FirebaseClient", package: "Common"),
            .product(name: "ExtendedFoundation", package: "Platform"),
            .product(name: "Logging", package: "Platform"),
            "Members"
        ]),
        .testTarget(name: "MembersTests", dependencies: [
            "Members"
        ])
    ]
)
