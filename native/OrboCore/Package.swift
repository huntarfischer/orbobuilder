// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "OrboCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "OrboCore",
            targets: ["OrboCore"]
        )
    ],
    targets: [
        .target(
            name: "OrboCore",
            resources: [
                .copy("Geoplacement/Resources/geoplacement-atlas-v1.js")
            ]
        ),
        .testTarget(
            name: "OrboCoreTests",
            dependencies: ["OrboCore"],
            resources: [
                .copy("Fixtures")
            ]
        )
    ]
)
