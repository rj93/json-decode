// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "json-decode",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
//        .package(url: "https://github.com/kelvin13/swift-json", from: "0.3.0"),
        .package(url: "https://github.com/kelvin13/swift-json", branch: "master"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "json-decode",
            dependencies: [
                .product(name: "JSON", package: "swift-json"),
            ]),
        .testTarget(
            name: "json-decodeTests",
            dependencies: ["json-decode"]),
    ]
)
