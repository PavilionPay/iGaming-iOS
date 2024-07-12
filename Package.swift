// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iGamingKit",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "iGamingKit",
            targets: ["iGamingKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/plaid/plaid-link-ios", from: "5.6.0"),
    ],
    targets: [
        .target(
            name: "iGamingKit",
            dependencies: [
                .product(name: "LinkKit", package: "plaid-link-ios")
            ]
        )
    ]
)
