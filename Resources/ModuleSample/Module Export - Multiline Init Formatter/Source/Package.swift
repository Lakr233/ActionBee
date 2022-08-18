// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Source",
    products: [
        .library(name: "Source", targets: ["Source"]),
    ],
    dependencies: [
        .package(name: "Definition", path: "./.supplement/Definition"),
    ],
    targets: [
        .target(name: "Source", dependencies: ["Definition"]),
    ]
)
