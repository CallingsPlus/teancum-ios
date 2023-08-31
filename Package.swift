// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "teancum",
    defaultLocalization: "en",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(name: "AppFeature", targets: ["AppFeature"]),
        .library(name: "FirebaseClient", targets: ["FirebaseClient"]),
    ],
    dependencies: [
        .package(
            name: "Firebase",
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            .upToNextMajor(from: "10.4.0")
          ),
        .package(
            name: "FirebaseUI",
            url: "https://github.com/firebase/FirebaseUI-iOS/",
            .upToNextMajor(from: "13.0.0")
          ),
    ],
    targets: [
        .target(
            name: "FirebaseClient",
            dependencies: [
                .product(name: "FirebaseAuth", package: "Firebase"),
                .product(name: "FirebaseFirestore", package: "Firebase"),
                .product(name: "FirebaseFirestoreSwift", package: "Firebase"),
                .product(name: "FirebaseAuthUI", package: "FirebaseUI"),
                .product(name: "FirebaseEmailAuthUI", package: "FirebaseUI"),
                .product(name: "FirebasePhoneAuthUI", package: "FirebaseUI"),
            ]
        ),
        .target(
            name: "AppFeature",
            dependencies: [
                "FirebaseClient"
            ]
        ),
    ]
)
