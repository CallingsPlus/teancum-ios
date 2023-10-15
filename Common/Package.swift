// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Common",
    defaultLocalization: "en",
    platforms: [.iOS(.v16), .macOS(.v12)],
    products: [
        .library(name: "FirebaseClient", targets: ["FirebaseClient"])
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", exact: "10.14.0"),
        .package(url: "https://github.com/firebase/FirebaseUI-iOS/", exact: "13.0.0"),
        .package(name: "Platform", path: "../Platform"),
    ],
    targets: [
        .target(
            name: "FirebaseClient",
            dependencies: [
                .product(name: "ErrorHandling", package: "Platform"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAuthUI", package: "FirebaseUI-iOS"),
                .product(name: "FirebaseEmailAuthUI", package: "FirebaseUI-iOS"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestoreSwift", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFunctions", package: "firebase-ios-sdk"),
                .product(name: "FirebasePhoneAuthUI", package: "FirebaseUI-iOS"),
                .product(name: "Logging", package: "Platform"),
            ]
        ),
    ]
)
