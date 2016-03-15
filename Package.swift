




import PackageDescription

let package = Package(
    name: "SwiftOracle",
    dependencies: [
        .Package(url: "https://github.com/goloveychuk/cocilib.git", majorVersion: 0),
        .Package(url: "https://github.com/Zewo/Data.git", majorVersion: 0, minor: 2)
    ]
)