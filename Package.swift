// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftOracle",
    products: [
        .library(name: "SwiftOracle", targets: ["SwiftOracle"])
    ],
    dependencies: [
        .package(url: "https://github.com/iWECon/cocilib", .upToNextMajor(from: "1.1.1"))
    ],
    targets: [
        .target(name: "SwiftOracle", dependencies: ["cocilib"])
    ]
)
