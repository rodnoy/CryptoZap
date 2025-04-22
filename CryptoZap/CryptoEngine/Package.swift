// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CryptoEngine",
    defaultLocalization: "en",
    platforms: [.macOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CryptoEngine",
            targets: ["CryptoEngine"]),
    ],
    dependencies: [
          .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
          .package(url: "https://github.com/weichsel/ZIPFoundation", from: "0.9.0"),
      ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CryptoEngine",
            dependencies: [
                            "ZIPFoundation"
                        ],
            resources: [
                .process("Resources")
            ]
        ),
        .executableTarget(
            name: "cryptozap-cli",
            dependencies: [
                "CryptoEngine",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .testTarget(
            name: "CryptoEngineTests",
            dependencies: ["CryptoEngine"]
        ),
        .testTarget(
            name: "cryptozap-cliTests",
            dependencies: [
                "CryptoEngine"
            ]
        ),
    ]
)
