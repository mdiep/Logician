// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Logician",
    targets: [
        .target(name: "Logician", dependencies: [], path: "Sources"),
        .testTarget(name: "LogicianTests", dependencies: ["Logician"], path: "Tests"),
    ]
)
