// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "teancum",
    defaultLocalization: "en",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(name: "AppCode", targets: ["AppCode"]),
        .library(name: "ErrorHandling", targets: ["ErrorHandling"]),
        .library(name: "FirebaseClient", targets: ["FirebaseClient"]),
        .library(name: "Logging", targets: ["Logging"]),
    ],
    dependencies: [
        .package(
            name: "Firebase",
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            .exact("10.14.0")
        ),
        .package(
            name: "FirebaseUI",
            url: "https://github.com/firebase/FirebaseUI-iOS/",
            .exact("13.0.0")
        ),
        .package(
            name: "VSM",
            url: "https://github.com/wayfair/vsm-ios",
            .exact("1.1.1")
        ),
    ],
    targets: [
        .target(
            name: "FirebaseClient",
            dependencies: [
                .product(name: "FirebaseAuth", package: "Firebase"),
                .product(name: "FirebaseAuthUI", package: "FirebaseUI"),
                .product(name: "FirebaseEmailAuthUI", package: "FirebaseUI"),
                .product(name: "FirebaseFirestore", package: "Firebase"),
                .product(name: "FirebaseFirestoreSwift", package: "Firebase"),
                .product(name: "FirebasePhoneAuthUI", package: "FirebaseUI"),
            ]
        ),
        .target(
            name: "AppCode",
            dependencies: [
                "ErrorHandling",
                "FirebaseClient",
                "Logging",
                "VSM",
            ]
        ),
        .target(
            name: "ErrorHandling",
            dependencies: []
        ),
        .target(
            name: "Logging",
            dependencies: []
        ),
    ]
)
