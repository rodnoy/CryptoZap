// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.
// cryptozap-cli/Package.swift : k3
import PackageDescription

let package = Package(
    name: "cryptozap-cli",
    platforms: [.macOS(.v12)],
    dependencies: [
        .package(path: "../CryptoEngine"),  // local dependency on CryptoEngine
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "cryptozap-cli",
            dependencies: [
                "CryptoEngine",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .testTarget(
            name: "cryptozap-cliTests",
            dependencies: ["cryptozap-cli"]
        ),
    ]
)
