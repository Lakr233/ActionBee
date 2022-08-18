// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Communicator",
    products: [
        .library(name: "Communicator", targets: ["Communicator"]),
    ],
    targets: [
        .target(name: "Communicator", dependencies: []),
    ]
)
