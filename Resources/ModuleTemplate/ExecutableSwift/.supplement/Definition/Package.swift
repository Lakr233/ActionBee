// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Definition",
    products: [
        .library(name: "Definition", targets: ["Definition"]),
    ],
    targets: [
        .target(name: "Definition", dependencies: []),
    ]
)
