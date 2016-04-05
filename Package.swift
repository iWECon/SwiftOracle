




import PackageDescription

let package = Package(
    name: "SwiftOracle",
    targets: [Target(name: "SwiftOracle", dependencies: ["cocilib"])],
    dependencies: [
        .Package(url: "https://github.com/Zewo/String.git", majorVersion: 0, minor: 4),
    ]
)
