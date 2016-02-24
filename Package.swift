




import PackageDescription

let package = Package(
    name: "SwiftOracle",
    dependencies: [
        .Package(url: "../cocilib", majorVersion: 0),
        .Package(url: "https://github.com/Zewo/SQL.git", majorVersion: 0, minor: 2),
    ]
)